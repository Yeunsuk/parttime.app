import { workplaceApi } from '../apis/workplace-api.js';
import { payrollApi } from '../apis/payroll-api.js';
import { accountApi } from '../apis/account-api.js';
import { storage } from '../storage.js';
import { state } from '../state.js';
import { navigate } from '../router.js';
import { renderWorkplaceGate } from '../components/workplace-gate.js';
import { openModal } from '../components/modal.js';
import { renderTimeRow } from '../components/time-row.js';
import { colorForWorker, defaultWorkerColorIndex } from '../components/worker-color.js';
import { generateQrDataUrl } from '../components/qr-code.js';
import { CURRENT_TIME_SENTINEL, WORKER_COLOR_PALETTE } from '../config.js';
import {
  el,
  formatCurrency,
  formatCount,
  dateKey,
  minutesToHm,
  WEEKDAY_LABELS,
  monthLabel,
  toast,
  nearestClockTime,
} from '../utils.js';

export async function renderOwnerHome(root) {
  const user = state.currentUser;

  const accountBtn = el('button', { class: 'icon-btn', title: '계좌', disabled: true }, '💳');
  const inviteBtn = el('button', { class: 'icon-btn hidden', title: '초대코드 보기' }, '🔑');
  const settingsBtn = el('button', { class: 'icon-btn hidden', title: '근무지 설정' }, '⚙️');

  const header = el('div', { class: 'app-bar' }, [
    accountBtn,
    el('div', { class: 'app-bar__title' }, `${user?.name ?? ''} 사장님`),
    el('div', { class: 'app-bar__actions' }, [inviteBtn, settingsBtn]),
  ]);

  const body = el('div', { class: 'page' }, [el('div', { class: 'loading' }, '불러오는 중...')]);
  root.replaceChildren(el('div', { class: 'screen' }, [header, body]));

  await renderWorkplaceGate(body, {
    allowCreate: true,
    onResolved: async (workplace) => {
      setupHeaderActions(accountBtn, inviteBtn, settingsBtn, workplace);
      await loadCalendar(body, workplace);
    },
  });
}

async function setupHeaderActions(accountBtn, inviteBtn, settingsBtn, workplace) {
  inviteBtn.classList.remove('hidden');
  settingsBtn.classList.remove('hidden');
  inviteBtn.onclick = () => openInviteCodeDialog(workplace);
  settingsBtn.onclick = () => openSettingsDialog(workplace);

  accountBtn.disabled = true;
  try {
    const accounts = await accountApi.getAccounts(workplace.id);
    accountBtn.disabled = false;
    accountBtn.onclick = () => openAccountPopup(workplace, accounts);
  } catch {
    // 계좌를 못 불러오면 팝업 버튼은 계속 비활성 상태로 둔다.
  }
}

function openAccountPopup(workplace, accounts) {
  const jsonStr = JSON.stringify(accounts);
  const encoded = btoa(unescape(encodeURIComponent(jsonStr)))
    .replaceAll('+', '-')
    .replaceAll('/', '_');
  const target = `/account-popup?workplaceName=${encodeURIComponent(workplace.name)}&data=${encodeURIComponent(encoded)}`;
  const baseUrl = window.location.href.split('#')[0];
  window.open(`${baseUrl}#${target}`, '_blank', 'width=420,height=640');
}

function openInviteCodeDialog(workplace) {
  openModal({
    title: `${workplace.name} 초대코드`,
    render: ({ body, footer, close }) => {
      const codeEl = el('span', { class: 'invite-code' }, workplace.inviteCode);
      const copyBtn = el(
        'button',
        {
          class: 'icon-btn',
          title: '복사',
          onclick: async () => {
            await navigator.clipboard.writeText(workplace.inviteCode);
            toast('초대코드가 복사되었습니다.', 'success');
          },
        },
        '📋',
      );
      body.append(el('div', { class: 'invite-code-row' }, [codeEl, copyBtn]));
      footer.append(el('button', { class: 'btn btn--ghost', onclick: close }, '닫기'));
    },
  });
}

// ---------- 근무지 설정 다이얼로그 ----------

function openSettingsDialog(workplace) {
  openModal({
    title: '근무지 설정',
    wide: true,
    render: ({ body, footer, close }) => {
      footer.append(el('button', { class: 'btn btn--ghost', onclick: close }, '닫기'));
      loadSettingsBody(body, workplace.id);
    },
  });
}

async function loadSettingsBody(body, workplaceId) {
  body.replaceChildren(el('div', { class: 'loading' }, '불러오는 중...'));
  let workplaces, workers, accounts;
  try {
    [workplaces, workers, accounts] = await Promise.all([
      workplaceApi.getMyWorkplaces(),
      workplaceApi.getWorkers(workplaceId),
      accountApi.getAccounts(workplaceId),
    ]);
  } catch (e) {
    body.replaceChildren(el('p', { class: 'error-text' }, `오류: ${e.message}`));
    return;
  }
  const current = workplaces.find((w) => w.id === workplaceId) || workplaces[0];
  const reload = () => loadSettingsBody(body, workplaceId);
  renderSettingsBody(body, workplaceId, current, workers, accounts, reload);
}

