import { workplaceApi } from '../apis/workplace-api.js';
import { state } from '../state.js';
import { resolveWorkplace } from '../state.js';
import { el, toast } from '../utils.js';

// Flutter의 WorkplaceGate와 같은 역할을 한다.
// - 근무지가 0개면 생성(사장만)/참가 폼을 보여준다.
// - 2개 이상이고 아직 선택 안 됐으면 선택 UI를 보여준다.
// - 1개거나 선택이 끝나면 onResolved(workplace, allWorkplaces)를 호출해 실제 화면을 그리게 한다.
export async function renderWorkplaceGate(container, { allowCreate, onResolved }) {
  container.innerHTML = '<div class="loading">불러오는 중...</div>';

  let workplaces;
  try {
    workplaces = await workplaceApi.getMyWorkplaces();
  } catch (e) {
    container.innerHTML = `<p class="error-text">오류: ${e.message}</p>`;
    return;
  }

  const resolved = resolveWorkplace(workplaces, state.selectedWorkplaceId);
  if (resolved) {
    await onResolved(resolved, workplaces);
    return;
  }

  if (workplaces.length === 0) {
    renderCreateOrJoinForm(container, allowCreate, () =>
      renderWorkplaceGate(container, { allowCreate, onResolved }),
    );
    return;
  }

  renderPicker(container, workplaces, (picked) => {
    state.selectedWorkplaceId = picked.id;
    renderWorkplaceGate(container, { allowCreate, onResolved });
  });
}

function renderPicker(container, workplaces, onPick) {
  container.replaceChildren(
    el('div', { class: 'page centered' }, [
      el('h2', {}, '근무지를 선택하세요'),
      el(
        'div',
        { class: 'card-list' },
        workplaces.map((w) =>
          el(
            'button',
            { class: 'list-card list-card--button', onclick: () => onPick(w) },
            [el('div', { class: 'list-card__title' }, w.name), el('div', { class: 'list-card__sub' }, `초대코드 ${w.inviteCode}`)],
          ),
        ),
      ),
    ]),
  );
}

export function renderCreateOrJoinForm(container, allowCreate, onDone) {
  const inviteInput = el('input', { type: 'text', placeholder: '초대코드 입력' });
  const joinError = el('div', { class: 'form-error hidden' });
  const joinBtn = el('button', { class: 'btn btn--primary', type: 'submit' }, '참가하기');

  const joinForm = el(
    'form',
    {
      class: 'auth-form',
      onsubmit: async (e) => {
        e.preventDefault();
        joinError.classList.add('hidden');
        joinBtn.disabled = true;
        try {
          await workplaceApi.join(inviteInput.value.trim());
          toast('근무지에 참가했습니다.', 'success');
          onDone();
        } catch (err) {
          joinError.textContent = err.message || '참가에 실패했습니다.';
          joinError.classList.remove('hidden');
        } finally {
          joinBtn.disabled = false;
        }
      },
    },
    [el('div', { class: 'form-field' }, [el('label', {}, '초대코드'), inviteInput]), joinError, joinBtn],
  );

  const sections = [
    el('div', { class: 'card' }, [el('h3', {}, '초대코드로 참가'), joinForm]),
  ];

  if (allowCreate) {
    const nameInput = el('input', { type: 'text', placeholder: '근무지 이름' });
    const wageInput = el('input', { type: 'number', placeholder: '시급', min: '0' });
    const createError = el('div', { class: 'form-error hidden' });
    const createBtn = el('button', { class: 'btn btn--primary', type: 'submit' }, '근무지 만들기');

    const createForm = el(
      'form',
      {
        class: 'auth-form',
        onsubmit: async (e) => {
          e.preventDefault();
          createError.classList.add('hidden');
          createBtn.disabled = true;
          try {
            await workplaceApi.create(nameInput.value.trim(), Number(wageInput.value || 0));
            toast('근무지를 만들었습니다.', 'success');
            onDone();
          } catch (err) {
            createError.textContent = err.message || '생성에 실패했습니다.';
            createError.classList.remove('hidden');
          } finally {
            createBtn.disabled = false;
          }
        },
      },
      [
        el('div', { class: 'form-field' }, [el('label', {}, '근무지 이름'), nameInput]),
        el('div', { class: 'form-field' }, [el('label', {}, '시급'), wageInput]),
        createError,
        createBtn,
      ],
    );

    sections.push(el('div', { class: 'card' }, [el('h3', {}, '근무지 만들기'), createForm]));
  }

  container.replaceChildren(el('div', { class: 'page centered' }, [el('h2', {}, '소속된 근무지가 없습니다'), ...sections]));
}
