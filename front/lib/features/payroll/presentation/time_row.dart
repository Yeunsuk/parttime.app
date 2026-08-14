import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// 시(0~23, 근무지 시간설정에서 비활성화된 시간은 목록에서 제외)/분(근무지 분설정에서
// 활성화된 분만, 기본 0·30) 선택 행. 근무기록 수정(WorkerDetailScreen)과 추가
// (OwnerHomeScreen) 다이얼로그가 공용으로 쓴다.
//
// allowCurrentTimeOption이 true면(직원별 "시간설정"의 기본시간 지정에서만 사용) 시(hour)
// 목록 맨 앞에 "현재시간"이라는 특수 옵션이 추가된다. 이 값(currentTimeSentinel, -1)이
// 저장되면 고정된 시각이 아니라 "실제 쓰이는 시점의 현재 시각"으로 해석된다.
class TimeRow extends StatelessWidget {
  static const int currentTimeSentinel = -1;

  final String label;
  final int hour;
  final int minute;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final List<int> disabledHours;
  final List<int> enabledMinutes;
  final bool allowCurrentTimeOption;

  const TimeRow({
    super.key,
    required this.label,
    required this.hour,
    required this.minute,
    required this.onHourChanged,
    required this.onMinuteChanged,
    this.disabledHours = const [],
    this.enabledMinutes = const [0, 30],
    this.allowCurrentTimeOption = false,
  });

  @override
  Widget build(BuildContext context) {
    // 이미 선택된(예: 기존 기록의) 값이 나중에 비활성화되었더라도 선택 UI가
    // 깨지지 않도록, 현재 값은 목록에서 빠지지 않게 다시 넣어준다.
    final availableHours =
        List.generate(24, (h) => h).where((h) => !disabledHours.contains(h)).toList();
    // "현재시간"은 근무지 "시간설정" 목록에도 함께 들어있는 항목이라, 거기서
    // 비활성화되지 않은 경우에만 이 선택지로 나타난다.
    if (allowCurrentTimeOption && !disabledHours.contains(currentTimeSentinel)) {
      availableHours.add(currentTimeSentinel);
    }
    if (!availableHours.contains(hour)) {
      availableHours.add(hour);
    }
    availableHours.sort();

    final availableMinutes = [...enabledMinutes]..sort();
    if (!availableMinutes.contains(minute)) {
      availableMinutes.add(minute);
      availableMinutes.sort();
    }

    final isCurrentTime = allowCurrentTimeOption && hour == currentTimeSentinel;

    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NumberPicker(
            value: hour,
            options: availableHours,
            suffix: '시',
            onChanged: onHourChanged,
            formatOption: allowCurrentTimeOption
                ? (o) => o == currentTimeSentinel ? '현재시간' : '$o시'
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: isCurrentTime
              ? const InputDecorator(
                  decoration: InputDecoration(isDense: true),
                  child: Text('현재시간',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : _NumberPicker(
                  value: minute,
                  options: availableMinutes,
                  suffix: '분',
                  onChanged: onMinuteChanged,
                ),
        ),
      ],
    );
  }
}

// 선택 가능한 값이 1개면 선택 UI 없이 그 값 하나로 고정, 2개면 탭할 때마다 서로
// 바뀌는 토글, 3개 이상이면 드롭다운 목록으로 보여준다.
class _NumberPicker extends StatelessWidget {
  final int value;
  final List<int> options;
  final String suffix;
  final ValueChanged<int> onChanged;
  final String Function(int)? formatOption;

  const _NumberPicker({
    required this.value,
    required this.options,
    required this.suffix,
    required this.onChanged,
    this.formatOption,
  });

  String _format(int o) => formatOption != null ? formatOption!(o) : '$o$suffix';

  @override
  Widget build(BuildContext context) {
    if (options.length <= 1) {
      final fixed = options.isNotEmpty ? options.first : value;
      if (fixed != value) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onChanged(fixed));
      }
      return InputDecorator(
        decoration: const InputDecoration(isDense: true),
        child: Text(_format(fixed)),
      );
    }

    if (options.length == 2) {
      return InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          final other = options.firstWhere((o) => o != value, orElse: () => options.first);
          onChanged(other);
        },
        child: InputDecorator(
          decoration: const InputDecoration(isDense: true),
          child: Text(_format(value)),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(isDense: true),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(_format(o))))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