function renderSettingsBody(body, workplaceId, workplace, workers, accounts, reload) {
  const minLimit = workers.length > 1 ? workers.length : 1;

  const memberLimitRow = el('div', { class: 'stepper-row' }, [
    el(
      'button',
      {
        class: 'icon-btn',
        disabled: workplace.memberLimit <= minLimit,
        onclick: async () => {
          try {
            await workplaceApi.updateMemberLimit(workplaceId, workplace.memberLimit - 1);
            reload();
          } catch (e) {
            toast(`변경 실패: ${e.message}`, 'error');
          }
        },
      },
      '➖',
    ),
    el('span', { class: 'stepper-value' }, `${workplace.memberLimit}명`),
    el(
      'button',
      {
        class: 'icon-btn',
        onclick: async () => {
          try {
            await workplaceApi.updateMemberLimit(workplaceId, workplace.memberLimit + 1);
            reload();
          } catch (e) {
            toast(`변경 실패: ${e.message}`, 'error');
          }
        },
      },
      '➕',
    ),
  ]);

  const timeSettingsRow = el('div', { class: 'button-row' }, [
    el('button', { class: 'btn btn--outline', onclick: () => openHourSettingsDialog(workplaceId, workplace, reload) }, '시간설정'),
    el('button', { class: 'btn btn--outline', onclick: () => openMinuteSettingsDialog(workplaceId, workplace, reload) }, '분설정'),
  ]);

  const memberSectionHeader = el('div', { class: 'section-header' }, [
    el('h3', {}, '직원 관리'),
    el(
      'button',
      { class: 'btn btn--text', onclick: () => addMember(workplaceId, reload) },
      '+ 직원 추가',
    ),
  ]);

  const memberList =
    workers.length === 0
      ? el('p', { class: 'empty-text' }, '아직 소속된 직원이 없습니다.')
      : el(
          'div',
          { class: 'settings-list' },
          workers.map((w) => renderWorkerRow(workplaceId, workplace, w, reload)),
        );

  const accountSectionHeader = el('div', { class: 'section-header' }, [
    el('h3', {}, '계좌설정'),
    el(
      'button',
      { class: 'btn btn--text', onclick: () => openAddAccountDialog(workplaceId, reload) },
      '+ 계좌 추가',
    ),
  ]);

  const accountList =
    accounts.length === 0
      ? el('p', { class: 'empty-text' }, '등록된 계좌가 없습니다.')
      : el(
          'div',
          { class: 'settings-list' },
          accounts.map((a) => renderAccountRow(workplaceId, a, reload)),
        );

  const logoutBtn = el(
    'button',
    {
      class: 'btn btn--outline btn--block btn--danger',
      onclick: () => {
        storage.clearAll();
        state.currentUser = null;
        navigate('/login');
      },
    },
    '🚪 로그아웃',
  );

  body.replaceChildren(
    el('div', { class: 'settings-dialog' }, [
      el('h3', {}, '인원제한'),
      memberLimitRow,
      el('hr'),
      timeSettingsRow,
      el('hr'),
      memberSectionHeader,
      memberList,
      el('hr'),
      accountSectionHeader,
      accountList,
      el('hr'),
      logoutBtn,
    ]),
  );
}

function renderWorkerRow(workplaceId, workplace, worker, reload) {
  return el('div', { class: 'settings-row' }, [
    el('div', { class: 'settings-row__name' }, worker.name),
    el('div', { class: 'settings-row__actions' }, [
      el('button', { class: 'btn btn--text-sm', onclick: () => openPayPeriodDialog(workplaceId, worker, reload) }, '월급설정'),
      el('button', { class: 'btn btn--text-sm', onclick: () => openPaymentTypeDialog(workplaceId, worker, reload) }, '정산방식'),
      el('button', { class: 'btn btn--text-sm', onclick: () => openDefaultTimeDialog(workplaceId, workplace, worker, reload) }, '시간설정'),
      el('button', { class: 'btn btn--text-sm', onclick: () => openWorkingDaysDialog(workplaceId, worker, reload) }, '요일설정'),
      el('button', { class: 'btn btn--text-sm', onclick: () => openCalendarColorDialog(workplaceId, worker) }, '달력색상'),
      el(
        'button',
        { class: 'btn btn--text-sm btn--danger', onclick: () => removeMember(workplaceId, worker, reload) },
        '내보내기',
      ),
    ]),
  ]);
}

function renderAccountRow(workplaceId, account, reload) {
  const qrRow =
    account.qrCodes.length > 0
      ? el(
          'div',
          { class: 'qr-chip-row' },
          account.qrCodes.map((qr) =>
            el('div', { class: 'qr-chip' }, [
              el('img', { src: qr.qrImage, alt: qr.name, class: 'qr-chip__img' }),
              el('span', { class: 'qr-chip__name' }, qr.name),
              el(
                'button',
                { class: 'qr-chip__delete', onclick: () => removeQr(workplaceId, account, qr, reload) },
                '✕',
              ),
            ]),
          ),
        )
      : null;

  return el('div', { class: 'settings-row' }, [
    el('div', {}, [
      el('div', { class: 'settings-row__name' }, account.accountName),
      el('div', { class: 'settings-row__sub' }, `${account.bankName} ${account.accountNumber}`),
    ]),
    qrRow,
    el('div', { class: 'settings-row__actions' }, [
      el('button', { class: 'btn btn--text-sm', onclick: () => generateQr(workplaceId, account, reload) }, 'QR자동생성'),
      el('button', { class: 'btn btn--text-sm', onclick: () => addQrFromFile(workplaceId, account, reload) }, 'QR추가'),
      el(
        'button',
        { class: 'btn btn--text-sm btn--danger', onclick: () => removeAccount(workplaceId, account, reload) },
        '계좌 삭제',
      ),
    ]),
  ]);
}

