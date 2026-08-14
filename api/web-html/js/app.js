import { authApi } from './apis/auth-api.js';
import { storage } from './storage.js';
import { state } from './state.js';
import { registerRoute, startRouter, refreshCurrentRoute } from './router.js';
import { renderLogin } from './screens/login.js';
import { renderSignup } from './screens/signup.js';
import { renderWorkerHome } from './screens/worker-home.js';
import { renderWorkerCalendar } from './screens/worker-calendar.js';
import { renderWorkplace } from './screens/workplace.js';
import { renderOwnerHome } from './screens/owner-home.js';
import { renderWorkerDetail } from './screens/worker-detail.js';
import { renderSettlement } from './screens/settlement.js';
import { renderAccountPopup } from './screens/account-popup.js';

registerRoute('/login', renderLogin, { public: true });
registerRoute('/signup', renderSignup, { public: true });
registerRoute('/account-popup', renderAccountPopup, { public: true });

registerRoute('/worker/home', renderWorkerHome, { role: 'WORKER' });
registerRoute('/worker/calendar', renderWorkerCalendar, { role: 'WORKER' });
registerRoute('/worker/workplace', renderWorkplace, { role: 'WORKER' });

registerRoute('/owner/home', renderOwnerHome, { role: 'OWNER' });
registerRoute('/owner/worker-detail', renderWorkerDetail, { role: 'OWNER' });
registerRoute('/owner/settlement', renderSettlement, { role: 'OWNER' });

async function bootstrap() {
  if (storage.getToken()) {
    try {
      state.currentUser = await authApi.me();
    } catch {
      storage.clearAll();
      state.currentUser = null;
    }
  }
  startRouter();
}

bootstrap();

// 다른 화면(로그아웃 등)에서 세션이 바뀐 뒤 라우팅을 다시 계산하고 싶을 때 쓴다.
window.__refreshRoute = refreshCurrentRoute;
