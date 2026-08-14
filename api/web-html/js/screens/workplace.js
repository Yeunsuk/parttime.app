import { workplaceApi } from '../apis/workplace-api.js';
import { state } from '../state.js';
import { renderCreateOrJoinForm } from '../components/workplace-gate.js';
import { el } from '../utils.js';

export async function renderWorkplace(root) {
  const role = state.currentUser?.role;

  const header = el('div', { class: 'app-bar' }, [
    el('button', { class: 'icon-btn', onclick: () => window.history.back() }, '←'),
    el('div', { class: 'app-bar__title' }, '근무지 관리'),
  ]);
  const body = el('div', { class: 'page' }, [el('div', { class: 'loading' }, '불러오는 중...')]);
  root.replaceChildren(el('div', { class: 'screen' }, [header, body]));

  await load(body, role);
}

async function load(body, role) {
  let workplaces;
  try {
    workplaces = await workplaceApi.getMyWorkplaces();
  } catch (e) {
    body.replaceChildren(el('p', { class: 'error-text' }, `오류: ${e.message}`));
    return;
  }

  if (workplaces.length === 0) {
    renderEmptyAndForm(body, role);
    return;
  }

  renderList(body, workplaces, role);
}

function renderEmptyAndForm(body, role) {
  const empty = el(
    'div',
    { class: 'empty-state' },
    role === 'OWNER'
      ? '아직 만든 근무지가 없어요.\n아래에서 근무지를 만들어보세요.'
      : '아직 참가한 근무지가 없어요.\n아래에서 초대코드를 입력해주세요.',
  );
  const formHost = el('div', { class: 'workplace-form-host' });
  body.replaceChildren(el('div', { class: 'page' }, [empty, formHost]));
  renderCreateOrJoinForm(formHost, role === 'OWNER', () => load(body, role));
}

function renderList(body, workplaces, role) {
  const isMultiple = workplaces.length > 1;

  const items = workplaces.map((w) => {
    const isSelected = workplaces.length === 1 || w.id === state.selectedWorkplaceId;
    return el(
      'button',
      {
        class: `list-card list-card--button workplace-item ${isSelected ? 'workplace-item--selected' : ''}`,
        onclick: () => {
          state.selectedWorkplaceId = w.id;
          renderList(body, workplaces, role);
        },
      },
      [
        el('div', {}, [
          el('div', { class: 'list-card__title' }, w.name),
          el('div', { class: 'list-card__sub' }, `사장: ${w.ownerName} · 시급 ${w.hourlyWage}원`),
          el('div', { class: 'list-card__sub' }, `초대코드: ${w.inviteCode}`),
        ]),
        isSelected ? el('span', { class: 'workplace-item__check' }, '✓') : null,
      ],
    );
  });

  const addBtn = el(
    'button',
    {
      class: 'btn btn--primary btn--block',
      onclick: () => openAddForm(body, workplaces, role),
    },
    role === 'OWNER' ? '+ 근무지 생성' : '+ 초대코드로 참가',
  );

  body.replaceChildren(
    el('div', { class: 'page' }, [
      el('div', { class: 'card-list' }, items),
      addBtn,
      el('div', { class: 'workplace-form-host hidden', id: 'workplace-add-form' }),
    ]),
  );

  if (!isMultiple) {
    // 근무지가 1개뿐이면 항상 선택된 것으로 취급한다 (Flutter의 isSelected 규칙과 동일).
    state.selectedWorkplaceId = workplaces[0].id;
  }
}

function openAddForm(body, workplaces, role) {
  const host = body.querySelector('#workplace-add-form');
  if (!host) return;
  host.classList.remove('hidden');
  renderCreateOrJoinForm(host, role === 'OWNER', () => load(body, role));
  host.scrollIntoView({ behavior: 'smooth', block: 'start' });
}