async function addMember(workplaceId, reload) {
  const employeeId = window.prompt('추가할 직원의 아이디를 입력하세요.');
  if (!employeeId || !employeeId.trim()) return;
  try {
    await workplaceApi.addMember(workplaceId, employeeId.trim());
    toast('추가되었습니다.', 'success');
    reload();
  } catch (e) {
    toast(`추가 실패: ${e.message}`, 'error');
  }
}

async function removeMember(workplaceId, worker, reload) {
  if (!window.confirm(`${worker.name}님을 이 근무지에서 내보내시겠습니까?\n기존 근무기록은 그대로 남습니다.`)) return;
  try {
    await workplaceApi.removeMember(workplaceId, worker.id);
    toast(`${worker.name}님을 내보냈습니다.`, 'success');
    reload();
  } catch (e) {
    toast(`내보내기 실패: ${e.message}`, 'error');
  }
}

function openHourSettingsDialog(workplaceId, workplaceSnapshot, onClose) {
  openModal({
    title: '시간설정',
    render: ({ body, footer, close }) => {
      footer.append(
        el(
          'button',
          {
            class: 'btn btn--ghost',
            onclick: () => {
              close();
              onClose();
            },
          },
          '닫기',
        ),
      );
      renderHourChips(body, workplaceId, workplaceSnapshot.disabledHours || []);
    },
  });
}

function renderHourChips(body, workplaceId, disabledHours) {
  const note = el('p', { class: 'hint-text' }, '선택한 시간은 근무기록 생성/수정 시 시간 목록에서 제외됩니다.');
  const hours = [CURRENT_TIME_SENTINEL, ...Array.from({ length: 24 }, (_, i) => i)];
  const chips = el(
    'div',
    { class: 'chip-wrap' },
    hours.map((h) => {
      const isCurrentTime = h === CURRENT_TIME_SENTINEL;
      const disabled = disabledHours.includes(h);
      return el(
        'button',
        {
          class: `chip ${disabled ? 'chip--off' : 'chip--on'}`,
          onclick: () => toggleDisabledHour(body, workplaceId, disabledHours, h),
        },
        isCurrentTime ? '현재시간' : `${h}시`,
      );
    }),
  );
  body.replaceChildren(note, chips);
}

async function toggleDisabledHour(body, workplaceId, currentDisabledHours, hour) {
  const next = currentDisabledHours.includes(hour)
    ? currentDisabledHours.filter((h) => h !== hour)
    : [...currentDisabledHours, hour];

  if (next.length >= 25) {
    toast('최소 1개의 시간은 활성화되어 있어야 합니다.', 'error');
    return;
  }

  try {
    await workplaceApi.updateDisabledHours(workplaceId, next);
    renderHourChips(body, workplaceId, next);
  } catch (e) {
    toast(`변경 실패: ${e.message}`, 'error');
  }
}

function openMinuteSettingsDialog(workplaceId, workplaceSnapshot, onClose) {
  openModal({
    title: '분설정',
    render: ({ body, footer, close }) => {
      footer.append(
        el(
          'button',
          {
            class: 'btn btn--ghost',
            onclick: () => {
              close();
              onClose();
            },
          },
          '닫기',
        ),
      );
      renderMinuteChips(body, workplaceId, workplaceSnapshot.enabledMinutes || [0, 30]);
    },
  });
}

function renderMinuteChips(body, workplaceId, enabledMinutes) {
  const note = el('p', { class: 'hint-text' }, '선택한 분만 근무기록 생성/수정 시 분 목록에 표시됩니다.');
  const minutes = Array.from({ length: 60 }, (_, i) => i);
  const chips = el(
    'div',
    { class: 'chip-wrap' },
    minutes.map((m) => {
      const enabled = enabledMinutes.includes(m);
      return el(
        'button',
        {
          class: `chip ${enabled ? 'chip--on' : 'chip--off'}`,
          onclick: () => toggleEnabledMinute(body, workplaceId, enabledMinutes, m),
        },
        `${m}분`,
      );
    }),
  );
  body.replaceChildren(note, chips);
}

async function toggleEnabledMinute(body, workplaceId, currentEnabledMinutes, minute) {
  const next = currentEnabledMinutes.includes(minute)
    ? currentEnabledMinutes.filter((m) => m !== minute)
    : [...currentEnabledMinutes, minute];

  if (next.length === 0) {
    toast('최소 1개의 분은 활성화되어 있어야 합니다.', 'error');
    return;
  }

  try {
    await workplaceApi.updateEnabledMinutes(workplaceId, next);
    renderMinuteChips(body, workplaceId, next);
  } catch (e) {
    toast(`변경 실패: ${e.message}`, 'error');
  }
}

