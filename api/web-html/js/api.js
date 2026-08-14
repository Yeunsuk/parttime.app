import { API_BASE_URL } from './config.js';
import { storage } from './storage.js';

export class ApiError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
  }
}

// 동시에 여러 요청이 401을 받아도 리프레시는 한 번만 수행되도록 진행 중인 Promise를
// 공유한다 (Flutter dio_client.dart의 refreshFuture와 동일한 목적).
let refreshPromise = null;

async function refreshAccessToken() {
  if (refreshPromise) return refreshPromise;
  refreshPromise = (async () => {
    const refreshToken = storage.getRefreshToken();
    if (!refreshToken) {
      return null;
    }

    try {
      const res = await fetch(`${API_BASE_URL}/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      });
      if (!res.ok) {
        throw new Error('refresh failed');
      }

      const body = await res.json();
      const data = body.data;
      storage.saveToken(data.accessToken);
      storage.saveRefreshToken(data.refreshToken);
      return data.accessToken;
    } catch {
      // 리프레시 자체가 실패하면 두 토큰 모두 지워 완전 로그아웃 상태로 만든다.
      storage.deleteToken();
      storage.deleteRefreshToken();
      return null;
    }
  })().finally(() => {
    refreshPromise = null;
  });
  return refreshPromise;
}

function buildQuery(params) {
  if (!params) return '';
  const usp = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) {
    if (v !== undefined && v !== null) usp.set(k, String(v));
  }
  const qs = usp.toString();
  return qs ? `?${qs}` : '';
}

// 백엔드는 모든 응답을 ApiResponse { success, data, message }로 감싸서 보낸다.
// 여기서 한 번만 벗겨내고, 실패 시 message를 담은 ApiError를 던진다.
async function request(path, { method = 'GET', body, query, auth = true } = {}, isRetry = false) {
  const headers = { 'Content-Type': 'application/json' };
  if (auth) {
    const token = storage.getToken();
    if (token) headers['Authorization'] = `Bearer ${token}`;
  }

  let res;
  try {
    res = await fetch(`${API_BASE_URL}${path}${buildQuery(query)}`, {
      method,
      headers,
      body: body !== undefined ? JSON.stringify(body) : undefined,
    });
  } catch {
    throw new ApiError('네트워크 오류가 발생했습니다. 연결 상태를 확인해주세요.', 0);
  }

  if (res.status === 401 && auth && !isRetry) {
    const newToken = await refreshAccessToken();
    if (newToken) {
      return request(path, { method, body, query, auth }, true);
    }
    throw new ApiError('로그인이 만료되었습니다. 다시 로그인해주세요.', 401);
  }

  let parsed = null;
  try {
    parsed = await res.json();
  } catch {
    // 본문이 없는 응답(예: 204)일 수 있다.
  }

  if (!res.ok) {
    const message = parsed?.message || `요청이 실패했습니다. (${res.status})`;
    throw new ApiError(message, res.status);
  }

  return parsed ? parsed.data : null;
}

export const api = {
  get: (path, query, opts) => request(path, { method: 'GET', query, ...opts }),
  post: (path, body, opts) => request(path, { method: 'POST', body, ...opts }),
  patch: (path, body, opts) => request(path, { method: 'PATCH', body, ...opts }),
  delete: (path, opts) => request(path, { method: 'DELETE', ...opts }),
};
