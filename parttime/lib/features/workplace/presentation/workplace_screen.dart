import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_provider.dart';
import '../domain/workplace_model.dart';
import 'workplace_forms.dart';
import 'workplace_provider.dart';

// 근무지 관리 화면: 내가 속한 근무지 목록을 보여주고,
// 근무지가 여러 개면 그중 하나를 "현재 근무지"로 고를 수 있게 하고,
// 새 근무지를 생성(사장)하거나 초대코드로 참가(알바생)할 수 있게 한다.
class WorkplaceScreen extends ConsumerWidget {
  const WorkplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workplacesAsync = ref.watch(myWorkplacesProvider);
    final selectedId = ref.watch(selectedWorkplaceIdProvider);
    final role = ref.watch(authStateProvider).value?.role;

    return Scaffold(
      appBar: AppBar(title: const Text('근무지 관리')),
      body: workplacesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (workplaces) => workplaces.isEmpty
            ? _EmptyState(role: role)
            : _WorkplaceList(workplaces: workplaces, selectedId: selectedId),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context, role),
        icon: const Icon(Icons.add),
        label: Text(role == 'OWNER' ? '근무지 생성' : '초대코드로 참가'),
      ),
    );
  }

  void _openAddSheet(BuildContext context, String? role) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: role == 'OWNER'
            ? CreateWorkplaceForm(onSuccess: () => Navigator.pop(ctx))
            : JoinWorkplaceForm(onSuccess: () => Navigator.pop(ctx)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? role;
  const _EmptyState({required this.role});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store_outlined,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              role == 'OWNER'
                  ? '아직 만든 근무지가 없어요.\n오른쪽 아래 버튼으로 근무지를 만들어보세요.'
                  : '아직 참가한 근무지가 없어요.\n오른쪽 아래 버튼으로 초대코드를 입력해주세요.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkplaceList extends ConsumerWidget {
  final List<WorkplaceModel> workplaces;
  final int? selectedId;

  const _WorkplaceList({required this.workplaces, required this.selectedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: workplaces.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final w = workplaces[i];
        final isSelected = workplaces.length == 1 || w.id == selectedId;
        return GestureDetector(
          onTap: () =>
              ref.read(selectedWorkplaceIdProvider.notifier).select(w.id),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('사장: ${w.ownerName} · 시급 ${w.hourlyWage}원',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text('초대코드: ${w.inviteCode}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
          ),
        );
      },
    );
  }
}
