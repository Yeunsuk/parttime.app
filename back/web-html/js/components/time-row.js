import { CURRENT_TIME_SENTINEL } from '../config.js';
import { el } from '../utils.js';

// Flutter TimeRow/_NumberPicker와 동일한 규칙:
// 옵션 1개면 고정 표시, 2개면 탭할 때마다 서로 바뀌는 토글, 3개 이상이면 드롭다운.
function renderNumberPicker({ value, options, suffix, onChange, formatOption }) {
  const format = formatOption || ((o) => `${o}${suffix}`);
  const wrapper = el('div', { class: 'number-picker' });

  if (options.length <= 1) {
    const fixed = options.length > 0 ? options[0] : value;
    if (fixed !== value) {
      // 렌더 도중 상태를 바꾸지 않도록 다음 tick에 반영한다.
      setTimeout(() => onChange(fixed), 0);
    }
    wrapper.append(el('div', { class: 'number-picker__fixed' }, format(fixed)));
    return wrapper;
  }

  if (options.length === 2) {
    const btn = el(
      'button',
      {
        type: 'button',
        class: 'number-picker__toggle',
        onclick: () => {
          const other = options.find((o) => o !== value) ?? options[0];
          onChange(other);
        },
      },
      format(value),
    );
    wrapper.append(btn);
    return wrapper;
  }

  const select = el(
    'select',
    { class: 'number-picker__select', onchange: (e) => onChange(Number(e.target.value)) },
    options.map((o) => el('option', { value: o, selected: o === value ? '' : undefined }, format(o))),
  );
  wrapper.append(select);
  return wrapper;
}

// allowCurrentTimeOption이 true면 시(hour) 목록에 "현재시간"(-1) 옵션을(근무지 disabledHours에서
// 비활성화되지 않은 경우) 추가한다 — 직원별 "시간설정"에서만 쓴다.
export function renderTimeRow({
  label,
  hour,
  minute,
  onHourChange,
  onMinuteChange,
  disabledHours = [],
  enabledMinutes = [0, 30],
  allowCurrentTimeOption = false,
}) {
  const availableHours = [];
  for (let h = 0; h < 24; h++) {
    if (!disabledHours.includes(h)) availableHours.push(h);
  }
  if (allowCurrentTimeOption && !disabledHours.includes(CURRENT_TIME_SENTINEL)) {
    availableHours.push(CURRENT_TIME_SENTINEL);
  }
  if (!availableHours.includes(hour)) {
    availableHours.push(hour);
  }
  availableHours.sort((a, b) => a - b);

  const availableMinutes = [...enabledMinutes].sort((a, b) => a - b);
  if (!availableMinutes.includes(minute)) {
    availableMinutes.push(minute);
    availableMinutes.sort((a, b) => a - b);
  }

  const isCurrentTime = allowCurrentTimeOption && hour === CURRENT_TIME_SENTINEL;

  const hourPicker = renderNumberPicker({
    value: hour,
    options: availableHours,
    suffix: '시',
    onChange: onHourChange,
    formatOption: allowCurrentTimeOption
      ? (o) => (o === CURRENT_TIME_SENTINEL ? '현재시간' : `${o}시`)
      : undefined,
  });

  const minutePicker = isCurrentTime
    ? el('div', { class: 'number-picker' }, [
        el('div', { class: 'number-picker__fixed number-picker__fixed--muted' }, '현재시간'),
      ])
    : renderNumberPicker({ value: minute, options: availableMinutes, suffix: '분', onChange: onMinuteChange });

  return el('div', { class: 'time-row' }, [el('div', { class: 'time-row__label' }, label), hourPicker, minutePicker]);
}
