import { state } from './state.js';

const routes = {};
let notFoundHandler = null;

// path: '/owner/home' 같은 해시 경로. meta.public이면 로그인 여부와 무관하게 접근 가능
// (Flutter GoRouter의 isAuthRoute/isSplash/isAccountPopup과 동일한 개념).
// meta.role이 있으면 그 role의 로그인 사용자만 접근 가능하고, 아니면 자기 홈으로 보낸다.
export function registerRoute(path, render, meta = {}) {
  routes[path] = { render, meta };
}

export function setNotFoundHandler(fn) {
  notFoundHandler = fn;
}

export function navigate(path) {
  if (window.location.hash.slice(1) === path) {
    // 같은 경로로 다시 navigate하면 hashchange가 안 뜨므로 직접 다시 그린다.
    handleRouteChange();
  } else {
    window.location.hash = path;
  }
}

function parseHash() {
  const raw = window.location.hash.slice(1) || '/splash';
  const [pathPart, queryPart] = raw.split('?');
  return { path: pathPart, params: new URLSearchParams(queryPart || '') };
}

function homeFor(role) {
  return role === 'OWNER' ? '/owner/home' : '/worker/home';
}

async function handleRouteChange() {
  const { path, params } = parseHash();
  const route = routes[path];

  if (!route) {
    if (path === '/splash') {
      // app.js의 bootstrap()이 startRouter()를 호출하기 전에 세션 복원을 먼저
      // await하므로, 여기 도달한 시점엔 이미 state.currentUser가 확정돼 있다 —
      // 곧장 로그인 화면이나 역할별 홈으로 보내고, splash는 그 사이 깜빡임을
      // 가리는 용도로만 잠깐 그린다.
      renderSplash();
      navigate(state.currentUser ? homeFor(state.currentUser.role) : '/login');
      return;
    }
    if (notFoundHandler) {
      notFoundHandler(getRoot());
    }
    return;
  }

  const { render, meta } = route;

  if (meta.public) {
    // 이미 로그인된 사용자가 로그인/회원가입 화면으로 가려 하면 자기 홈으로 돌려보낸다.
    if ((path === '/login' || path === '/signup') && state.currentUser) {
      navigate(homeFor(state.currentUser.role));
      return;
    }
  } else {
    if (!state.currentUser) {
      navigate('/login');
      return;
    }
    if (meta.role && state.currentUser.role !== meta.role) {
      navigate(homeFor(state.currentUser.role));
      return;
    }
  }

  const root = getRoot();
  try {
    await render(root, params);
  } catch (e) {
    console.error('[router] render failed:', e);
    root.innerHTML = `<div class="page"><p class="error-text">화면을 불러오지 못했습니다: ${e.message || e}</p></div>`;
  }
}

function getRoot() {
  return document.getElementById('app');
}

function renderSplash() {
  getRoot().innerHTML = `
    <div class="splash">
      <div class="splash__icon">💼</div>
      <div class="splash__title">알바시간</div>
      <div class="splash__loading">로딩중...</div>
    </div>`;
}

export function startRouter() {
  window.addEventListener('hashchange', handleRouteChange);
  handleRouteChange();
}

export { handleRouteChange as refreshCurrentRoute };
