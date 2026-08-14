import { authApi } from '../apis/auth-api.js';
import { storage } from '../storage.js';
import { state } from '../state.js';
import { navigate } from '../router.js';
import { APP_VERSION } from '../config.js';
import { el } from '../utils.js';

export async function renderLogin(root) {
  const lastEmail = storage.getLastEmail() || '';
  const lastPassword = storage.getLastPassword() || '';

  const emailInput = el('input', {
    type: 'text',
    placeholder: '아이디',
    value: lastEmail,
    autocomplete: 'username',
  });
  const passwordInput = el('input', {
    type: 'password',
    placeholder: '비밀번호',
    value: lastPassword,
    autocomplete: 'current-password',
  });
  const errorBox = el('div', { class: 'form-error hidden' });
  const submitBtn = el('button', { class: 'btn btn--primary btn--block', type: 'submit' }, '로그인');

  const form = el(
    'form',
    {
      class: 'auth-form',
      onsubmit: async (e) => {
        e.preventDefault();
        errorBox.classList.add('hidden');
        submitBtn.disabled = true;
        submitBtn.textContent = '로그인 중...';
        try {
          const email = emailInput.value.trim();
          const password = passwordInput.value;
          const res = await authApi.login(email, password);
          storage.saveToken(res.accessToken);
          storage.saveRefreshToken(res.refreshToken);
          storage.saveLastCredentials(email, password);
          state.currentUser = res.user;
          navigate(res.user.role === 'OWNER' ? '/owner/home' : '/worker/home');
        } catch (err) {
          errorBox.textContent = err.message || '로그인에 실패했습니다.';
          errorBox.classList.remove('hidden');
        } finally {
          submitBtn.disabled = false;
          submitBtn.textContent = '로그인';
        }
      },
    },
    [
      el('div', { class: 'form-field' }, [el('label', {}, '아이디'), emailInput]),
      el('div', { class: 'form-field' }, [el('label', {}, '비밀번호'), passwordInput]),
      errorBox,
      submitBtn,
    ],
  );

  root.replaceChildren(
    el('div', { class: 'auth-page' }, [
      el('div', { class: 'auth-card' }, [
        el('div', { class: 'auth-title' }, '알바시간'),
        el('div', { class: 'auth-subtitle' }, '로그인'),
        form,
        el('div', { class: 'auth-footer' }, ['계정이 없으신가요? ', el('a', { href: '#/signup' }, '회원가입')]),
        el('div', { class: 'auth-version' }, `v${APP_VERSION}`),
      ]),
    ]),
  );

  emailInput.focus();
}