function openPayPeriodDialog(workplaceId, worker, reload) {
  let startDay = worker.payPeriodStartDay || 1;
  openModal({
    title: `${worker.name}님 정산 기간`,
    render: ({ body, footer, close }) => {
      const noteEl = el('div', { class: 'hint-text' });
      const select = el(
        'select',
        {
          onchange: (e) => {
            startDay = Number(e.target.value);
            updateNote();
          },
        },
        Array.from({ length: 28 }, (_, i) => i + 1).map((d) =>
          el('option', { value: d, selected: d === startDay ? '' : undefined }, `${d}일`),
        ),
      );
      function updateNote() {
        const endDay = startDay === 1 ? '말일' : `${startDay - 1}일`;
        noteEl.textContent =
          startDay === 1 ? '매월 1일 ~ 말일 (기본값)' : `매월 ${startDay}일 ~ 다음달 ${endDay}`;
      }
      updateNote();

      body.append(el('p', {}, '매월 정산 시작일'), select, noteEl);
      footer.append(
        el('button', { class: 'btn btn--ghost', onclick: close }, '취소'),
        el('button', {
          class: 'btn btn--primary',
          onclick: async () => {
            try {
              await workplaceApi.updatePayPeriod(workplaceId, worker.id, startDay);
              toast('정산 기간이 저장되었습니다.', 'success');
              close();
              reload();
            } catch (e) {
              toast(`저장 실패: ${e.message}`, 'error');
            }
          },
        }, '저장'),
      );
    },
  });
}

function openPaymentTypeDialog(workplaceId, worker, reload) {
  let paymentType = worker.paymentType;
  openModal({
    title: `${worker.name}님 정산 방식`,
    render: ({ body, footer, close }) => {
      function renderOptions() {
        return el('div', { class: 'radio-group' }, [
          el('label', { class: 'radio-option' }, [
            el('input', {
              type: 'radio',
              name: 'payment-type',
              checked: paymentType === 'TIME' ? '' : undefined,
              onchange: () => {
                paymentType = 'TIME';
              },
            }),
            el('div', {}, [el('div', {}, '시간'), el('div', { class: 'hint-text' }, '시급 × 근무시간으로 정산')]),
          ]),
          el('label', { class: 'radio-option' }, [
            el('input', {
              type: 'radio',
              name: 'payment-type',
              checked: paymentType === 'COUNT' ? '' : undefined,
              onchange: () => {
                paymentType = 'COUNT';
              },
            }),
            el('div', {}, [el('div', {}, '횟수'), el('div', { class: 'hint-text' }, '근무 1건당 횟수로만 집계')]),
          ]),
        ]);
      }
      body.append(renderOptions());
      footer.append(
        el('button', { class: 'btn btn--ghost', onclick: close }, '취소'),
        el('button', {
          class: 'btn btn--primary',
          onclick: async () => {
            try {
              await workplaceApi.updatePaymentType(workplaceId, worker.id, paymentType);
              toast('정산 방식이 저장되었습니다.', 'success');
              close();
              reload();
            } catch (e) {
              toast(`저장 실패: ${e.message}`, 'error');
            }
          },
        }, '저장'),
      );
    },
  });
}

function openDefaultTimeDialog(workplaceId, workplace, worker, reload) {
  const disabledHours = workplace.disabledHours || [];
  const enabledMinutes = workplace.enabledMinutes || [0, 30];
  const timeState = {
    clockInHour: worker.defaultClockInHour ?? 18,
    clockInMinute: worker.defaultClockInMinute ?? 0,
    clockOutHour: worker.defaultClockOutHour ?? 22,
    clockOutMinute: worker.defaultClockOutMinute ?? 0,
  };

  openModal({
    title: `${worker.name}님 시간설정`,
    render: ({ body, footer, close }) => {
      const rowsHost = el('div', { class: 'time-rows' });
      function renderRows() {
        rowsHost.replaceChildren(
          renderTimeRow({
            label: '출근',
            hour: timeState.clockInHour,
            minute: timeState.clockInMinute,
            disabledHours,
            enabledMinutes,
            allowCurrentTimeOption: true,
            onHourChange: (h) => {
              timeState.clockInHour = h;
              renderRows();
            },
            onMinuteChange: (m) => {
              timeState.clockInMinute = m;
              renderRows();
            },
          }),
          renderTimeRow({
            label: '퇴근',
            hour: timeState.clockOutHour,
            minute: timeState.clockOutMinute,
            disabledHours,
            enabledMinutes,
            allowCurrentTimeOption: true,
            onHourChange: (h) => {
              timeState.clockOutHour = h;
              renderRows();
            },
            onMinuteChange: (m) => {
              timeState.clockOutMinute = m;
              renderRows();
            },
          }),
        );
      }
      renderRows();
      body.append(rowsHost);
      footer.append(
        el('button', { class: 'btn btn--ghost', onclick: close }, '취소'),
        el('button', {
          class: 'btn btn--primary',
          onclick: async () => {
            try {
              await workplaceApi.updateDefaultTime(
                workplaceId,
                worker.id,
                timeState.clockInHour,
                timeState.clockInMinute,
                timeState.clockOutHour,
                timeState.clockOutMinute,
              );
              toast('기본 근무시간이 저장되었습니다.', 'success');
              close();
              reload();
            } catch (e) {
              toast(`저장 실패: ${e.message}`, 'error');
            }
          },
        }, '저장'),
      );
    },
  });
}

const WEEKDAY_SHORT_LABELS = ['월', '화', '수', '목', '금', '토', '일'];

