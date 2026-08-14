import 'dart:convert';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/presentation/auth_provider.dart';
import '../../account/domain/account_model.dart';
import '../../account/presentation/account_popup.dart';
import '../../account/presentation/account_provider.dart';
import '../../account/presentation/qr_chip.dart';
import '../../workplace/domain/workplace_model.dart';
import '../../workplace/presentation/workplace_gate.dart';
import '../../workplace/presentation/workplace_provider.dart';
import '../../workplace/presentation/worker_color_provider.dart';
import '../domain/payroll_model.dart';
import 'payroll_provider.dart';
import 'time_row.dart';

// 횟수제 표기용: 정수면 "3회", 0.5 단위 소수면 "1.5회"처럼 보여준다.
String _formatCount(double count) {
  return count == count.roundToDouble()
      ? '${count.toInt()}회'
      : '$count회';
}

// 근무지 "분설정"에서 활성화된 분(options) 중 지금 시각(nowHour:nowMinute)과 실제로 가장
// 가까운 시각을 (시, 분)으로 반환한다. 분만 따로 놓고 비교하면 시간이 안 넘어가서, 예를 들어
// 22:59에 options=[0,30]이면 22:30(29분 차이)을 골라버리는 버그가 있었다 — 실제로는
// 23:00(1분 차이)이 훨씬 가깝다. 그래서 앞/현재/다음 시간의 후보를 모두 놓고 실제 분 단위
// 거리로 비교한다. 동률이면 더 이른 시각을 고른다.
(int, int) _nearestClockTime(int nowHour, int nowMinute, List<int> options) {
  if (options.isEmpty) return (nowHour, nowMinute);
  final nowTotal = nowHour * 60 + nowMinute;
  int bestTotal = (nowHour - 1) * 60 + options.first;
  int bestDist = (bestTotal - nowTotal).abs();
  for (final dh in [-1, 0, 1]) {
    for (final m in options) {
      final total = (nowHour + dh) * 60 + m;
      final dist = (total - nowTotal).abs();
      if (dist < bestDist || (dist == bestDist && total < bestTotal)) {
        bestDist = dist;
        bestTotal = total;
      }
    }
  }
  final minute = bestTotal % 60;
  final hour = ((bestTotal - minute) ~/ 60) % 24;
  return (hour, minute);
}

// 근무기록 추가 다이얼로그의 근로자 드롭다운 정렬 기준: (1) 그 날짜 요일에 활성인 근로자가
// 먼저, (2) 같은 활성 여부 안에서는 시간제가 횟수제보다 먼저, (3) 그 안에서는 가나다순.
// date.weekday는 1=월요일 ... 7=일요일이라 WorkerModel.workingDays(같은 값 규칙)와 그대로 비교한다.
// "미설정"(workingDaysEnabled=false)이면 선택된 요일 자체가 없으므로 항상 비활성으로 취급한다.
int _compareWorkersForAddRecord(WorkerModel a, WorkerModel b, DateTime date) {
  final dayValue = date.weekday;
  final aActive = a.workingDaysEnabled && a.workingDays.contains(dayValue);
  final bActive = b.workingDaysEnabled && b.workingDays.contains(dayValue);
  if (aActive != bActive) return aActive ? -1 : 1;

  final aCount = a.paymentType == 'COUNT';
  final bCount = b.paymentType == 'COUNT';
  if (aCount != bCount) return aCount ? 1 : -1;

  return a.name.compareTo(b.name);
}

class OwnerHomeScreen extends ConsumerWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('${user?.name ?? ''} 사장님'),
        leading: Consumer(
          builder: (context, ref, _) {
            final workplaces = ref.watch(myWorkplacesProvider).value ?? [];
            final selectedId = ref.watch(selectedWorkplaceIdProvider);
            final workplace = resolveWorkplace(workplaces, selectedId);
            if (workplace == null) return const SizedBox.shrink();
            // 버튼을 눌렀을 때 곧바로(동기적으로) 팝업을 열 수 있도록 미리
            // 불러와둔다 — 클릭 이후 await를 거치면 브라우저가 사용자 조작과
            // 무관한 팝업으로 간주해 차단할 수 있다.
            final accountsAsync =
                ref.watch(workplaceAccountsProvider(workplace.id));
            return IconButton(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              tooltip: '계좌',
              onPressed: !accountsAsync.hasValue
                  ? null
                  : () {
                      // 로그인/API 호출 없이 계좌 데이터를 URL에 그대로 담아 넘긴다.
                      // 웹에서는 기존 창을 그대로 두고 별도의 팝업 창으로 띄운다 —
                      // 위치 이동/크기 조절 등 독립적인 컨트롤이 가능해야 하므로
                      // 인앱 화면 전환이 아니라 진짜 새 브라우저 창을 연다. 웹이
                      // 아닌 플랫폼에서는 팝업 창 개념이 없어 일반 화면 이동으로
                      // 대체한다.
                      final jsonStr = jsonEncode(
                          accountsAsync.value!.map((a) => a.toJson()).toList());
                      final encoded = base64Url.encode(utf8.encode(jsonStr));
                      final target = '/account-popup'
                          '?workplaceName=${Uri.encodeComponent(workplace.name)}'
                          '&data=${Uri.encodeComponent(encoded)}';
                      // Uri.replace(fragment: '')는 "빈 프래그먼트가 있는" 상태가
                      // 되어 뒤에 '#'이 하나 더 남는다 — 그대로 이어붙이면
                      // "...##/account-popup..."처럼 '#'이 두 번 들어가 팝업이
                      // 이 주소를 인식하지 못하는 원인이 됐다. 문자열을 직접
                      // '#' 기준으로 잘라내 확실히 하나만 붙인다.
                      final baseUrl = Uri.base.toString().split('#').first;
                      final popupUrl = '$baseUrl#$target';
                      if (!openAccountPopup(popupUrl)) {
                        context.push(target);
                      }
                    },
            );
          },
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final workplaces = ref.watch(myWorkplacesProvider).value ?? [];
              final selectedId = ref.watch(selectedWorkplaceIdProvider);
              final workplace = resolveWorkplace(workplaces, selectedId);
              if (workplace == null) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.vpn_key_outlined),
                    tooltip: '초대코드 보기',
                    onPressed: () => _showInviteCodeDialog(context, workplace),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: '근무지 설정',
                    onPressed: () => _showWorkplaceSettingsDialog(context, workplace),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: WorkplaceGate(
        builder: (context, workplace) => _OwnerHomeBody(workplace: workplace),
      ),
    );
  }
}

