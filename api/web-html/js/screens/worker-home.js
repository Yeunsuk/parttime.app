import { workRecordApi } from '../apis/work-record-api.js';
import { workplaceApi } from '../apis/workplace-api.js';
import { storage } from '../storage.js';
import { state } from '../state.js';
import { navigate } from '../router.js';
import { el, formatTime, toast } from '../utils.js';

export async function renderWorkerHome(root) {
  const user = state.currentUser;

  const header = el('div', { class: 'app-bar' }, [
    el('div', { class: 'app-bar__title' }, `${user?.name ?? ''}의 근무`),
    el('button', {
      class: 'icon-btn',
      title: '로그아웃',
      onclick: async () => {
        storage.clearAll();
        state.currentUser = null;
        navigate('/login');
      },
    }, '🚪'),
  ]);

  const body = el('div', { class: 'page' }, [el('div', { class: 'loading' }, '불러오는 중...')]);
  root.replaceChildren(el('div', { class: 'screen' }, [header, body]));

  let status;
  try {
    status = await workRecordApi.getStatus();
  } catch (e) {
    body.replaceChildren(el('p', { class: 'error-text' }, `오류: ${e.message}`));
    return;
  }

  renderBody(body, status);
}

function todayString() {
  const now = new Date();
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  const wd = weekdays[(now.getDay() + 6) % 7];
  return `${now.getFullYear()}.${String(now.getMonth() + 1).padStart(2, '0')}.${String(now.getDate()).padStart(2, '0')} (${wd})`;
}

function renderBody(body, status) {
  const isClockedIn = status.isClockedIn;
  const record = status.currentRecord;

  const statusCard = el('div', { class: `status-card ${isClockedIn ? 'status-card--active' : ''}` }, [
    el('div', { class: 'status-card__badge' }, [
      el('span', { class: `status-dot ${isClockedIn ? 'status-dot--on' : ''}` }),
      el('span', {}, isClockedIn ? '근무 중' : '미출근'),
    ]),
    isClockedIn && record
      ? el('div', {}, [
          el('div', { class: 'status-card__workplace' }, record.workplaceName),
          el('div', { class: 'status-card__time' }, `${formatTime(record.clockIn)}부터 출근`),
        ])
      : el('div', {}, [
          el('div', { class: 'status-card__headline' }, '오늘도 화이팅!'),
          el('div', { class: 'status-card__sub' }, todayString()),
        ]),
  ]);

  const clockBtn = el(
    'button',
    {
      class: `clock-button ${isClockedIn ? 'clock-button--off' : 'clock-button--on'}`,
      onclick: () => handleClockTap(body, status),
    },
    [
      el('div', { class: 'clock-button__icon' }, isClockedIn ? '🚪' : '🔓'),
      el('div', { class: 'clock-button__label' }, isClockedIn ? '퇴근' : '출근'),
    ],
  );

  const shortcuts = el('div', { class: 'shortcut-row' }, [
    el(
      'button',
      { class: 'shortcut-card', onclick: () => navigate('/worker/calendar') },
      [el('div', { class: 'shortcut-card__icon' }, '📅'), el('div', {}, '근무 달력')],
    ),
    el(
      'button',
      { class: 'shortcut-card', onclick: () => navigate('/worker/workplace') },
      [el('div', { class: 'shortcut-card__icon' }, '🏪'), el('div', {}, '근무지 관리')],
    ),
  ]);

  body.replaceChildren(
    el('div', { class: 'page worker-home' }, [statusCard, el('div', { class: 'clock-button-wrap' }, clockBtn), shortcuts]),
  );
}

async function handleClockTap(body, status) {
  if (status.isClockedIn && status.currentRecord) {
    if (!window.confirm('퇴근 처리하시겠습니까?')) return;
    try {
      await workRecordApi.clockOut(status.currentRecord.id);
      const next = await workRecordApi.getStatus();
      renderBody(body, next);
    } catch (e) {
      toast(e.message || '퇴근 처리에 실패했습니다.', 'error');
    }
    return;
  }

  const workplaceId = await resolveWorkplaceIdForClockIn();
  if (workplaceId == null) return;

  try {
    await workRecordApi.clockIn(workplaceId);
    const next = await workRecordApi.getStatus();
    renderBody(body, next);
  } catch (e) {
    toast(e.message || '출근 처리에 실패했습니다.', 'error');
  }
}

async function resolveWorkplaceIdForClockIn() {
  const workplaces = await workplaceApi.getMyWorkplaces();

  if (workplaces.length === 0) {
    toast('먼저 근무지에 참가해주세요.', 'error');
    navigate('/worker/workplace');
    return null;
  }

  if (workplaces.length === 1) return workplaces[0].id;

  const names = workplaces.map((w, i) => `${i + 1}. ${w.name}`).join('\n');
  const answer = window.prompt(`출근할 근무지를 선택하세요\n${names}`, '1');
  if (!answer) return null;
  const idx = Number(answer.trim()) - 1;
  if (Number.isNaN(idx) || idx < 0 || idx >= workplaces.length) return null;
  return workplaces[idx].id;
}
