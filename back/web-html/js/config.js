// 백엔드 API 주소. Flutter 앱(parttime/lib/core/constants/api_constants.dart)과 동일한
// 서버를 바라본다 — 같은 백엔드를 대상으로 한 대체 구현이므로 주소를 반드시 맞춰야 한다.
// 이 자리표시자는 api/Dockerfile 빌드 단계에서 API_BASE_URL 빌드 인자로 치환된다.
// 로컬에서 python -m http.server 등으로 바로 열면(치환 안 됨) 이 기본값이 쓰인다.
const _RAW_API_BASE_URL = '__API_BASE_URL__';
export const API_BASE_URL = _RAW_API_BASE_URL.startsWith('__')
  ? 'http://localhost:8080/api'
  : _RAW_API_BASE_URL;

// Flutter 앱(parttime/lib/core/constants/app_version.dart)과 같은 값으로 수동으로 맞춰준다.
// 기능 단위 수정마다 마지막 숫자(patch)를 1씩 올린다 — major/minor는 별도 지시가 있을 때만 변경.
export const APP_VERSION = '1.3.3';

export const STORAGE_KEYS = {
  token: 'access_token',
  refreshToken: 'refresh_token',
  lastEmail: 'last_email',
  lastPassword: 'last_password',
};

// 근무지 시간설정에서 "현재시간"을 뜻하는 특수값 (Flutter의 TimeRow.currentTimeSentinel과 동일).
export const CURRENT_TIME_SENTINEL = -1;

export const WORKER_COLOR_PALETTE = [
  '#E53935', // red
  '#1E88E5', // blue
  '#43A047', // green
  '#FB8C00', // orange
  '#8E24AA', // purple
  '#00897B', // teal
  '#D81B60', // pink
  '#6D4C41', // brown
  '#3949AB', // indigo
  '#C0CA33', // lime
];
