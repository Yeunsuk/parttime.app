import { authApi } from '../apis/auth-api.js';
import { storage } from '../storage.js';
import { state } from '../state.js';
import { navigate } from '../router.js';
import { el } from '../utils.js';

export async function renderSignup(root) {
  let role = 'WORKER';

  const emailInput = el('input', { type: 'text', placeholder: '아이디', autocomplete: 'username' });
  const passwordInput = el('input', {
    type: 'password',
    placeholder: '비밀번호 (6자 이상)',
    autocomplete: 'new-password',
  });
  const nameInput = el('input', { type: 'text', placeholder: '이름' });
  const ownerCodeInput = el('input', { type: 'text', placeholder: '사장 인증코드' });
  const ownerCodeField = el('div', { class: 'form-field hidden' }, [
    el('label', {}, '사장 인증코드'),
    ownerCodeInput,
  ]);
  const errorBox = el('div', { class: 'form-error hidden' });

  const workerTile = el('button', { type: 'button', class: 'role-tile role-tile--selected' }, '알바생');
  const ownerTile = el('button', { type: 'button', class: 'role-tile' }, '사장님');

  function selectRole(newRole) {
    role = newRole;
    workerTile.classList.toggle('role-tile--selected', role === 'WORKER');
    ownerTile.classList.toggle('role-tile--selected', role === 'OWNER');
    ownerCodeField.classList.toggle('hidden', role !== 'OWNER');
  }
  workerTile.addEventListener('click', () => selectRole('WORKER'));
  ownerTile.addEventListener('click', () => selectRole('OWNER'));

  const submitBtn = el('button', { class: 'btn btn--primary btn--block', type: 'submit' }, '회원가입');

  const form = el(
    'form',
    {
      class: 'auth-form',
      onsubmit: async (e) => {
        e.preventDefault();
        errorBox.classList.add('hidden');
        submitBtn.disabled = true;
        try {
          const email = emailInput.value.trim();
          const password = passwordInput.value;
          const res = await authApi.signup({
            email,
            password,
            name: nameInput.value.trim(),
            role,
            ownerAuthCode: role === 'OWNER' ? ownerCodeInput.value.trim() : undefined,
          });
          storage.saveToken(res.accessToken);
          storage.saveRefreshToken(res.refreshToken);
          storage.saveLastCredentials(email, password);
          state.currentUser = res.user;
          navigate(res.user.role === 'OWNER' ? '/owner/home' : '/worker/home');
        } catch (err) {
          errorBox.textContent = err.message || '회원가입에 실패했습니다.';
          errorBox.classList.remove('hidden');
        } finally {
          submitBtn.disabled = false;
        }
      },
    },
    [
      el('div', { class: 'role-tiles' }, [workerTile, ownerTile]),
      el('div', { class: 'form-field' }, [el('label', {}, '아이디'), emailInput]),
      el('div', { class: 'form-field' }, [el('label', {}, '비밀번호'), passwordInput]),
      el('div', { class: 'form-field' }, [el('label', {}, '이름'), nameInput]),
      ownerCodeField,
      errorBox,
      submitBtn,
    ],
  );

  root.replaceChildren(
    el('div', { class: 'auth-page' }, [
      el('div', { class: 'auth-card' }, [
        el('div', { class: 'auth-title' }, '알바시간'),
        el('div', { class: 'auth-subtitle' }, '회원가입'),
        form,
        el('div', { class: 'auth-footer' }, ['이미 계정이 있으신가요? ', el('a', { href: '#/login' }, '로그인')]),
      ]),
    ]),
  );
}
