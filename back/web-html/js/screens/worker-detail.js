import { payrollApi } from '../apis/payroll-api.js';
import { workplaceApi } from '../apis/workplace-api.js';
import { openModal } from '../components/modal.js';
import { renderTimeRow } from '../components/time-row.js';
import {
  el,
  formatCurrency,
  formatTime,
  dateKey,
  minutesToHm,
  WEEKDAY_LABELS,
  monthLabel,
  toast,
} from '../utils.js';

export async function renderWorkerDetail(root, params) {
  const workplaceId = Number(params.get('workplaceId'));
  const workerId = Number(params.get('workerId'));
  const workerName = params.get('workerName') || '';
  const year = Number(params.get('year'));
  const month = Number(params.get('month'));

  const header = el('div', { class: 'app-bar' }, [
    el('button', { class: 'icon-btn', onclick: () => window.history.back() }, '←'),
    el('div', { class: 'app-bar__title' }, `${workerName} 근무내역`),
  ]);
  const body = el('div', { class: 'page' }, [el('div', { class: 'loading' }, '불러오는 중...')]);
  root.replaceChildren(el('div', { class: 'screen' }, [header, body]));

  let disabledHours = [];
  let enabledMinutes = [0, 30];
  try {
    const workplaces = await workplaceApi.getMyWorkplaces();
    const wp = workplaces.find((w) => w.id === workplaceId);
    disabledHours = wp?.disabledHours || [];
    enabledMinutes = wp?.enabledMinutes || [0, 30];
  } catch {
    // 시간설정을 못 불러와도 수정 다이얼로그는 기본값(전체 허용)으로 계속 쓸 수 있다.
  }

  const view = { workplaceId, workerId, workerName, year, month, selectedKey: null, disabledHours, enabledMinutes };
  await load(body, view);
}

async function load(body, view) {
  let records;
  try {
    records = await payrollApi.getWorkerDetail(view.workplaceId, view.workerId, view.year, view.month);
  } catch (e) {
    body.replaceChildren(el('p', { class: 'error-text' }, `오류: ${e.message}`));
    return;
  }
  render(body, view, records);
}

function render(body, view, records) {
  const recordMap = {};
  for (const r of records) {
    const key = dateKey(new Date(r.clockIn));
    (recordMap[key] ||= []).push(r);
  }
  const realRecords = records.filter((r) => !r.deletionOnly);
  const monthTotal = realRecords.reduce((s, r) => s + (r.wageAmount || 0), 0);

  const banner = el('div', { class: 'month-banner' }, [
    el('span', {}, '이번 달 총 급여'),
    el('span', { class: 'month-banner__amount' }, formatCurrency(monthTotal)),
  ]);

  const nav = el('div', { class: 'calendar-nav' }, [
    el('button', { class: 'btn btn--ghost', onclick: () => changeMonth(body, view, -1) }, '‹'),
    el('div', { class: 'calendar-nav__label' }, monthLabel(view.year, view.month)),
    el('button', { class: 'btn btn--ghost', onclick: () => changeMonth(body, view, 1) }, '›'),
  ]);

  const grid = buildGrid(view, recordMap, (key) => {
    view.selectedKey = view.selectedKey === key ? null : key;
    render(body, view, records);
  });

  const selectedRecords = view.selectedKey ? recordMap[view.selectedKey] || [] : [];

  const actionRow = el('div', { class: 'calendar-action-row' }, [
    el(
      'button',
      { class: 'btn btn--chip', onclick: () => startDeleteFlow(body, view, records, selectedRecords) },
      '➖ 근무기록 삭제',
    ),
  ]);

  const children = [banner, nav, grid, actionRow];
  if (view.selectedKey && selectedRecords.length) {
    children.push(renderDayDetail(body, view, records, selectedRecords));
  }

  body.replaceChildren(el('div', { class: 'page' }, children));
}

