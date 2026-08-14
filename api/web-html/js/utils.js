export function formatCurrency(amount) {
  return `${Number(amount || 0).toLocaleString('ko-KR')}원`;
}

// 횟수제 표기용: 정수면 "3회", 0.5 단위 소수면 "1.5회"처럼 보여준다.
export function formatCount(count) {
  const n = Number(count || 0);
  return Number.isInteger(n) ? `${n}회` : `${n}회`;
}

export function pad2(n) {
  return String(n).padStart(2, '0');
}

// 백엔드가 내려주는 "yyyy-MM-dd'T'HH:mm:ss" 형태의 로컬 시각 문자열에서 HH:mm만 뽑는다.
export function formatTime(iso) {
  if (!iso) return '--:--';
  const dt = new Date(iso);
  return `${pad2(dt.getHours())}:${pad2(dt.getMinutes())}`;
}

export function normalizeDate(d) {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate());
}

export function dateKey(d) {
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`;
}

export function isoDateKeyFromIso(iso) {
  return dateKey(new Date(iso));
}

export function minutesToHm(totalMinutes) {
  const m = Number(totalMinutes || 0);
  return { h: Math.trunc(m / 60), m: m % 60 };
}

// 근무지 "분설정"에서 활성화된 분(options) 중 지금 시각(nowHour:nowMinute)과 실제로 가장
// 가까운 시각을 {hour, minute}로 반환한다. 분만 따로 놓고 비교하면 시간이 안 넘어가서, 예를
// 들어 22:59에 options=[0,30]이면 22:30(29분 차이)을 골라버리는 버그가 있었다 — 실제로는
// 23:00(1분 차이)이 훨씬 가깝다. 그래서 앞/현재/다음 시간의 후보를 모두 놓고 실제 분 단위
// 거리로 비교한다. 동률이면 더 이른 시각을 고른다.
export function nearestClockTime(nowHour, nowMinute, options) {
  if (!options || options.length === 0) return { hour: nowHour, minute: nowMinute };
  const nowTotal = nowHour * 60 + nowMinute;
  let bestTotal = (nowHour - 1) * 60 + options[0];
  let bestDist = Math.abs(bestTotal - nowTotal);
  for (const dh of [-1, 0, 1]) {
    for (const m of options) {
      const total = (nowHour + dh) * 60 + m;
      const dist = Math.abs(total - nowTotal);
      if (dist < bestDist || (dist === bestDist && total < bestTotal)) {
        bestDist = dist;
        bestTotal = total;
      }
    }
  }
  const minute = ((bestTotal % 60) + 60) % 60;
  const hour = (((bestTotal - minute) / 60) % 24 + 24) % 24;
  return { hour, minute };
}

export function el(tag, attrs = {}, children = []) {
  const node = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (k === 'class') node.className = v;
    else if (k === 'html') node.innerHTML = v;
    else if (k.startsWith('on') && typeof v === 'function') {
      node.addEventListener(k.slice(2).toLowerCase(), v);
    } else if (v !== undefined && v !== null && v !== false) {
      node.setAttribute(k, v === true ? '' : v);
    }
  }
  for (const child of [].concat(children)) {
    if (child === null || child === undefined || child === false) continue;
    node.append(child instanceof Node ? child : document.createTextNode(String(child)));
  }
  return node;
}

export function escapeHtml(str) {
  return String(str ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

let toastTimer = null;
export function toast(message, type = 'info') {
  let container = document.getElementById('toast');
  if (!container) {
    container = el('div', { id: 'toast', class: 'toast' });
    document.body.append(container);
  }
  container.textContent = message;
  container.className = `toast toast--${type} toast--show`;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    container.classList.remove('toast--show');
  }, 2600);
}

export function monthLabel(year, month) {
  return `${year}년 ${month}월`;
}

export const WEEKDAY_LABELS = ['일', '월', '화', '수', '목', '금', '토'];
