import { payrollApi } from '../apis/payroll-api.js';
import { el, formatCurrency, formatCount, minutesToHm, monthLabel } from '../utils.js';

export async function renderSettlement(root, params) {
  const workplaceId = Number(params.get('workplaceId'));
  const workplaceName = params.get('workplaceName') || '';

  const header = el('div', { class: 'app-bar' }, [
    el('button', { class: 'icon-btn', onclick: () => window.history.back() }, '←'),
    el('div', { class: 'app-bar__title' }, `${workplaceName} 정산`),
  ]);
  const body = el('div', { class: 'page' }, [el('div', { class: 'loading' }, '불러오는 중...')]);
  root.replaceChildren(el('div', { class: 'screen' }, [header, body]));

  const now = new Date();
  const view = { year: now.getFullYear(), month: now.getMonth() + 1 };
  await load(body, workplaceId, workplaceName, view);
}

async function load(body, workplaceId, workplaceName, view) {
  let rows;
  try {
    rows = await payrollApi.getSettlement(workplaceId, view.year, view.month);
  } catch (e) {
    body.replaceChildren(el('p', { class: 'error-text' }, `오류: ${e.message}`));
    return;
  }
  render(body, workplaceId, workplaceName, view, rows);
}

function render(body, workplaceId, workplaceName, view, rows) {
  const nav = el('div', { class: 'calendar-nav' }, [
    el('button', { class: 'btn btn--ghost', onclick: () => changeMonth(body, workplaceId, workplaceName, view, -1) }, '‹'),
    el('div', { class: 'calendar-nav__label' }, monthLabel(view.year, view.month)),
    el('button', { class: 'btn btn--ghost', onclick: () => changeMonth(body, workplaceId, workplaceName, view, 1) }, '›'),
  ]);

  const actionRow = el('div', { class: 'calendar-action-row' }, [
    el(
      'button',
      {
        class: 'btn btn--chip',
        disabled: rows.length === 0,
        onclick: async (e) => {
          const btn = e.currentTarget;
          const originalText = btn.textContent;
          btn.disabled = true;
          btn.textContent = '캡처 중...';
          try {
            await captureSettlementToPng(workplaceName, view, rows);
          } catch (err) {
            alert(`캡처 실패: ${err.message}`);
          } finally {
            btn.disabled = false;
            btn.textContent = originalText;
          }
        },
      },
      '📸 캡처',
    ),
  ]);

  const list =
    rows.length === 0
      ? el('div', { class: 'empty-state' }, '소속된 직원이 없습니다.')
      : el('div', { class: 'card-list' }, rows.map((r) => renderRow(r)));

  body.replaceChildren(el('div', { class: 'page' }, [nav, actionRow, list]));
}

function changeMonth(body, workplaceId, workplaceName, view, delta) {
  let m = view.month + delta;
  let y = view.year;
  if (m < 1) { m = 12; y -= 1; }
  if (m > 12) { m = 1; y += 1; }
  view.year = y;
  view.month = m;
  body.replaceChildren(el('div', { class: 'loading' }, '불러오는 중...'));
  load(body, workplaceId, workplaceName, view);
}

function renderRow(r) {
  const isCount = r.paymentType === 'COUNT';
  const { h, m } = minutesToHm(r.totalMinutes);

  return el('div', { class: 'card settlement-row' }, [
    el('div', { class: 'settlement-row__top' }, [
      el('span', { class: 'settlement-row__name' }, r.workerName),
      el('span', { class: 'settlement-row__amount' }, isCount ? formatCount(r.recordCount) : formatCurrency(r.totalWage)),
    ]),
    el('div', { class: 'settlement-row__period' }, `${r.periodStart} ~ ${r.periodEnd}`),
    el(
      'div',
      { class: 'settlement-row__detail' },
      isCount ? `근무 ${formatCount(r.recordCount)}` : `근무 ${formatCount(r.recordCount)} · ${h}h ${m}m`,
    ),
  ]);
}

// 정산 내역을 캔버스에 직접 그려서 PNG로 내보낸다 (html2canvas 같은 외부 라이브러리 없이,
// DOM을 그대로 찍는 대신 깔끔한 리포트 형태로 다시 그린다).
function roundRect(ctx, x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + w, y, x + w, y + h, r);
  ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r);
  ctx.arcTo(x, y, x + w, y, r);
  ctx.closePath();
}

async function captureSettlementToPng(workplaceName, view, rows) {
  const FONT = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Malgun Gothic", "Apple SD Gothic Neo", sans-serif';
  const width = 640;
  const padding = 24;
  const headerHeight = 56;
  const rowHeight = 82;
  const rowGap = 10;
  const height = padding * 2 + headerHeight + rows.length * rowHeight + Math.max(rows.length - 1, 0) * rowGap;

  const dpr = window.devicePixelRatio || 1;
  const canvas = document.createElement('canvas');
  canvas.width = width * dpr;
  canvas.height = height * dpr;
  const ctx = canvas.getContext('2d');
  ctx.scale(dpr, dpr);

  ctx.fillStyle = '#F5F6F8';
  ctx.fillRect(0, 0, width, height);

  ctx.fillStyle = '#1a1a1a';
  ctx.font = `bold 18px ${FONT}`;
  ctx.textAlign = 'left';
  ctx.textBaseline = 'alphabetic';
  ctx.fillText(`${workplaceName} 정산 · ${monthLabel(view.year, view.month)}`, padding, padding + 22);

  let y = padding + headerHeight;
  for (const r of rows) {
    const isCount = r.paymentType === 'COUNT';
    const { h, m } = minutesToHm(r.totalMinutes);

    ctx.fillStyle = '#FFFFFF';
    ctx.strokeStyle = '#E0E0E0';
    ctx.lineWidth = 1;
    roundRect(ctx, padding, y, width - padding * 2, rowHeight, 14);
    ctx.fill();
    ctx.stroke();

    const contentX = padding + 18;
    const contentRight = width - padding - 18;

    ctx.fillStyle = '#1a1a1a';
    ctx.font = `bold 16px ${FONT}`;
    ctx.textAlign = 'left';
    ctx.fillText(r.workerName, contentX, y + 28);

    ctx.fillStyle = '#3D5AFE';
    ctx.textAlign = 'right';
    ctx.fillText(isCount ? formatCount(r.recordCount) : formatCurrency(r.totalWage), contentRight, y + 28);

    ctx.fillStyle = '#757575';
    ctx.font = `13px ${FONT}`;
    ctx.textAlign = 'left';
    ctx.fillText(`${r.periodStart} ~ ${r.periodEnd}`, contentX, y + 48);

    const detail = isCount
      ? `근무 ${formatCount(r.recordCount)}`
      : `근무 ${formatCount(r.recordCount)} · ${h}h ${m}m`;
    ctx.fillText(detail, contentX, y + 66);

    y += rowHeight + rowGap;
  }

  const blob = await new Promise((resolve) => canvas.toBlob(resolve, 'image/png'));
  if (!blob) throw new Error('PNG 생성에 실패했습니다.');

  const url = URL.createObjectURL(blob);
  const filename = `정산_${workplaceName}_${view.year}${String(view.month).padStart(2, '0')}.png`;
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.style.display = 'none';
  document.body.append(a);
  a.click();
  a.remove();
  URL.revokeObjectUrl(url);
}