function changeMonth(body, view, delta) {
  let m = view.month + delta;
  let y = view.year;
  if (m < 1) { m = 12; y -= 1; }
  if (m > 12) { m = 1; y += 1; }
  view.year = y;
  view.month = m;
  view.selectedKey = null;
  body.replaceChildren(el('div', { class: 'loading' }, '불러오는 중...'));
  load(body, view);
}

function buildGrid(view, recordMap, onSelect) {
  const first = new Date(view.year, view.month - 1, 1);
  const daysInMonth = new Date(view.year, view.month, 0).getDate();
  const startWeekday = first.getDay();

  const cells = [];
  for (let i = 0; i < startWeekday; i++) cells.push(el('div', { class: 'day-cell day-cell--empty' }));

  for (let d = 1; d <= daysInMonth; d++) {
    const key = dateKey(new Date(view.year, view.month - 1, d));
    const dayRecords = recordMap[key] || [];
    const realRecords = dayRecords.filter((r) => !r.deletionOnly);
    const isDeletionOnly = dayRecords.length > 0 && realRecords.length === 0;
    const isSelected = view.selectedKey === key;
    const isToday = key === dateKey(new Date());

    const cellChildren = [el('div', { class: 'day-cell__num' }, String(d))];
    let extraClass = '';
    if (isDeletionOnly) {
      extraClass = 'day-cell--deleted';
      cellChildren.push(el('div', { class: 'day-cell__wage day-cell__wage--danger' }, '삭제됨'));
    } else if (realRecords.length > 0) {
      extraClass = 'day-cell--has-record';
      const totalWage = realRecords.reduce((s, r) => s + (r.wageAmount || 0), 0);
      const totalMinutes = realRecords.reduce((s, r) => s + (r.workMinutes || 0), 0);
      const { h, m } = minutesToHm(totalMinutes);
      cellChildren.push(el('div', { class: 'day-cell__wage' }, formatCurrency(totalWage)));
      cellChildren.push(el('div', { class: 'day-cell__hours' }, `${h}h ${m}m`));
    }

    cells.push(
      el(
        'button',
        {
          class: `day-cell ${extraClass} ${isSelected ? 'day-cell--selected' : ''} ${isToday ? 'day-cell--today' : ''}`,
          onclick: () => onSelect(key),
        },
        cellChildren,
      ),
    );
  }

  return el('div', { class: 'calendar' }, [
    el('div', { class: 'calendar__weekdays' }, WEEKDAY_LABELS.map((w) => el('div', { class: 'calendar__weekday' }, w))),
    el('div', { class: 'calendar__grid' }, cells),
  ]);
}

function renderDayDetail(body, view, allRecords, dayRecords) {
  return el(
    'div',
    { class: 'card day-detail' },
    [el('h3', {}, '근무 상세'), ...dayRecords.map((r) => renderRecordRow(body, view, allRecords, r))],
  );
}

function renderRecordRow(body, view, allRecords, record) {
  if (record.deletionOnly) {
    return el('div', { class: 'record-row record-row--deleted' }, '🗑️ 삭제이력');
  }

  const { h, m } = minutesToHm(record.workMinutes);
  const tags = [];
  if (record.creationStatus === 'CREATED') tags.push(['생성됨', 'tag--primary']);
  if (record.creationStatus === 'MODIFIED') tags.push(['수정됨', 'tag--warning']);

  return el('div', { class: 'record-row' }, [
    el('div', { class: 'record-row__main' }, [
      el('div', { class: 'record-row__time-line' }, [
        el('span', { class: 'record-row__time' }, `${formatTime(record.clockIn)} ~ ${formatTime(record.clockOut)}`),
        ...tags.map(([text, cls]) => el('span', { class: `tag ${cls}` }, text)),
      ]),
      el('div', { class: 'record-row__hours' }, `${h}h ${m}m`),
    ]),
    el('div', { class: 'record-row__amounts' }, [
      el('div', { class: 'record-row__wage' }, formatCurrency(record.wageAmount)),
      el(
        'button',
        { class: 'btn btn--chip-sm', onclick: () => openModifyDialog(body, view, allRecords, record) },
        '수정',
      ),
    ]),
  ]);
}

