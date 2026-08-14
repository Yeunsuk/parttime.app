import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../workplace/domain/workplace_model.dart';
import '../../workplace/presentation/workplace_provider.dart';
import 'work_record_provider.dart';
import '../domain/work_record_model.dart';


class WorkerHomeScreen extends ConsumerWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final statusAsync = ref.watch(workStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${user?.name ?? ''}의 근무'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (status) => _HomeBody(status: status),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  final WorkStatusModel status;

  const _HomeBody({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isClockedIn = status.isClockedIn;
    final record = status.currentRecord;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // 상태 카드
          _StatusCard(isClockedIn: isClockedIn, record: record),
          const SizedBox(height: 32),

          // 출근/퇴근 버튼
          _ClockButton(isClockedIn: isClockedIn, record: record),
          const SizedBox(height: 40),

          // 하단 바로가기
          Row(
            children: [
              Expanded(
                child: _ShortcutCard(
                  icon: Icons.calendar_month_outlined,
                  label: '근무 달력',
                  onTap: () => context.push('/worker/calendar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ShortcutCard(
                  icon: Icons.store_outlined,
                  label: '근무지 관리',
                  onTap: () => context.push('/worker/workplace'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isClockedIn;
  final WorkRecordModel? record;

  const _StatusCard({required this.isClockedIn, required this.record});

  String _formatClockInTime(String iso) {
    final dt = DateTime.parse(iso).toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isClockedIn
              ? [AppColors.success, const Color(0xFF2E7D32)]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isClockedIn ? AppColors.success : AppColors.primary)
                .withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: isClockedIn ? Colors.greenAccent : Colors.white54,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isClockedIn ? '근무 중' : '미출근',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isClockedIn && record != null) ...[
            Text(
              record!.workplaceName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_formatClockInTime(record!.clockIn)}부터 출근',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            const Text(
              '오늘도 화이팅!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _todayString(),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  String _todayString() {
    final now = DateTime.now();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${now.year}.${now.month.toString().padLeft(2,'0')}.${now.day.toString().padLeft(2,'0')} (${weekdays[now.weekday - 1]})';
  }
}

class _ClockButton extends ConsumerWidget {
  final bool isClockedIn;
  final WorkRecordModel? record;

  const _ClockButton({required this.isClockedIn, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(workStatusProvider).isLoading;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () async {
              if (isClockedIn && record != null) {
                // 퇴근 확인 다이얼로그
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('퇴근'),
                    content: const Text('퇴근 처리하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('퇴근'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(workStatusProvider.notifier).clockOut(record!.id);
                }
              } else {
                final workplaceId = await _resolveWorkplaceId(context, ref);
                if (workplaceId == null) return;
                await ref.read(workStatusProvider.notifier).clockIn(workplaceId);
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isClockedIn ? AppColors.error : AppColors.success,
          boxShadow: [
            BoxShadow(
              color: (isClockedIn ? AppColors.error : AppColors.success)
                  .withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isClockedIn ? Icons.logout : Icons.login,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isClockedIn ? '퇴근' : '출근',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // 출근할 근무지 결정: 근무지가 없으면 근무지 관리 화면으로 유도,
  // 1개면 그대로 사용, 여러 개면 선택 다이얼로그를 띄운다.
  Future<int?> _resolveWorkplaceId(BuildContext context, WidgetRef ref) async {
    final workplaces = await ref.read(myWorkplacesProvider.future);

    if (workplaces.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('먼저 근무지에 참가해주세요.')),
        );
        context.push('/worker/workplace');
      }
      return null;
    }

    if (workplaces.length == 1) {
      return workplaces.first.id;
    }

    if (!context.mounted) return null;
    final chosen = await showDialog<WorkplaceModel>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('출근할 근무지를 선택하세요'),
        children: workplaces
            .map((w) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, w),
                  child: Text(w.name),
                ))
            .toList(),
      ),
    );
    return chosen?.id;
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
