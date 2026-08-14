import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../workplace/presentation/workplace_provider.dart';
import '../domain/payroll_model.dart';
import 'payroll_provider.dart';
import 'time_row.dart';

// 특정 근로자 1명의 근무내역을 달력으로 보여주는 화면 (사장 전용).
// 날짜를 선택하면 그날의 근무기록을 보여주고, 사장은 기록을 수정할 수 있다.
class WorkerDetailScreen extends ConsumerStatefulWidget {
  final int workplaceId;
  final int workerId;
  final String workerName;
  final int year;
  final int month;

  const WorkerDetailScreen({
    super.key,
    required this.workplaceId,
    required this.workerId,
    required this.workerName,
    required this.year,
    required this.month,
  });

  @override
  ConsumerState<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends ConsumerState<WorkerDetailScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  // 상세 내역을 스크롤/탭하면 달력을 週 단위로 줄여서 내역이 더 잘 보이게 하고,
  // 달력을 다시 탭하면(날짜 선택/페이지 이동) 원래 크기로 되돌린다.
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(widget.year, widget.month);
  }

  @override
  Widget build(BuildContext context) {
    final param = (
      workplaceId: widget.workplaceId,
      workerId: widget.workerId,
      year: _focusedDay.year,
      month: _focusedDay.month,
    );
    final detailAsync = ref.watch(workerDetailProvider(param));

    return Scaffold(
      appBar: AppBar(title: Text('${widget.workerName} 근무내역')),
      body: detailAsync.when(
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
              _buildCalendar(recordMap),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.remove, size: 18),
                      tooltip: '근무기록 삭제',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _showDeleteRecordFlow(
                          context, ref, _selectedDay, selectedRecords),
                    ),
                  ],
                ),
              ),
              if (_selectedDay != null && selectedRecords.isNotEmpty)
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
                      child: _DayDetailPanel(
                        records: selectedRecords,
                        workplaceId: widget.workplaceId,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
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

  Widget _buildCalendar(Map<DateTime, List<PayrollDetailModel>> recordMap) {
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
      ),
    );
  }
}

String _fmtTime(String? iso) {
  if (iso == null) return '--:--';
  final dt = DateTime.parse(iso).toLocal();
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// 선택한 날짜의 근무기록 중 하나를 골라 삭제한다. 기록이 1개뿐이면 선택 창 없이 바로 확인만 받는다.
Future<void> _showDeleteRecordFlow(
  BuildContext context,
  WidgetRef ref,
  DateTime? selectedDay,
  List<PayrollDetailModel> dayRecords,
) async {
  // "삭제이력" placeholder는 실제 근무기록이 아니라 삭제할 대상이 없다.
  final deletable = dayRecords.where((r) => !r.deletionOnly).toList();
  if (selectedDay == null || deletable.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('삭제할 근무가 있는 날짜를 선택하세요.')),
    );
    return;
  }

  PayrollDetailModel target;
  if (deletable.length == 1) {
    target = deletable.first;
  } else {
    final picked = await showDialog<PayrollDetailModel>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('삭제할 근무 선택'),
        children: deletable.map((r) {
          final h = r.workMinutes ~/ 60;
          final m = r.workMinutes % 60;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, r),
            child: Text(
                '${_fmtTime(r.clockIn)} ~ ${_fmtTime(r.clockOut)} (${h}h ${m}m)'),
          );
        }).toList(),
      ),
    );
    if (picked == null || !context.mounted) return;
    target = picked;
  }

  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('근무기록 삭제'),
      content: Text(
          '${_fmtTime(target.clockIn)} ~ ${_fmtTime(target.clockOut)} 근무기록을 삭제하시겠습니까?'),
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

  await ref.read(recordModifyProvider.notifier).delete(target.id);

  if (!context.mounted) return;
  final result = ref.read(recordModifyProvider);
  if (result.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('삭제 실패: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  } else {
    // 지금 화면이 실제로 watch 중인 ref로 직접 다시 무효화해서 바로 반영되게 한다.
    ref.invalidate(workerDetailProvider);
    ref.invalidate(workplaceRecordsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('삭제되었습니다.')),
    );
  }
}

