import { workRecordApi } from '../apis/work-record-api.js';
import { el, formatCurrency, formatTime, dateKey, minutesToHm, WEEKDAY_LABELS, monthLabel } from '../utils.js';

export async function renderWorkerCalendar(root) {
  const header = el('div', { class: 'app-bar' }, [
    el('button', { class: 'icon-btn', onclick: () => window.history.back() }, '←'),
    el('div', { class: 'app-bar__title' }, '근무 달력'),
  ]);
  const body = el('div', { class: 'page' }, [el('div', { class: 'loading' }, '불러오는 중...')]);
  root.replaceChildren(el('div', { class: 'screen' }, [header, body]));

  const now = new Date();
  const view = { year: now.getFullYear(), month: now.getMonth() + 1, selectedKey: null };
  await load(body, view);
}

async function load(body, view) {
  let records;
  try {
    records = await workRecordApi.getCalendar(view.year, view.month);
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
  const monthTotal = records.reduce((s, r) => s + (r.wageAmount || 0), 0);

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

  const children = [banner, nav, grid];
  if (view.selectedKey && recordMap[view.selectedKey]?.length) {
    children.push(renderDayDetail(recordMap[view.selectedKey]));
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
    const isSelected = view.selectedKey === key;
    const isToday = key === dateKey(new Date());

    const cellChildren = [el('div', { class: 'day-cell__num' }, String(d))];
    if (dayRecords.length > 0) {
      const totalWage = dayRecords.reduce((s, r) => s + (r.wageAmount || 0), 0);
      const totalMinutes = dayRecords.reduce((s, r) => s + (r.workMinutes || 0), 0);
      const { h, m } = minutesToHm(totalMinutes);
      cellChildren.push(el('div', { class: 'day-cell__wage' }, formatCurrency(totalWage)));
      cellChildren.push(el('div', { class: 'day-cell__hours' }, `${h}h ${m}m`));
    }

    cells.push(
      el(
        'button',
        {
          class: `day-cell ${dayRecords.length ? 'day-cell--has-record' : ''} ${isSelected ? 'day-cell--selected' : ''} ${isToday ? 'day-cell--today' : ''}`,
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

function renderDayDetail(records) {
  return el('div', { class: 'card day-detail' }, [
    el('h3', {}, '근무 상세'),
    ...records.map((r) => renderRecordRow(r)),
  ]);
}

function renderRecordRow(record) {
  const wage = formatCurrency(record.wageAmount);
  const { h, m } = minutesToHm(record.workMinutes);

  const tags = [];
  if (record.creationStatus === 'CREATED') tags.push(['생성됨', 'tag--primary']);
  if (record.creationStatus === 'MODIFIED') tags.push(['수정됨', 'tag--warning']);
  if (record.deletedSameDay) tags.push(['삭제됨', 'tag--warning']);

  return el('div', { class: 'record-row' }, [
    el('div', { class: 'record-row__main' }, [
      el('div', { class: 'record-row__workplace' }, record.workplaceName),
      el('div', { class: 'record-row__time-line' }, [
        el('span', { class: 'record-row__time' }, `${formatTime(record.clockIn)} ~ ${formatTime(record.clockOut)}`),
        ...tags.map(([text, cls]) => el('span', { class: `tag ${cls}` }, text)),
      ]),
    ]),
    el('div', { class: 'record-row__amounts' }, [
      el('div', { class: 'record-row__wage' }, wage),
      el('div', { class: 'record-row__hours' }, `${h}h ${m}m`),
    ]),
  ]);
}
