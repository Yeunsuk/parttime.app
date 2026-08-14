import { STORAGE_KEYS } from './config.js';

// Flutter의 flutter_secure_storage(암호화 저장)와 달리 그냥 localStorage를 쓴다 —
// 이 앱은 "동일 기능 검증용 대체 구현"이 목적이라 토큰 저장 방식의 보안 수준까지
// 완전히 맞출 필요는 없다고 판단했다.
export const storage = {
  getToken: () => localStorage.getItem(STORAGE_KEYS.token),
  saveToken: (t) => localStorage.setItem(STORAGE_KEYS.token, t),
  deleteToken: () => localStorage.removeItem(STORAGE_KEYS.token),

  getRefreshToken: () => localStorage.getItem(STORAGE_KEYS.refreshToken),
  saveRefreshToken: (t) => localStorage.setItem(STORAGE_KEYS.refreshToken, t),
  deleteRefreshToken: () => localStorage.removeItem(STORAGE_KEYS.refreshToken),

  saveLastCredentials(email, password) {
    localStorage.setItem(STORAGE_KEYS.lastEmail, email);
    localStorage.setItem(STORAGE_KEYS.lastPassword, password);
  },
  getLastEmail: () => localStorage.getItem(STORAGE_KEYS.lastEmail),
  getLastPassword: () => localStorage.getItem(STORAGE_KEYS.lastPassword),

  getWorkerColorOverrides(workplaceId) {
    const raw = localStorage.getItem(`worker_color_overrides_${workplaceId}`);
    if (!raw) return {};
    try {
      return JSON.parse(raw);
    } catch {
      return {};
    }
  },
  saveWorkerColorOverride(workplaceId, workerId, colorIndex) {
    const current = storage.getWorkerColorOverrides(workplaceId);
    current[workerId] = colorIndex;
    localStorage.setItem(`worker_color_overrides_${workplaceId}`, JSON.stringify(current));
  },

  clearAll() {
    localStorage.removeItem(STORAGE_KEYS.token);
    localStorage.removeItem(STORAGE_KEYS.refreshToken);
  },
};