// 월 총 급여 배너
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
          const Text('이번 달 총 급여',
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

// 근무 있는 날의 달력 셀
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
    // 실제 근무기록이 하나도 없이 "삭제이력" placeholder만 있는 날은 근무 내용
    // 대신 삭제됨을 알리는 표시로 대체한다.
    final realRecords = records.where((r) => !r.deletionOnly).toList();
    final isDeletionOnly = realRecords.isEmpty && records.isNotEmpty;

    if (isDeletionOnly) {
      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.error
              : AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.error
                : AppColors.error.withValues(alpha: 0.3),
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
              '삭제됨',
              style: TextStyle(
                fontSize: 8,
                color: isSelected ? Colors.white : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final totalWage = realRecords.fold(0, (s, r) => s + r.wageAmount);
    final totalMinutes = realRecords.fold(0, (s, r) => s + r.workMinutes);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
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
            '${hours}h ${minutes}m',
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

// 선택된 날짜 상세 패널 (수정 가능)
class _DayDetailPanel extends ConsumerWidget {
  final List<PayrollDetailModel> records;
  final int workplaceId;

  const _DayDetailPanel({required this.records, required this.workplaceId});

  String _fmt(String? iso) {
    if (iso == null) return '--:--';
    final dt = DateTime.parse(iso).toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('근무 상세',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          // 하루에 기록이 많아도 스크롤로 아래까지 볼 수 있도록 ListView로 감싼다.
          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, i) {
                final r = records[i];
                if (r.deletionOnly) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 16, color: AppColors.error),
                        SizedBox(width: 6),
                        Text('삭제이력',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.error)),
                      ],
                    ),
                  );
                }
                final h = r.workMinutes ~/ 60;
                final m = r.workMinutes % 60;
                // "생성됨"은 금액 표시와 같은 파란색(primary), "수정됨"은 경고색으로
                // 구분한다. 삭제 이력은 이 기록에 태그를 붙이는 대신 같은 날짜 안에
                // 별도의 "삭제이력" 항목(deletionOnly)으로 온다.
                final tags = <(String, Color)>[];
                if (r.creationStatus == 'CREATED') {
                  tags.add(('생성됨', AppColors.primary));
                }
                if (r.creationStatus == 'MODIFIED') {
                  tags.add(('수정됨', AppColors.warning));
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${_fmt(r.clockIn)} ~ ${_fmt(r.clockOut)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                if (tags.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  for (var idx = 0; idx < tags.length; idx++) ...[
                                    if (idx > 0)
                                      const Text(' · ',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary)),
                                    Text(tags[idx].$1,
                                        style: TextStyle(
                                            fontSize: 11, color: tags[idx].$2)),
                                  ],
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${h}h ${m}m',
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${NumberFormat('#,###').format(r.wageAmount)}원',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () =>
                                _showModifyDialog(context, ref, r, workplaceId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('수정',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.primary)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 이미 날짜(달력에서 클릭한 그 날) 안에서 여는 다이얼로그이므로 날짜는 그대로 두고
  // 시(0~23)/분(0 또는 30)만 선택하게 한다.
  Future<void> _showModifyDialog(BuildContext context, WidgetRef ref,
      PayrollDetailModel record, int workplaceId) async {
    final clockInDt = DateTime.parse(record.clockIn);
    final clockOutDt =
        record.clockOut != null ? DateTime.parse(record.clockOut!) : clockInDt;

    int clockInHour = clockInDt.hour;
    int clockInMinute = clockInDt.minute >= 15 ? 30 : 0;
    int clockOutHour = clockOutDt.hour;
    int clockOutMinute = clockOutDt.minute >= 15 ? 30 : 0;

    final workplaces = ref.read(myWorkplacesProvider).value ?? [];
    final currentWorkplace =
        workplaces.where((w) => w.id == workplaceId).firstOrNull;
    final disabledHours = currentWorkplace?.disabledHours ?? const <int>[];
    final enabledMinutes = currentWorkplace?.enabledMinutes ?? const <int>[0, 30];

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('근무시간 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TimeRow(
                label: '출근',
                hour: clockInHour,
                minute: clockInMinute,
                onHourChanged: (h) => setState(() => clockInHour = h),
                onMinuteChanged: (m) => setState(() => clockInMinute = m),
                disabledHours: disabledHours,
                enabledMinutes: enabledMinutes,
              ),
              const SizedBox(height: 12),
              TimeRow(
                label: '퇴근',
                hour: clockOutHour,
                minute: clockOutMinute,
                onHourChanged: (h) => setState(() => clockOutHour = h),
                onMinuteChanged: (m) => setState(() => clockOutMinute = m),
                disabledHours: disabledHours,
                enabledMinutes: enabledMinutes,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final newClockIn = DateTime(clockInDt.year, clockInDt.month,
                    clockInDt.day, clockInHour, clockInMinute);
                final newClockOut = DateTime(clockOutDt.year, clockOutDt.month,
                    clockOutDt.day, clockOutHour, clockOutMinute);
                const fmt = 'yyyy-MM-ddTHH:mm';
                await ref.read(recordModifyProvider.notifier).modify(
                      record.id,
                      DateFormat(fmt).format(newClockIn),
                      DateFormat(fmt).format(newClockOut),
                    );
                if (!context.mounted) return;
                final result = ref.read(recordModifyProvider);
                if (result.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('수정 실패: ${result.error}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('수정되었습니다.')),
                  );
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
