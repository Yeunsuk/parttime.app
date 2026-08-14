import { api } from '../api.js';

export const authApi = {
  // 로그인/회원가입은 토큰이 없는 상태에서 호출되고, 이 요청 자체의 401(잘못된
  // 자격증명)을 세션 만료로 오인해 리프레시를 시도하면 안 되므로 auth: false로 보낸다.
  signup({ email, password, name, role, ownerAuthCode }) {
    return api.post('/auth/signup', { email, password, name, role, ownerAuthCode }, { auth: false });
  },
  login(email, password) {
    return api.post('/auth/login', { email, password }, { auth: false });
  },
  me() {
    return api.get('/auth/me');
  },
};