function openModifyDialog(body, view, allRecords, record) {
  const clockInDt = new Date(record.clockIn);
  const clockOutDt = record.clockOut ? new Date(record.clockOut) : clockInDt;

  const timeState = {
    clockInHour: clockInDt.getHours(),
    clockInMinute: clockInDt.getMinutes() >= 15 ? 30 : 0,
    clockOutHour: clockOutDt.getHours(),
    clockOutMinute: clockOutDt.getMinutes() >= 15 ? 30 : 0,
  };

  openModal({
    title: '근무시간 수정',
    render: ({ body: modalBody, footer, close }) => {
      const rowsHost = el('div', { class: 'time-rows' });
      function renderRows() {
        rowsHost.replaceChildren(
          renderTimeRow({
            label: '출근',
            hour: timeState.clockInHour,
            minute: timeState.clockInMinute,
            disabledHours: view.disabledHours,
            enabledMinutes: view.enabledMinutes,
            onHourChange: (v) => { timeState.clockInHour = v; renderRows(); },
            onMinuteChange: (v) => { timeState.clockInMinute = v; renderRows(); },
          }),
          renderTimeRow({
            label: '퇴근',
            hour: timeState.clockOutHour,
            minute: timeState.clockOutMinute,
            disabledHours: view.disabledHours,
            enabledMinutes: view.enabledMinutes,
            onHourChange: (v) => { timeState.clockOutHour = v; renderRows(); },
            onMinuteChange: (v) => { timeState.clockOutMinute = v; renderRows(); },
          }),
        );
      }
      renderRows();
      modalBody.append(rowsHost);

      footer.append(
        el('button', { class: 'btn btn--ghost', onclick: close }, '취소'),
        el('button', {
          class: 'btn btn--primary',
          onclick: async () => {
            close();
            const pad = (n) => String(n).padStart(2, '0');
            const dateStr = (d) => `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
            const newClockIn = `${dateStr(clockInDt)}T${pad(timeState.clockInHour)}:${pad(timeState.clockInMinute)}`;
            const newClockOut = `${dateStr(clockOutDt)}T${pad(timeState.clockOutHour)}:${pad(timeState.clockOutMinute)}`;
            try {
              await payrollApi.modifyRecord(record.id, newClockIn, newClockOut);
              toast('수정되었습니다.', 'success');
              load(body, view);
            } catch (e) {
              toast(`수정 실패: ${e.message}`, 'error');
            }
          },
        }, '저장'),
      );
    },
  });
}

async function startDeleteFlow(body, view, allRecords, dayRecords) {
  const deletable = dayRecords.filter((r) => !r.deletionOnly);
  if (!view.selectedKey || deletable.length === 0) {
    toast('삭제할 근무가 있는 날짜를 선택하세요.', 'error');
    return;
  }

  let target;
  if (deletable.length === 1) {
    target = deletable[0];
  } else {
    const labels = deletable.map((r, i) => {
      const { h, m } = minutesToHm(r.workMinutes);
      return `${i + 1}. ${formatTime(r.clockIn)} ~ ${formatTime(r.clockOut)} (${h}h ${m}m)`;
    });
    const answer = window.prompt(`삭제할 근무를 선택하세요\n${labels.join('\n')}`, '1');
    if (!answer) return;
    const idx = Number(answer.trim()) - 1;
    if (Number.isNaN(idx) || idx < 0 || idx >= deletable.length) return;
    target = deletable[idx];
  }

  if (!window.confirm(`${formatTime(target.clockIn)} ~ ${formatTime(target.clockOut)} 근무기록을 삭제하시겠습니까?`)) return;

  try {
    await payrollApi.deleteRecord(target.id);
    toast('삭제되었습니다.', 'success');
    load(body, view);
  } catch (e) {
    toast(`삭제 실패: ${e.message}`, 'error');
  }
}