void _showInviteCodeDialog(BuildContext context, WorkplaceModel workplace) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('${workplace.name} 초대코드'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            workplace.inviteCode,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: '복사',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: workplace.inviteCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('초대코드가 복사되었습니다.')),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}

void _showWorkplaceSettingsDialog(BuildContext context, WorkplaceModel workplace) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('근무지 설정'),
      content: SizedBox(
        width: double.maxFinite,
        child: Consumer(
          builder: (context, ref, _) {
            // 인원제한은 실시간 값이 필요하므로 다이얼로그 오픈 시점의 스냅샷인
            // workplace 파라미터 대신 myWorkplacesProvider를 반응형으로 watch한다.
            final workplaces = ref.watch(myWorkplacesProvider).value ?? [];
            final current = workplaces.where((w) => w.id == workplace.id).firstOrNull ??
                workplace;

            final workersAsync = ref.watch(workplaceWorkersProvider(workplace.id));

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('인원제한',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Builder(builder: (context) {
                    final currentMemberCount = workersAsync.value?.length ?? 0;
                    final minLimit =
                        currentMemberCount > 1 ? currentMemberCount : 1;
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: current.memberLimit > minLimit
                              ? () => _changeMemberLimit(context, ref,
                                  workplace.id, current.memberLimit - 1)
                              : null,
                        ),
                        Text(
                          '${current.memberLimit}명',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _changeMemberLimit(context, ref,
                              workplace.id, current.memberLimit + 1),
                        ),
                      ],
                    );
                  }),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _showHourSettingsDialog(context, workplace.id),
                          child: const Text('시간설정'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _showMinuteSettingsDialog(context, workplace.id),
                          child: const Text('분설정'),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('직원 관리',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () =>
                            _showAddMemberDialog(context, ref, workplace.id),
                        icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                        label: const Text('직원 추가'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  workersAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('오류: $e'),
                    data: (workers) {
                      if (workers.isEmpty) {
                        return const Text('아직 소속된 직원이 없습니다.');
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: workers.map((w) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(w.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Wrap(
                                  spacing: 4,
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8)),
                                      onPressed: () => _showPayPeriodDialog(
                                          context, ref, workplace.id, w),
                                      child: const Text('월급설정',
                                          style: TextStyle(fontSize: 13)),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8)),
                                      onPressed: () => _showPaymentTypeDialog(
                                          context, ref, workplace.id, w),
                                      child: const Text('정산방식',
                                          style: TextStyle(fontSize: 13)),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8)),
                                      onPressed: () => _showDefaultTimeDialog(
                                          context, ref, workplace.id, w),
                                      child: const Text('시간설정',
                                          style: TextStyle(fontSize: 13)),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8)),
                                      onPressed: () => _showWorkingDaysDialog(
                                          context, ref, workplace.id, w),
                                      child: const Text('요일설정',
                                          style: TextStyle(fontSize: 13)),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8)),
                                      onPressed: () => _showCalendarColorDialog(
                                          context, ref, workplace.id, w),
                                      child: const Text('달력색상',
                                          style: TextStyle(fontSize: 13)),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8)),
                                      onPressed: () => _showRemoveMemberConfirm(
                                          context, ref, workplace.id, w),
                                      child: const Text('내보내기',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('계좌설정',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () =>
                            _showAddAccountDialog(context, ref, workplace.id),
                        icon: const Icon(Icons.add_card_outlined, size: 18),
                        label: const Text('계좌 추가'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, _) {
                      final accountsAsync =
                          ref.watch(workplaceAccountsProvider(workplace.id));
                      return accountsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Text('오류: $e'),
                        data: (accounts) {
                          if (accounts.isEmpty) {
                            return const Text('등록된 계좌가 없습니다.');
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: accounts.map((a) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.accountName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      '${a.bankName} ${a.accountNumber}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary),
                                    ),
                                    if (a.qrCodes.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: a.qrCodes
                                            .map((qr) => QrChip(
                                                  qr: qr,
                                                  onDelete: () =>
                                                      _showRemoveQrConfirm(
                                                          context,
                                                          ref,
                                                          workplace.id,
                                                          a,
                                                          qr),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                    Wrap(
                                      spacing: 4,
                                      children: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8)),
                                          onPressed: () => _showGenerateQrDialog(
                                              context, ref, workplace.id, a),
                                          child: const Text('QR자동생성',
                                              style: TextStyle(fontSize: 13)),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8)),
                                          onPressed: () => _showAddQrDialog(
                                              context, ref, workplace.id, a),
                                          child: const Text('QR추가',
                                              style: TextStyle(fontSize: 13)),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8)),
                                          onPressed: () =>
                                              _showRemoveAccountConfirm(
                                                  context, ref, workplace.id, a),
                                          child: const Text('계좌 삭제',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error),
                      onPressed: () async {
                        await ref.read(authStateProvider.notifier).logout();
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('로그아웃'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}

Future<void> _changeMemberLimit(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  int newLimit,
) async {
  await ref
      .read(myWorkplacesProvider.notifier)
      .updateMemberLimit(workplaceId, newLimit);

  if (!context.mounted) return;
  final result = ref.read(myWorkplacesProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('변경 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

Future<void> _toggleDisabledHour(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  List<int> currentDisabledHours,
  int hour,
) async {
  final next = currentDisabledHours.contains(hour)
      ? (currentDisabledHours.where((h) => h != hour).toList())
      : ([...currentDisabledHours, hour]);

  // 0~23시 24개 + "현재시간" 1개 = 총 25개 중 최소 1개는 활성화되어 있어야 한다.
  if (next.length >= 25) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('최소 1개의 시간은 활성화되어 있어야 합니다.')),
    );
    return;
  }

  await ref.read(myWorkplacesProvider.notifier).updateDisabledHours(workplaceId, next);

  if (!context.mounted) return;
  final result = ref.read(myWorkplacesProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('변경 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

Future<void> _toggleEnabledMinute(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  List<int> currentEnabledMinutes,
  int minute,
) async {
  final next = currentEnabledMinutes.contains(minute)
      ? (currentEnabledMinutes.where((m) => m != minute).toList())
      : ([...currentEnabledMinutes, minute]);

  if (next.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('최소 1개의 분은 활성화되어 있어야 합니다.')),
    );
    return;
  }

  await ref.read(myWorkplacesProvider.notifier).updateEnabledMinutes(workplaceId, next);

  if (!context.mounted) return;
  final result = ref.read(myWorkplacesProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('변경 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

void _showHourSettingsDialog(BuildContext context, int workplaceId) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('시간설정'),
      content: SizedBox(
        width: double.maxFinite,
        child: Consumer(
          builder: (context, ref, _) {
            final workplaces = ref.watch(myWorkplacesProvider).value ?? [];
            final disabledHours = workplaces
                    .where((w) => w.id == workplaceId)
                    .firstOrNull
                    ?.disabledHours ??
                const <int>[];

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('선택한 시간은 근무기록 생성/수정 시 시간 목록에서 제외됩니다.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [TimeRow.currentTimeSentinel, ...List.generate(24, (h) => h)]
                        .map((h) {
                      final isCurrentTime = h == TimeRow.currentTimeSentinel;
                      final disabled = disabledHours.contains(h);
                      return FilterChip(
                        label: Text(isCurrentTime ? '현재시간' : '$h시'),
                        selected: !disabled,
                        showCheckmark: false,
                        selectedColor: AppColors.primary.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: disabled
                              ? AppColors.textSecondary
                              : AppColors.primary,
                          decoration:
                              disabled ? TextDecoration.lineThrough : null,
                        ),
                        onSelected: (_) => _toggleDisabledHour(
                            context, ref, workplaceId, disabledHours, h),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}

void _showMinuteSettingsDialog(BuildContext context, int workplaceId) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('분설정'),
      content: SizedBox(
        width: double.maxFinite,
        child: Consumer(
          builder: (context, ref, _) {
            final workplaces = ref.watch(myWorkplacesProvider).value ?? [];
            final enabledMinutes = workplaces
                    .where((w) => w.id == workplaceId)
                    .firstOrNull
                    ?.enabledMinutes ??
                const <int>[0, 30];

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('선택한 분만 근무기록 생성/수정 시 분 목록에 표시됩니다.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(60, (m) => m).map((m) {
                      final enabled = enabledMinutes.contains(m);
                      return FilterChip(
                        label: Text('$m분'),
                        selected: enabled,
                        showCheckmark: false,
                        selectedColor: AppColors.primary.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: enabled
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          decoration:
                              enabled ? null : TextDecoration.lineThrough,
                        ),
                        onSelected: (_) => _toggleEnabledMinute(
                            context, ref, workplaceId, enabledMinutes, m),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}

Future<void> _showAddMemberDialog(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
) async {
  final employeeId = await showDialog<String>(
    context: context,
    builder: (_) => const _AddMemberInputDialog(),
  );
  if (employeeId == null || employeeId.isEmpty || !context.mounted) return;

  await ref.read(memberManagementProvider.notifier).addMember(workplaceId, employeeId);

  if (!context.mounted) return;
  final result = ref.read(memberManagementProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('추가 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    // 지금 화면에서 실제로 watch 중인 ref로 직접 다시 무효화해서, 목록이
    // 확실히 바로 갱신되도록 한다.
    ref.invalidate(workplaceWorkersProvider(workplaceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('추가되었습니다.')),
    );
  }
}

class _AddMemberInputDialog extends StatefulWidget {
  const _AddMemberInputDialog();

  @override
  State<_AddMemberInputDialog> createState() => _AddMemberInputDialogState();
}

class _AddMemberInputDialogState extends State<_AddMemberInputDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('직원 추가'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: '아이디',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          child: const Text('추가'),
        ),
      ],
    );
  }
}

Future<void> _showRemoveMemberConfirm(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  WorkerModel worker,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('직원 내보내기'),
      content: Text(
        '${worker.name}님을 이 근무지에서 내보내시겠습니까?\n기존 근무기록은 그대로 남습니다.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('내보내기'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  await ref.read(memberManagementProvider.notifier).removeMember(workplaceId, worker.id);

  if (!context.mounted) return;
  final result = ref.read(memberManagementProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('내보내기 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    // 지금 화면에서 실제로 watch 중인 ref로 직접 다시 무효화해서, 목록이
    // 확실히 바로 갱신되도록 한다.
    ref.invalidate(workplaceWorkersProvider(workplaceId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${worker.name}님을 내보냈습니다.')),
    );
  }
}

// QR 이름을 입력받는 다이얼로그. 은행/간편결제 앱마다 QR 규격이 달라 이름으로 구분한다.
Future<String?> _showQrNameDialog(BuildContext context, String title) {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'QR 이름 (예: 카카오페이, 국민은행)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = ctrl.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(context, name);
          },
          child: const Text('다음'),
        ),
      ],
    ),
  );
}

// 이름을 붙여 QR 이미지 파일을 업로드한다.
Future<void> _showAddQrDialog(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  AccountModel account,
) async {
  final name = await _showQrNameDialog(context, 'QR 추가');
  if (name == null || !context.mounted) return;

  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
  );
  final file = result?.files.single;
  if (file == null || file.bytes == null || !context.mounted) return;

  final ext = file.extension?.toLowerCase();
  final mime = ext == 'jpg' || ext == 'jpeg'
      ? 'image/jpeg'
      : ext == 'gif'
          ? 'image/gif'
          : 'image/png';
  final dataUri = 'data:$mime;base64,${base64Encode(file.bytes!)}';

  await _uploadQr(context, ref, workplaceId, account.id, name, dataUri);
}

// 이름을 붙여 계좌번호를 담은 QR 코드를 앱에서 직접 그려 생성한다 (이미지 업로드 없이).
Future<void> _showGenerateQrDialog(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  AccountModel account,
) async {
  final name = await _showQrNameDialog(context, 'QR 자동생성');
  if (name == null || !context.mounted) return;

  final painter = QrPainter(
    data: account.accountNumber,
    version: QrVersions.auto,
    gapless: false,
  );
  final imageData = await painter.toImageData(400, format: ui.ImageByteFormat.png);
  if (imageData == null || !context.mounted) return;
  final dataUri =
      'data:image/png;base64,${base64Encode(imageData.buffer.asUint8List())}';

  await _uploadQr(context, ref, workplaceId, account.id, name, dataUri);
}

Future<void> _uploadQr(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  int accountId,
  String name,
  String qrImage,
) async {
  await ref.read(accountManagementProvider.notifier).addQr(
        workplaceId,
        accountId,
        name,
        qrImage,
      );

  if (!context.mounted) return;
  final result = ref.read(accountManagementProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR 등록 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    ref.invalidate(workplaceAccountsProvider(workplaceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR이 등록되었습니다.')),
    );
  }
}

Future<void> _showRemoveQrConfirm(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  AccountModel account,
  AccountQrModel qr,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('QR 삭제'),
      content: Text('${qr.name} QR을 삭제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('삭제'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  await ref
      .read(accountManagementProvider.notifier)
      .deleteQr(workplaceId, account.id, qr.id);

  if (!context.mounted) return;
  final result = ref.read(accountManagementProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('삭제 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    ref.invalidate(workplaceAccountsProvider(workplaceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('삭제되었습니다.')),
    );
  }
}

Future<void> _showAddAccountDialog(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
) async {
  final input = await showDialog<_AddAccountInput>(
    context: context,
    builder: (_) => const _AddAccountInputDialog(),
  );
  if (input == null || !context.mounted) return;

  await ref.read(accountManagementProvider.notifier).create(
        workplaceId,
        input.accountName,
        input.accountNumber,
        input.bankName,
      );

  if (!context.mounted) return;
  final result = ref.read(accountManagementProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('추가 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    ref.invalidate(workplaceAccountsProvider(workplaceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('계좌가 추가되었습니다.')),
    );
  }
}

class _AddAccountInput {
  final String accountName;
  final String accountNumber;
  final String bankName;
  const _AddAccountInput({
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
  });
}

class _AddAccountInputDialog extends StatefulWidget {
  const _AddAccountInputDialog();

  @override
  State<_AddAccountInputDialog> createState() => _AddAccountInputDialogState();
}

class _AddAccountInputDialogState extends State<_AddAccountInputDialog> {
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _bankCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('계좌 추가'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: '계좌명'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bankCtrl,
            decoration: const InputDecoration(labelText: '은행명'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _numberCtrl,
            decoration: const InputDecoration(labelText: '계좌번호'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            final number = _numberCtrl.text.trim();
            final bank = _bankCtrl.text.trim();
            if (name.isEmpty || number.isEmpty || bank.isEmpty) return;
            Navigator.pop(
              context,
              _AddAccountInput(
                  accountName: name, accountNumber: number, bankName: bank),
            );
          },
          child: const Text('추가'),
        ),
      ],
    );
  }
}

Future<void> _showRemoveAccountConfirm(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  AccountModel account,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('계좌 삭제'),
      content: Text('${account.accountName} 계좌를 삭제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('삭제'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  await ref.read(accountManagementProvider.notifier).delete(workplaceId, account.id);

  if (!context.mounted) return;
  final result = ref.read(accountManagementProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('삭제 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    ref.invalidate(workplaceAccountsProvider(workplaceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('삭제되었습니다.')),
    );
  }
}

Future<void> _showDefaultTimeDialog(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  WorkerModel worker,
) async {
  final workplaces = ref.read(myWorkplacesProvider).value ?? [];
  final currentWorkplace =
      workplaces.where((w) => w.id == workplaceId).firstOrNull;
  final disabledHours = currentWorkplace?.disabledHours ?? const <int>[];
  final enabledMinutes = currentWorkplace?.enabledMinutes ?? const <int>[0, 30];
  final input = await showDialog<_DefaultTimeInput>(
    context: context,
    builder: (_) => _DefaultTimeDialog(
      worker: worker,
      disabledHours: disabledHours,
      enabledMinutes: enabledMinutes,
    ),
  );
  if (input == null || !context.mounted) return;

  await ref.read(memberManagementProvider.notifier).updateDefaultTime(
        workplaceId,
        worker.id,
        input.clockInHour,
        input.clockInMinute,
        input.clockOutHour,
        input.clockOutMinute,
      );

  if (!context.mounted) return;
  final result = ref.read(memberManagementProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('저장 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    ref.invalidate(workplaceWorkersProvider(workplaceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('기본 근무시간이 저장되었습니다.')),
    );
  }
}

class _DefaultTimeInput {
  final int clockInHour;
  final int clockInMinute;
  final int clockOutHour;
  final int clockOutMinute;
  const _DefaultTimeInput({
    required this.clockInHour,
    required this.clockInMinute,
    required this.clockOutHour,
    required this.clockOutMinute,
  });
}

// 직원별 기본 근무시간 설정 다이얼로그. 값을 안 바꾸고 저장하면 지금 채워진(기존 설정
// 또는 전역 기본값 18~22시) 값 그대로 저장된다 — 즉 손 안 대면 사실상 기존 기본시간 유지.
class _DefaultTimeDialog extends StatefulWidget {
  final WorkerModel worker;
  final List<int> disabledHours;
  final List<int> enabledMinutes;
  const _DefaultTimeDialog({
    required this.worker,
    this.disabledHours = const [],
    this.enabledMinutes = const [0, 30],
  });

  @override
  State<_DefaultTimeDialog> createState() => _DefaultTimeDialogState();
}

class _DefaultTimeDialogState extends State<_DefaultTimeDialog> {
  late int _clockInHour;
  late int _clockInMinute;
  late int _clockOutHour;
  late int _clockOutMinute;

  @override
  void initState() {
    super.initState();
    _clockInHour = widget.worker.defaultClockInHour ?? 18;
    _clockInMinute = widget.worker.defaultClockInMinute ?? 0;
    _clockOutHour = widget.worker.defaultClockOutHour ?? 22;
    _clockOutMinute = widget.worker.defaultClockOutMinute ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.worker.name}님 시간설정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimeRow(
            label: '출근',
            hour: _clockInHour,
            minute: _clockInMinute,
            onHourChanged: (h) => setState(() => _clockInHour = h),
            onMinuteChanged: (m) => setState(() => _clockInMinute = m),
            disabledHours: widget.disabledHours,
            enabledMinutes: widget.enabledMinutes,
            allowCurrentTimeOption: true,
          ),
          const SizedBox(height: 12),
          TimeRow(
            label: '퇴근',
            hour: _clockOutHour,
            minute: _clockOutMinute,
            onHourChanged: (h) => setState(() => _clockOutHour = h),
            onMinuteChanged: (m) => setState(() => _clockOutMinute = m),
            enabledMinutes: widget.enabledMinutes,
            disabledHours: widget.disabledHours,
            allowCurrentTimeOption: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            _DefaultTimeInput(
              clockInHour: _clockInHour,
              clockInMinute: _clockInMinute,
              clockOutHour: _clockOutHour,
              clockOutMinute: _clockOutMinute,
            ),
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }
}

Future<void> _showPayPeriodDialog(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  WorkerModel worker,
) async {
  final startDay = await showDialog<int>(
    context: context,
    builder: (_) => _PayPeriodDialog(worker: worker),
  );
  if (startDay == null || !context.mounted) return;

  await ref
      .read(memberManagementProvider.notifier)
      .updatePayPeriod(workplaceId, worker.id, startDay);

  if (!context.mounted) return;
  final result = ref.read(memberManagementProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('저장 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    ref.invalidate(workplaceWorkersProvider(workplaceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('정산 기간이 저장되었습니다.')),
    );
  }
}

// 직원별 정산 기간(월급설정) 다이얼로그. 시작일이 1이면 달력월(기본값)과 동일하다.
class _PayPeriodDialog extends StatefulWidget {
  final WorkerModel worker;
  const _PayPeriodDialog({required this.worker});

  @override
  State<_PayPeriodDialog> createState() => _PayPeriodDialogState();
}

class _PayPeriodDialogState extends State<_PayPeriodDialog> {
  late int _startDay;

  @override
  void initState() {
    super.initState();
    _startDay = widget.worker.payPeriodStartDay ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final endDay = _startDay == 1 ? '말일' : '${_startDay - 1}일';
    return AlertDialog(
      title: Text('${widget.worker.name}님 정산 기간'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('매월 정산 시작일'),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _startDay,
            isExpanded: true,
            items: List.generate(28, (i) => i + 1)
                .map((d) => DropdownMenuItem(value: d, child: Text('$d일')))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _startDay = v);
            },
          ),
          const SizedBox(height: 8),
          Text(
            _startDay == 1 ? '매월 1일 ~ 말일 (기본값)' : '매월 $_startDay일 ~ 다음달 $endDay',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _startDay),
          child: const Text('저장'),
        ),
      ],
    );
  }
}

Future<void> _showPaymentTypeDialog(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  WorkerModel worker,
) async {
  final paymentType = await showDialog<String>(
    context: context,
    builder: (_) => _PaymentTypeDialog(worker: worker),
  );
  if (paymentType == null || !context.mounted) return;

  await ref
      .read(memberManagementProvider.notifier)
      .updatePaymentType(workplaceId, worker.id, paymentType);

  if (!context.mounted) return;
  final result = ref.read(memberManagementProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('저장 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    ref.invalidate(workplaceWorkersProvider(workplaceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('정산 방식이 저장되었습니다.')),
    );
  }
}

// 직원별 정산 방식(시간/횟수) 다이얼로그. 기본값은 시간.
class _PaymentTypeDialog extends StatefulWidget {
  final WorkerModel worker;
  const _PaymentTypeDialog({required this.worker});

  @override
  State<_PaymentTypeDialog> createState() => _PaymentTypeDialogState();
}

class _PaymentTypeDialogState extends State<_PaymentTypeDialog> {
  late String _paymentType;

  @override
  void initState() {
    super.initState();
    _paymentType = widget.worker.paymentType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.worker.name}님 정산 방식'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: const Text('시간'),
            subtitle: const Text('시급 × 근무시간으로 정산'),
            value: 'TIME',
            groupValue: _paymentType,
            onChanged: (v) {
              if (v != null) setState(() => _paymentType = v);
            },
          ),
          RadioListTile<String>(
            title: const Text('횟수'),
            subtitle: const Text('근무 1건당 횟수로만 집계'),
            value: 'COUNT',
            groupValue: _paymentType,
            onChanged: (v) {
              if (v != null) setState(() => _paymentType = v);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _paymentType),
          child: const Text('저장'),
        ),
      ],
    );
  }
}

const List<String> _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

Future<void> _showWorkingDaysDialog(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  WorkerModel worker,
) async {
  final input = await showDialog<_WorkingDaysInput>(
    context: context,
    builder: (_) => _WorkingDaysDialog(worker: worker),
  );
  if (input == null || !context.mounted) return;

  await ref.read(memberManagementProvider.notifier).updateWorkingDays(
        workplaceId, worker.id, input.enabled, input.days.toList());

  if (!context.mounted) return;
  final result = ref.read(memberManagementProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('저장 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    ref.invalidate(workplaceWorkersProvider(workplaceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('요일 설정이 저장되었습니다.')),
    );
  }
}

class _WorkingDaysInput {
  final bool enabled; // true면 workingDays에 담긴 요일에만 활성, false면 "미설정"(선택된 요일이 없어 항상 비활성)
  final Set<int> days;
  const _WorkingDaysInput({required this.enabled, required this.days});
}

// 직원별 요일설정 다이얼로그. "미설정"을 켜면(요일 지정 안 함, 항상 비활성) 요일 버튼들이
// 비활성화되고, 끄면 요일 버튼을 개별적으로 토글할 수 있다.
// 1=월요일 ... 7=일요일(DateTime.weekday와 동일).
class _WorkingDaysDialog extends StatefulWidget {
  final WorkerModel worker;
  const _WorkingDaysDialog({required this.worker});

  @override
  State<_WorkingDaysDialog> createState() => _WorkingDaysDialogState();
}

class _WorkingDaysDialogState extends State<_WorkingDaysDialog> {
  late bool _unset; // "미설정" 버튼이 활성화된 상태인지
  late Set<int> _days;

  @override
  void initState() {
    super.initState();
    _unset = !widget.worker.workingDaysEnabled;
    _days = widget.worker.workingDays.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.worker.name}님 요일설정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('선택한 요일에만 이 직원을 활성으로 표시합니다. "미설정"이면 요일이 지정되지 않아 항상 비활성으로 표시됩니다.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          FilterChip(
            label: const Text('미설정'),
            selected: _unset,
            onSelected: (_) => setState(() => _unset = !_unset),
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(7, (i) {
              final day = i + 1; // 1=월 ... 7=일
              final selected = _days.contains(day);
              return FilterChip(
                label: Text(_weekdayLabels[i]),
                selected: selected,
                showCheckmark: false,
                selectedColor: AppColors.primary.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: _unset
                      ? AppColors.textSecondary.withValues(alpha: 0.4)
                      : (selected ? AppColors.primary : AppColors.textSecondary),
                ),
                onSelected: _unset
                    ? null
                    : (_) => setState(() {
                          if (selected) {
                            _days.remove(day);
                          } else {
                            _days.add(day);
                          }
                        }),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            _WorkingDaysInput(enabled: !_unset, days: _days),
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }
}

// 직원별 근무지 달력에서 쓰이는 마커 색상 설정 다이얼로그. 선택 즉시 기기 로컬에
// 저장되므로(WorkerColorOverrides), 별도의 저장 버튼 없이 탭하면 바로 반영된다.
void _showCalendarColorDialog(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  WorkerModel worker,
) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('${worker.name}님 달력색상'),
      content: Consumer(
        builder: (context, ref, _) {
          final overrides =
              ref.watch(workerColorOverridesProvider(workplaceId)).value ?? {};
          final currentIndex =
              overrides[worker.id] ?? defaultWorkerColorIndex(worker.id);
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(kWorkerColorPalette.length, (i) {
              final selected = i == currentIndex;
              return GestureDetector(
                onTap: () => ref
                    .read(workerColorOverridesProvider(workplaceId).notifier)
                    .setColorIndex(workplaceId, worker.id, i),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kWorkerColorPalette[i],
                    border: selected
                        ? Border.all(color: AppColors.textPrimary, width: 2)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}

// 다이얼로그는 입력값만 반환하고, 실제 API 호출은 (다이얼로그가 닫혀 사라진 뒤에도
// 계속 살아있는) 호출한 화면의 ref/context로 수행한다 — 그래야 dispose된 다이얼로그의
// ref를 쓰는 문제가 없다.
class _AddRecordInput {
  final int workerId;
  final DateTime clockIn;
  final DateTime clockOut;
  final double? recordCount;
  const _AddRecordInput({
    required this.workerId,
    required this.clockIn,
    required this.clockOut,
    this.recordCount,
  });
}

Future<void> _showAddRecordDialog(
  BuildContext context,
  WidgetRef ref,
  int workplaceId,
  DateTime? selectedDay,
) async {
  final date = selectedDay ?? DateTime.now();
  final input = await showDialog<_AddRecordInput>(
    context: context,
    builder: (_) => _AddRecordDialog(workplaceId: workplaceId, date: date),
  );
  if (input == null || !context.mounted) return;

  const fmt = 'yyyy-MM-ddTHH:mm';
  await ref.read(recordModifyProvider.notifier).add(
        workplaceId,
        input.workerId,
        DateFormat(fmt).format(input.clockIn),
        DateFormat(fmt).format(input.clockOut),
        input.recordCount,
      );

  if (!context.mounted) return;
  final result = ref.read(recordModifyProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('추가 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    // 지금 화면이 실제로 watch 중인 ref로 직접 다시 무효화해서 바로 반영되게 한다.
    ref.invalidate(workplaceRecordsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('추가되었습니다.')),
    );
  }
}

// 근로자 근무기록 추가 다이얼로그. 시/분 선택은 WorkerDetailScreen의 수정
// 다이얼로그와 같은 TimeRow를 공유한다. 입력만 받고 실제 API 호출은 안 한다.
class _AddRecordDialog extends ConsumerStatefulWidget {
  final int workplaceId;
  final DateTime date;

  const _AddRecordDialog({required this.workplaceId, required this.date});

  @override
  ConsumerState<_AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends ConsumerState<_AddRecordDialog> {
  int? _selectedWorkerId;
  String _selectedPaymentType = 'TIME';
  double _recordCount = 1.0;
  int _clockInHour = 18;
  int _clockInMinute = 0;
  int _clockOutHour = 22;
  int _clockOutMinute = 0;

  // 그 근로자의 개인 시간설정(default)이 있으면 그걸, 없으면 전역 기본값(18시~22시)을
  // 채운다. "현재시간"(TimeRow.currentTimeSentinel)으로 지정된 쪽은 실제 지금 시각으로
  // 채우되, 분은 근무지 분설정에서 활성화된 값 중 가장 가까운 값으로 맞춘다.
  void _applyWorkerDefaults(WorkerModel worker, List<int> enabledMinutes) {
    final now = DateTime.now();
    if (worker.defaultClockInHour == TimeRow.currentTimeSentinel) {
      final (h, m) = _nearestClockTime(now.hour, now.minute, enabledMinutes);
      _clockInHour = h;
      _clockInMinute = m;
    } else {
      _clockInHour = worker.defaultClockInHour ?? 18;
      _clockInMinute = worker.defaultClockInMinute ?? 0;
    }
    if (worker.defaultClockOutHour == TimeRow.currentTimeSentinel) {
      final (h, m) = _nearestClockTime(now.hour, now.minute, enabledMinutes);
      _clockOutHour = h;
      _clockOutMinute = m;
    } else {
      _clockOutHour = worker.defaultClockOutHour ?? 22;
      _clockOutMinute = worker.defaultClockOutMinute ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(workplaceWorkersProvider(widget.workplaceId));
    final workplaces = ref.watch(myWorkplacesProvider).value ?? [];
    final currentWorkplace =
        workplaces.where((w) => w.id == widget.workplaceId).firstOrNull;
    final disabledHours = currentWorkplace?.disabledHours ?? const <int>[];
    final enabledMinutes = currentWorkplace?.enabledMinutes ?? const <int>[0, 30];

    return AlertDialog(
      title: const Text('근무기록 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('yyyy-MM-dd (E)', 'ko_KR').format(widget.date),
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            workersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('오류: $e'),
              data: (rawWorkers) {
                if (rawWorkers.isEmpty) {
                  return const Text('아직 참가한 근로자가 없습니다.');
                }
                final workers = [...rawWorkers]
                  ..sort((a, b) =>
                      _compareWorkersForAddRecord(a, b, widget.date));
                if (_selectedWorkerId == null) {
                  _selectedWorkerId = workers.first.id;
                  _selectedPaymentType = workers.first.paymentType;
                  _applyWorkerDefaults(workers.first, enabledMinutes);
                }
                return DropdownButtonFormField<int>(
                  value: _selectedWorkerId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: '근로자'),
                  items: workers
                      .map((w) =>
                          DropdownMenuItem(value: w.id, child: Text(w.name)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    final worker = workers.firstWhere((w) => w.id == v);
                    setState(() {
                      _selectedWorkerId = v;
                      _selectedPaymentType = worker.paymentType;
                      _recordCount = 1.0;
                      _applyWorkerDefaults(worker, enabledMinutes);
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            if (_selectedPaymentType != 'COUNT') ...[
              TimeRow(
                label: '출근',
                hour: _clockInHour,
                minute: _clockInMinute,
                onHourChanged: (h) => setState(() => _clockInHour = h),
                onMinuteChanged: (m) => setState(() => _clockInMinute = m),
                disabledHours: disabledHours,
                enabledMinutes: enabledMinutes,
              ),
              const SizedBox(height: 12),
              TimeRow(
                label: '퇴근',
                hour: _clockOutHour,
                minute: _clockOutMinute,
                onHourChanged: (h) => setState(() => _clockOutHour = h),
                onMinuteChanged: (m) => setState(() => _clockOutMinute = m),
                disabledHours: disabledHours,
                enabledMinutes: enabledMinutes,
              ),
            ] else ...[
              const Text('횟수', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<double>(
                title: const Text('1회'),
                value: 1.0,
                groupValue: _recordCount,
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) {
                  if (v != null) setState(() => _recordCount = v);
                },
              ),
              RadioListTile<double>(
                title: const Text('0.5회'),
                value: 0.5,
                groupValue: _recordCount,
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) {
                  if (v != null) setState(() => _recordCount = v);
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _selectedWorkerId == null
              ? null
              : () {
                  final clockIn = DateTime(widget.date.year, widget.date.month,
                      widget.date.day, _clockInHour, _clockInMinute);
                  final clockOut = _selectedPaymentType == 'COUNT'
                      ? clockIn
                      : DateTime(widget.date.year, widget.date.month,
                          widget.date.day, _clockOutHour, _clockOutMinute);
                  Navigator.pop(
                    context,
                    _AddRecordInput(
                      workerId: _selectedWorkerId!,
                      clockIn: clockIn,
                      clockOut: clockOut,
                      recordCount:
                          _selectedPaymentType == 'COUNT' ? _recordCount : null,
                    ),
                  );
                },
          child: const Text('추가'),
        ),
      ],
    );
  }
}

// 근무지 전체 근무기록을 달력으로 보여주는 사장 홈 본문.
// 날짜를 선택하면 그날 일한 근로자별 내역을, 선택 안 했으면 이번 달 근로자별 요약을 보여준다.
// 근로자 행을 탭하면 그 근로자만의 달력(WorkerDetailScreen)으로 이동한다.
class _OwnerHomeBody extends ConsumerStatefulWidget {
  final WorkplaceModel workplace;
  const _OwnerHomeBody({required this.workplace});

  @override
  ConsumerState<_OwnerHomeBody> createState() => _OwnerHomeBodyState();
}

class _OwnerHomeBodyState extends ConsumerState<_OwnerHomeBody> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // 내역 목록을 스크롤/탭하면 달력을 週 단위로 줄여서 내역이 더 잘 보이게 하고,
  // 달력을 다시 탭하면(날짜 선택/페이지 이동) 원래 크기로 되돌린다.
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final param = (
      workplaceId: widget.workplace.id,
      year: _focusedDay.year,
      month: _focusedDay.month,
    );
    final recordsAsync = ref.watch(workplaceRecordsProvider(param));
    final colorOverrides = ref
            .watch(workerColorOverridesProvider(widget.workplace.id))
            .value ??
        {};

    return recordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
      data: (records) {
        final recordMap = _buildRecordMap(records);
        final selectedRecords = _selectedDay != null
            ? (recordMap[_normalizeDate(_selectedDay!)] ?? [])
            : <PayrollDetailModel>[];
        final monthTotal = records.fold(0, (s, r) => s + r.wageAmount);

        return Column(
          children: [
            _MonthSummaryBanner(totalWage: monthTotal),
            _buildCalendar(recordMap, colorOverrides),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    tooltip: '정산',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => context.push(
                      '/owner/settlement',
                      extra: {
                        'workplaceId': widget.workplace.id,
                        'workplaceName': widget.workplace.name,
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add, size: 18),
                    tooltip: '근무기록 추가',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _showAddRecordDialog(
                      context,
                      ref,
                      widget.workplace.id,
                      _selectedDay,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _collapseCalendar();
                  }
                  return false;
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _collapseCalendar,
                  child: _selectedDay != null && selectedRecords.isNotEmpty
                      ? _DayWorkerBreakdown(
                          records: selectedRecords,
                          workplaceId: widget.workplace.id,
                          year: _focusedDay.year,
                          month: _focusedDay.month,
                        )
                      : _WorkerSummaryList(
                          records: records,
                          workplaceId: widget.workplace.id,
                          year: _focusedDay.year,
                          month: _focusedDay.month,
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _collapseCalendar() {
    if (_calendarFormat != CalendarFormat.week) {
      setState(() => _calendarFormat = CalendarFormat.week);
    }
  }

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  Map<DateTime, List<PayrollDetailModel>> _buildRecordMap(
      List<PayrollDetailModel> records) {
    final map = <DateTime, List<PayrollDetailModel>>{};
    for (final r in records) {
      final date = _normalizeDate(DateTime.parse(r.clockIn));
      map.putIfAbsent(date, () => []).add(r);
    }
    return map;
  }

  Widget _buildCalendar(
    Map<DateTime, List<PayrollDetailModel>> recordMap,
    Map<int, int> colorOverrides,
  ) {
    return TableCalendar<PayrollDetailModel>(
      locale: 'ko_KR',
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: '월',
        CalendarFormat.week: '주',
      },
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (day) => recordMap[_normalizeDate(day)] ?? [],
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = isSameDay(_selectedDay, selected) ? null : selected;
          _focusedDay = focused;
          _calendarFormat = CalendarFormat.month;
        });
      },
      onPageChanged: (focused) {
        setState(() {
          _focusedDay = focused;
          _selectedDay = null;
          _calendarFormat = CalendarFormat.month;
        });
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final records = recordMap[_normalizeDate(day)] ?? [];
          if (records.isEmpty) return null;
          return _WorkDayCell(day: day, records: records, isSelected: false);
        },
        selectedBuilder: (context, day, focusedDay) {
          final records = recordMap[_normalizeDate(day)] ?? [];
          return _WorkDayCell(day: day, records: records, isSelected: true);
        },
        // 기본 마커(근무건수만큼 찍히는 검은 점)를 대신해서, 그날 일한 근로자별로
        // 색이 다른 점을 셀 맨 아래쪽에 찍는다. 금액/인원 텍스트와 안 겹치게 살짝 아래로 뺀다.
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          final workerIds = events.map((e) => e.workerId).toSet().toList();
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: workerIds.take(5).map((id) {
                  return Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorForWorker(id, colorOverrides),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 월 총 지출 배너
class _MonthSummaryBanner extends StatelessWidget {
  final int totalWage;
  const _MonthSummaryBanner({required this.totalWage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('이번 달 총 지출',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text(
            '${NumberFormat('#,###').format(totalWage)}원',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// 근무 있는 날의 달력 셀 (그날 전체 근로자 합산 지출 + 근무 인원)
class _WorkDayCell extends StatelessWidget {
  final DateTime day;
  final List<PayrollDetailModel> records;
  final bool isSelected;

  const _WorkDayCell({
    required this.day,
    required this.records,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final totalWage = records.fold(0, (s, r) => s + r.wageAmount);
    final workerCount = records.map((r) => r.workerId).toSet().length;
    final wageStr = NumberFormat('#,###').format(totalWage);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$wageStr원',
            style: TextStyle(
              fontSize: 8,
              color: isSelected ? Colors.white : AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$workerCount명',
            style: TextStyle(
              fontSize: 8,
              color: isSelected ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// 선택한 날짜에 일한 근로자별 내역 (탭하면 그 근로자 달력으로 이동)
class _DayWorkerBreakdown extends StatelessWidget {
  final List<PayrollDetailModel> records;
  final int workplaceId;
  final int year;
  final int month;

  const _DayWorkerBreakdown({
    required this.records,
    required this.workplaceId,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <int, List<PayrollDetailModel>>{};
    for (final r in records) {
      grouped.putIfAbsent(r.workerId, () => []).add(r);
    }
    final entries = grouped.entries.toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final workerId = entries[i].key;
        final workerRecords = entries[i].value;
        final workerName = workerRecords.first.workerName;
        final isCount = workerRecords.first.paymentType == 'COUNT';
        final wage = workerRecords.fold(0, (s, r) => s + r.wageAmount);
        final minutes = workerRecords.fold(0, (s, r) => s + r.workMinutes);
        final count = workerRecords.fold(0.0, (s, r) => s + r.recordCount);
        final h = minutes ~/ 60;
        final m = minutes % 60;

        return GestureDetector(
          onTap: () => context.push('/owner/worker-detail', extra: {
            'workplaceId': workplaceId,
            'workerId': workerId,
            'workerName': workerName,
            'year': year,
            'month': month,
          }),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      if (!isCount)
                        Text('${h}h ${m}m',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  isCount
                      ? _formatCount(count)
                      : '${NumberFormat('#,###').format(wage)}원',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 이번 달 근로자별 요약 (날짜 미선택 시 기본으로 보여줌, 탭하면 그 근로자 달력으로 이동)
class _WorkerSummaryList extends StatelessWidget {
  final List<PayrollDetailModel> records;
  final int workplaceId;
  final int year;
  final int month;

  const _WorkerSummaryList({
    required this.records,
    required this.workplaceId,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const _EmptyState();
    }

    final grouped = <int, List<PayrollDetailModel>>{};
    for (final r in records) {
      grouped.putIfAbsent(r.workerId, () => []).add(r);
    }
    final entries = grouped.entries.toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final workerId = entries[i].key;
        final workerRecords = entries[i].value;
        final workerName = workerRecords.first.workerName;
        final isCount = workerRecords.first.paymentType == 'COUNT';
        final totalWage = workerRecords.fold(0, (s, r) => s + r.wageAmount);
        final totalMinutes = workerRecords.fold(0, (s, r) => s + r.workMinutes);
        final totalCount = workerRecords.fold(0.0, (s, r) => s + r.recordCount);
        final workDays = workerRecords
            .map((r) {
              final d = DateTime.parse(r.clockIn);
              return DateTime(d.year, d.month, d.day);
            })
            .toSet()
            .length;
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;

        return GestureDetector(
          onTap: () => context.push('/owner/worker-detail', extra: {
            'workplaceId': workplaceId,
            'workerId': workerId,
            'workerName': workerName,
            'year': year,
            'month': month,
          }),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    workerName.substring(0, 1),
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        isCount
                            ? '$workDays일 · ${_formatCount(totalCount)}'
                            : '$workDays일 · ${hours}h ${minutes}m',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isCount
                          ? _formatCount(totalCount)
                          : '${NumberFormat('#,###').format(totalWage)}원',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right,
                        size: 18, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('이번 달 근무 기록이 없습니다.',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