// 직원별 요일설정 다이얼로그. "미설정"을 켜면(요일 제한 없음) 요일 칩들이 비활성화되고,
// 끄면 개별적으로 토글할 수 있다. 1=월요일 ... 7=일요일 (JS Date.getDay()는 0=일요일이라
// 다르므로, 이 값을 쓰는 쪽(정렬 로직)에서 변환해야 한다).
function openWorkingDaysDialog(workplaceId, worker, reload) {
  const state = {
    unset: !worker.workingDaysEnabled,
    days: new Set(worker.workingDays || []),
  };

  openModal({
    title: `${worker.name}님 요일설정`,
    render: ({ body, footer, close }) => {
      function renderContent() {
        const unsetChip = el(
          'button',
          {
            class: `chip ${state.unset ? 'chip--on' : 'chip--off-plain'}`,
            onclick: () => {
              state.unset = !state.unset;
              renderContent();
            },
          },
          '미설정',
        );

        const dayChips = el(
          'div',
          { class: 'chip-wrap' },
          WEEKDAY_SHORT_LABELS.map((label, i) => {
            const day = i + 1;
            const selected = state.days.has(day);
            return el(
              'button',
              {
                class: `chip ${state.unset ? 'chip--disabled' : selected ? 'chip--on' : 'chip--off-plain'}`,
                disabled: state.unset,
                onclick: state.unset
                  ? undefined
                  : () => {
                      if (selected) state.days.delete(day);
                      else state.days.add(day);
                      renderContent();
                    },
              },
              label,
            );
          }),
        );

        body.replaceChildren(
          el('p', { class: 'hint-text' }, '선택한 요일에만 이 직원을 활성으로 표시합니다. "미설정"이면 요일이 지정되지 않아 항상 비활성으로 표시됩니다.'),
          unsetChip,
          dayChips,
        );
      }
      renderContent();

      footer.append(
        el('button', { class: 'btn btn--ghost', onclick: close }, '취소'),
        el('button', {
          class: 'btn btn--primary',
          onclick: async () => {
            try {
              await workplaceApi.updateWorkingDays(workplaceId, worker.id, !state.unset, [...state.days]);
              toast('요일 설정이 저장되었습니다.', 'success');
              close();
              reload();
            } catch (e) {
              toast(`저장 실패: ${e.message}`, 'error');
            }
          },
        }, '저장'),
      );
    },
  });
}

function openCalendarColorDialog(workplaceId, worker) {
  openModal({
    title: `${worker.name}님 달력색상`,
    render: ({ body, footer, close }) => {
      function renderSwatches() {
        const overrides = storage.getWorkerColorOverrides(workplaceId);
        const currentIndex = overrides[worker.id] ?? undefined;
        body.replaceChildren(
          el(
            'div',
            { class: 'swatch-wrap' },
            WORKER_COLOR_PALETTE.map((color, i) => {
              const selected = i === (currentIndex ?? defaultWorkerColorIndex(worker.id));
              return el('button', {
                class: `swatch ${selected ? 'swatch--selected' : ''}`,
                style: `background:${color}`,
                onclick: () => {
                  storage.saveWorkerColorOverride(workplaceId, worker.id, i);
                  renderSwatches();
                },
              }, selected ? '✓' : '');
            }),
          ),
        );
      }
      renderSwatches();
      footer.append(el('button', { class: 'btn btn--ghost', onclick: close }, '닫기'));
    },
  });
}

function openAddAccountDialog(workplaceId, reload) {
  const nameInput = el('input', { type: 'text', placeholder: '계좌명' });
  const bankInput = el('input', { type: 'text', placeholder: '은행명' });
  const numberInput = el('input', { type: 'text', placeholder: '계좌번호' });

  openModal({
    title: '계좌 추가',
    render: ({ body, footer, close }) => {
      body.append(
        el('div', { class: 'form-field' }, [el('label', {}, '계좌명'), nameInput]),
        el('div', { class: 'form-field' }, [el('label', {}, '은행명'), bankInput]),
        el('div', { class: 'form-field' }, [el('label', {}, '계좌번호'), numberInput]),
      );
      footer.append(
        el('button', { class: 'btn btn--ghost', onclick: close }, '취소'),
        el('button', {
          class: 'btn btn--primary',
          onclick: async () => {
            const accountName = nameInput.value.trim();
            const bankName = bankInput.value.trim();
            const accountNumber = numberInput.value.trim();
            if (!accountName || !bankName || !accountNumber) return;
            try {
              await accountApi.create(workplaceId, accountName, accountNumber, bankName);
              toast('계좌가 추가되었습니다.', 'success');
              close();
              reload();
            } catch (e) {
              toast(`추가 실패: ${e.message}`, 'error');
            }
          },
        }, '추가'),
      );
    },
  });
}

async function removeAccount(workplaceId, account, reload) {
  if (!window.confirm(`${account.accountName} 계좌를 삭제하시겠습니까?`)) return;
  try {
    await accountApi.delete(workplaceId, account.id);
    toast('삭제되었습니다.', 'success');
    reload();
  } catch (e) {
    toast(`삭제 실패: ${e.message}`, 'error');
  }
}

