import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/work_record_model.dart';
import 'work_record_provider.dart';

class WorkerCalendarScreen extends ConsumerStatefulWidget {
  const WorkerCalendarScreen({super.key});

  @override
  ConsumerState<WorkerCalendarScreen> createState() => _WorkerCalendarScreenState();
}

class _WorkerCalendarScreenState extends ConsumerState<WorkerCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(
      calendarProvider((year: _focusedDay.year, month: _focusedDay.month)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('근무 달력')),
      body: calendarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (records) {
          final recordMap = _buildRecordMap(records);
          final selectedRecords = _selectedDay != null
              ? (recordMap[_normalizeDate(_selectedDay!)] ?? [])
              : [];
          final monthTotal = _calcMonthTotal(records);

          return Column(
            children: [
              _MonthSummaryBanner(totalWage: monthTotal),
              _buildCalendar(recordMap),
              if (_selectedDay != null && selectedRecords.isNotEmpty)
                _DayDetailPanel(records: selectedRecords.cast<WorkRecordModel>(),),
            ],
          );
        },
      ),
    );
  }

  // 날짜 정규화 (시분초 제거)
  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  // 근무기록을 날짜별 Map으로 변환
  Map<DateTime, List<WorkRecordModel>> _buildRecordMap(List<WorkRecordModel> records) {
    final map = <DateTime, List<WorkRecordModel>>{};
    for (final r in records) {
      final date = _normalizeDate(DateTime.parse(r.clockIn));
      map.putIfAbsent(date, () => []).add(r);
    }
    return map;
  }

  int _calcMonthTotal(List<WorkRecordModel> records) =>
      records.fold(0, (sum, r) => sum + (r.wageAmount ?? 0));

  Widget _buildCalendar(Map<DateTime, List<WorkRecordModel>> recordMap) {
    return TableCalendar<WorkRecordModel>(
      locale: 'ko_KR',
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (day) => recordMap[_normalizeDate(day)] ?? [],
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      onPageChanged: (focused) {
        setState(() => _focusedDay = focused);
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
        markerDecoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        // 날짜 셀 빌더는 calendarBuilders로 처리
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
        // 날짜 셀에 금액 + 시간 표시
        defaultBuilder: (context, day, focusedDay) {
          final records = recordMap[_normalizeDate(day)] ?? [];
          if (records.isEmpty) return null; // 기본 렌더링
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

// 근무 있는 날의 달력 셀
class _WorkDayCell extends StatelessWidget {
  final DateTime day;
  final List<WorkRecordModel> records;
  final bool isSelected;

  const _WorkDayCell({
    required this.day,
    required this.records,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final totalWage = records.fold(0, (s, r) => s + (r.wageAmount ?? 0));
    final totalMinutes = records.fold(0, (s, r) => s + (r.workMinutes ?? 0));
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
          color: isSelected ? AppColors.primary : AppColors.success.withValues(alpha: 0.3),
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

// 월 총액 배너 (우측 상단)
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
          const Text(
            '이번 달 총 급여',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
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

// 선택된 날짜 상세 패널
class _DayDetailPanel extends StatelessWidget {
  final List<WorkRecordModel> records;

  const _DayDetailPanel({required this.records});

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '--:--';
    final dt = DateTime.parse(isoTime).toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
          ...records.map((r) => _RecordRow(record: r, formatTime: _formatTime)),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final WorkRecordModel record;
  final String Function(String?) formatTime;

  const _RecordRow({required this.record, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    final wage = NumberFormat('#,###').format(record.wageAmount ?? 0);
    final minutes = record.workMinutes ?? 0;
    final h = minutes ~/ 60;
    final m = minutes % 60;

    // "생성됨"은 금액 표시와 같은 파란색(primary), 나머지는 경고색으로 구분한다.
    final tags = <(String, Color)>[];
    if (record.creationStatus == 'CREATED') tags.add(('생성됨', AppColors.primary));
    if (record.creationStatus == 'MODIFIED') tags.add(('수정됨', AppColors.warning));
    if (record.deletedSameDay) tags.add(('삭제됨', AppColors.warning));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.workplaceName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${formatTime(record.clockIn)} ~ ${formatTime(record.clockOut)}',
                      style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      for (var idx = 0; idx < tags.length; idx++) ...[
                        if (idx > 0)
                          const Text(' · ',
                            style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                        Text(tags[idx].$1,
                          style: TextStyle(
                            fontSize: 12, color: tags[idx].$2)),
                      ],
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$wage원',
                style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text('${h}h ${m}m',
                style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