async function generateQr(workplaceId, account, reload) {
  const name = window.prompt('QR 이름 (예: 카카오페이, 국민은행)');
  if (!name || !name.trim()) return;
  try {
    const dataUrl = generateQrDataUrl(account.accountNumber);
    await accountApi.addQr(workplaceId, account.id, name.trim(), dataUrl);
    toast('QR이 등록되었습니다.', 'success');
    reload();
  } catch (e) {
    toast(`QR 등록 실패: ${e.message}`, 'error');
  }
}

function addQrFromFile(workplaceId, account, reload) {
  const name = window.prompt('QR 이름 (예: 카카오페이, 국민은행)');
  if (!name || !name.trim()) return;

  const input = el('input', { type: 'file', accept: 'image/*', class: 'hidden' });
  input.addEventListener('change', () => {
    const file = input.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = async () => {
      try {
        await accountApi.addQr(workplaceId, account.id, name.trim(), reader.result);
        toast('QR이 등록되었습니다.', 'success');
        reload();
      } catch (e) {
        toast(`QR 등록 실패: ${e.message}`, 'error');
      }
    };
    reader.readAsDataURL(file);
  });
  document.body.append(input);
  input.click();
  setTimeout(() => input.remove(), 5000);
}

async function removeQr(workplaceId, account, qr, reload) {
  if (!window.confirm(`${qr.name} QR을 삭제하시겠습니까?`)) return;
  try {
    await accountApi.deleteQr(workplaceId, account.id, qr.id);
    toast('삭제되었습니다.', 'success');
    reload();
  } catch (e) {
    toast(`삭제 실패: ${e.message}`, 'error');
  }
}

// ---------- 근무지 전체 달력 (본문) ----------

async function loadCalendar(body, workplace) {
  const now = new Date();
  const view = { year: now.getFullYear(), month: now.getMonth() + 1, selectedKey: null };
  await loadRecords(body, workplace, view);
}

async function loadRecords(body, workplace, view) {
  let records;
  try {
    records = await payrollApi.getWorkplaceRecords(workplace.id, view.year, view.month);
  } catch (e) {
    body.replaceChildren(el('p', { class: 'error-text' }, `오류: ${e.message}`));
    return;
  }
  renderCalendarBody(body, workplace, view, records);
}

function renderCalendarBody(body, workplace, view, records) {
  const overrides = storage.getWorkerColorOverrides(workplace.id);
  const recordMap = {};
  for (const r of records) {
    const key = dateKey(new Date(r.clockIn));
    (recordMap[key] ||= []).push(r);
  }
  const monthTotal = records.reduce((s, r) => s + (r.wageAmount || 0), 0);

  const banner = el('div', { class: 'month-banner' }, [
    el('span', {}, '이번 달 총 지출'),
    el('span', { class: 'month-banner__amount' }, formatCurrency(monthTotal)),
  ]);

  const nav = el('div', { class: 'calendar-nav' }, [
    el('button', { class: 'btn btn--ghost', onclick: () => changeMonth(body, workplace, view, -1) }, '‹'),
    el('div', { class: 'calendar-nav__label' }, monthLabel(view.year, view.month)),
    el('button', { class: 'btn btn--ghost', onclick: () => changeMonth(body, workplace, view, 1) }, '›'),
  ]);

  const grid = buildOwnerGrid(view, recordMap, overrides, (key) => {
    view.selectedKey = view.selectedKey === key ? null : key;
    renderCalendarBody(body, workplace, view, records);
  });

  const actionRow = el('div', { class: 'calendar-action-row' }, [
    el(
      'button',
      {
        class: 'btn btn--chip',
        onclick: () => navigate(`/owner/settlement?workplaceId=${workplace.id}&workplaceName=${encodeURIComponent(workplace.name)}`),
      },
      '🧮 정산',
    ),
    el(
      'button',
      {
        class: 'btn btn--chip',
        onclick: () =>
          openAddRecordDialog(workplace, view.selectedKey, () => loadRecords(body, workplace, view)),
      },
      '➕ 근무기록 추가',
    ),
  ]);

  const listHost =
    view.selectedKey && recordMap[view.selectedKey]?.length
      ? renderDayWorkerBreakdown(recordMap[view.selectedKey], workplace, view)
      : renderWorkerSummaryList(records, workplace, view);

  body.replaceChildren(el('div', { class: 'page owner-page' }, [banner, nav, grid, actionRow, listHost]));
}

function changeMonth(body, workplace, view, delta) {
  let m = view.month + delta;
  let y = view.year;
  if (m < 1) { m = 12; y -= 1; }
  if (m > 12) { m = 1; y += 1; }
  view.year = y;
  view.month = m;
  view.selectedKey = null;
  body.replaceChildren(el('div', { class: 'loading' }, '불러오는 중...'));
  loadRecords(body, workplace, view);
}

function buildOwnerGrid(view, recordMap, overrides, onSelect) {
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
      const workerCount = new Set(dayRecords.map((r) => r.workerId)).size;
      cellChildren.push(el('div', { class: 'day-cell__wage' }, formatCurrency(totalWage)));
      cellChildren.push(el('div', { class: 'day-cell__hours' }, `${workerCount}명`));

      const workerIds = [...new Set(dayRecords.map((r) => r.workerId))].slice(0, 5);
      cellChildren.push(
        el(
          'div',
          { class: 'day-cell__markers' },
          workerIds.map((id) => el('span', { class: 'marker-dot', style: `background:${colorForWorker(id, overrides)}` })),
        ),
      );
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

function groupByWorker(records) {
  const grouped = new Map();
  for (const r of records) {
    if (!grouped.has(r.workerId)) grouped.set(r.workerId, []);
    grouped.get(r.workerId).push(r);
  }
  return [...grouped.entries()];
}

function renderDayWorkerBreakdown(records, workplace, view) {
  const entries = groupByWorker(records);
  return el(
    'div',
    { class: 'card-list' },
    entries.map(([workerId, workerRecords]) => {
      const workerName = workerRecords[0].workerName;
      const isCount = workerRecords[0].paymentType === 'COUNT';
      const wage = workerRecords.reduce((s, r) => s + (r.wageAmount || 0), 0);
      const minutes = workerRecords.reduce((s, r) => s + (r.workMinutes || 0), 0);
      const count = workerRecords.reduce((s, r) => s + (r.recordCount || 0), 0);
      const { h, m } = minutesToHm(minutes);

      return el(
        'button',
        {
          class: 'list-card list-card--button',
          onclick: () => goToWorkerDetail(workplace.id, workerId, workerName, view.year, view.month),
        },
        [
          el('div', {}, [
            el('div', { class: 'list-card__title' }, workerName),
            !isCount ? el('div', { class: 'list-card__sub' }, `${h}h ${m}m`) : null,
          ]),
          el('div', { class: 'list-card__amount' }, isCount ? formatCount(count) : formatCurrency(wage)),
        ],
      );
    }),
  );
}

function renderWorkerSummaryList(records, workplace, view) {
  if (records.length === 0) {
    return el('div', { class: 'empty-state' }, '이번 달 근무 기록이 없습니다.');
  }
  const entries = groupByWorker(records);
  return el(
    'div',
    { class: 'card-list' },
    entries.map(([workerId, workerRecords]) => {
      const workerName = workerRecords[0].workerName;
      const isCount = workerRecords[0].paymentType === 'COUNT';
      const totalWage = workerRecords.reduce((s, r) => s + (r.wageAmount || 0), 0);
      const totalMinutes = workerRecords.reduce((s, r) => s + (r.workMinutes || 0), 0);
      const totalCount = workerRecords.reduce((s, r) => s + (r.recordCount || 0), 0);
      const workDays = new Set(workerRecords.map((r) => dateKey(new Date(r.clockIn)))).size;
      const { h, m } = minutesToHm(totalMinutes);

      return el(
        'button',
        {
          class: 'list-card list-card--button worker-summary-card',
          onclick: () => goToWorkerDetail(workplace.id, workerId, workerName, view.year, view.month),
        },
        [
          el('div', { class: 'worker-summary-card__avatar' }, workerName.slice(0, 1)),
          el('div', { class: 'worker-summary-card__body' }, [
            el('div', { class: 'list-card__title' }, workerName),
            el(
              'div',
              { class: 'list-card__sub' },
              isCount ? `${workDays}일 · ${formatCount(totalCount)}` : `${workDays}일 · ${h}h ${m}m`,
            ),
          ]),
          el('div', { class: 'list-card__amount' }, isCount ? formatCount(totalCount) : formatCurrency(totalWage)),
        ],
      );
    }),
  );
}

function goToWorkerDetail(workplaceId, workerId, workerName, year, month) {
  navigate(
    `/owner/worker-detail?workplaceId=${workplaceId}&workerId=${workerId}&workerName=${encodeURIComponent(workerName)}&year=${year}&month=${month}`,
  );
}

// ---------- 근무기록 추가 다이얼로그 ----------

// 근무기록 추가 다이얼로그의 근로자 목록 정렬 기준: (1) 그 날짜 요일에 활성인 근로자가
// 먼저, (2) 같은 활성 여부 안에서는 시간제가 횟수제보다 먼저, (3) 그 안에서는 가나다순.
// JS의 Date.getDay()는 0=일요일 ... 6=토요일이라, 백엔드/Flutter와 같은 1=월~7=일 값으로
// 바꿔서 workingDays와 비교한다. "미설정"(workingDaysEnabled=false)이면 선택된 요일 자체가
// 없으므로 항상 비활성으로 취급한다.
function compareWorkersForAddRecord(a, b, date) {
  const jsDay = date.getDay();
  const dayValue = jsDay === 0 ? 7 : jsDay;
  const aActive = a.workingDaysEnabled && (a.workingDays || []).includes(dayValue);
  const bActive = b.workingDaysEnabled && (b.workingDays || []).includes(dayValue);
  if (aActive !== bActive) return aActive ? -1 : 1;

  const aCount = a.paymentType === 'COUNT';
  const bCount = b.paymentType === 'COUNT';
  if (aCount !== bCount) return aCount ? 1 : -1;

  return a.name.localeCompare(b.name, 'ko');
}

function openAddRecordDialog(workplace, selectedKey, onSuccess) {
  const date = selectedKey ? new Date(`${selectedKey}T00:00:00`) : new Date();
  const disabledHours = workplace.disabledHours || [];
  const enabledMinutes = workplace.enabledMinutes || [0, 30];

  const formState = {
    workerId: null,
    paymentType: 'TIME',
    recordCount: 1.0,
    clockInHour: 18,
    clockInMinute: 0,
    clockOutHour: 22,
    clockOutMinute: 0,
  };

  function applyWorkerDefaults(worker) {
    const now = new Date();
    if (worker.defaultClockInHour === CURRENT_TIME_SENTINEL) {
      const t = nearestClockTime(now.getHours(), now.getMinutes(), enabledMinutes);
      formState.clockInHour = t.hour;
      formState.clockInMinute = t.minute;
    } else {
      formState.clockInHour = worker.defaultClockInHour ?? 18;
      formState.clockInMinute = worker.defaultClockInMinute ?? 0;
    }
    if (worker.defaultClockOutHour === CURRENT_TIME_SENTINEL) {
      const t = nearestClockTime(now.getHours(), now.getMinutes(), enabledMinutes);
      formState.clockOutHour = t.hour;
      formState.clockOutMinute = t.minute;
    } else {
      formState.clockOutHour = worker.defaultClockOutHour ?? 22;
      formState.clockOutMinute = worker.defaultClockOutMinute ?? 0;
    }
  }

  openModal({
    title: '근무기록 추가',
    render: ({ body, footer, close }) => {
      const dateLabel = el('div', { class: 'hint-text' }, formatDateLabel(date));
      const contentHost = el('div', {});
      const saveBtn = el('button', { class: 'btn btn--primary', onclick: () => {} }, '추가');
      footer.append(el('button', { class: 'btn btn--ghost', onclick: close }, '취소'), saveBtn);

      body.append(dateLabel, contentHost);

      workplaceApi
        .getWorkers(workplace.id)
        .then((fetchedWorkers) => {
          if (fetchedWorkers.length === 0) {
            contentHost.replaceChildren(el('p', {}, '아직 참가한 근로자가 없습니다.'));
            return;
          }
          const workers = [...fetchedWorkers].sort((a, b) => compareWorkersForAddRecord(a, b, date));
          if (formState.workerId == null) {
            formState.workerId = workers[0].id;
            formState.paymentType = workers[0].paymentType;
            applyWorkerDefaults(workers[0]);
          }
          renderForm(contentHost, workers);
          saveBtn.onclick = () => submit(workers, close, onSuccess);
        })
        .catch((e) => {
          contentHost.replaceChildren(el('p', { class: 'error-text' }, `오류: ${e.message}`));
        });

      function renderForm(host, workers) {
        const select = el(
          'select',
          {
            onchange: (e) => {
              const worker = workers.find((w) => w.id === Number(e.target.value));
              formState.workerId = worker.id;
              formState.paymentType = worker.paymentType;
              formState.recordCount = 1.0;
              applyWorkerDefaults(worker);
              renderForm(host, workers);
            },
          },
          workers.map((w) => el('option', { value: w.id, selected: w.id === formState.workerId ? '' : undefined }, w.name)),
        );

        const timeSection =
          formState.paymentType !== 'COUNT'
            ? el('div', { class: 'time-rows' }, [
                renderTimeRow({
                  label: '출근',
                  hour: formState.clockInHour,
                  minute: formState.clockInMinute,
                  disabledHours,
                  enabledMinutes,
                  onHourChange: (h) => { formState.clockInHour = h; renderForm(host, workers); },
                  onMinuteChange: (m) => { formState.clockInMinute = m; renderForm(host, workers); },
                }),
                renderTimeRow({
                  label: '퇴근',
                  hour: formState.clockOutHour,
                  minute: formState.clockOutMinute,
                  disabledHours,
                  enabledMinutes,
                  onHourChange: (h) => { formState.clockOutHour = h; renderForm(host, workers); },
                  onMinuteChange: (m) => { formState.clockOutMinute = m; renderForm(host, workers); },
                }),
              ])
            : el('div', { class: 'radio-group' }, [
                el('label', { class: 'radio-option' }, [
                  el('input', {
                    type: 'radio',
                    name: 'record-count',
                    checked: formState.recordCount === 1.0 ? '' : undefined,
                    onchange: () => { formState.recordCount = 1.0; },
                  }),
                  el('div', {}, '1회'),
                ]),
                el('label', { class: 'radio-option' }, [
                  el('input', {
                    type: 'radio',
                    name: 'record-count',
                    checked: formState.recordCount === 0.5 ? '' : undefined,
                    onchange: () => { formState.recordCount = 0.5; },
                  }),
                  el('div', {}, '0.5회'),
                ]),
              ]);

        host.replaceChildren(el('div', { class: 'form-field' }, [el('label', {}, '근로자'), select]), timeSection);
      }

      async function submit(workers, closeFn, onDone) {
        if (formState.workerId == null) return;
        const pad = (n) => String(n).padStart(2, '0');
        const dateStr = `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
        const clockIn = `${dateStr}T${pad(formState.clockInHour)}:${pad(formState.clockInMinute)}`;
        const clockOut =
          formState.paymentType === 'COUNT' ? clockIn : `${dateStr}T${pad(formState.clockOutHour)}:${pad(formState.clockOutMinute)}`;
        try {
          await payrollApi.addRecord(
            workplace.id,
            formState.workerId,
            clockIn,
            clockOut,
            formState.paymentType === 'COUNT' ? formState.recordCount : undefined,
          );
          toast('추가되었습니다.', 'success');
          closeFn();
          onDone();
        } catch (e) {
          toast(`추가 실패: ${e.message}`, 'error');
        }
      }
    },
  });
}

function formatDateLabel(date) {
  const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  const pad = (n) => String(n).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} (${weekdays[date.getDay()]})`;
}
