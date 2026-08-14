import { openModal } from '../components/modal.js';
import { el } from '../utils.js';

// '계좌' 팝업 전용 화면. 로그인이나 API 호출 없이, URL에 그대로 담겨온 계좌 데이터만
// 디코딩해서 보여준다 (owner-home.js의 openAccountPopup이 만든 링크로만 진입한다).
export async function renderAccountPopup(root, params) {
  const workplaceName = params.get('workplaceName') || '';
  const encoded = params.get('data') || '';

  let accounts = [];
  try {
    const b64 = encoded.replaceAll('-', '+').replaceAll('_', '/');
    const jsonStr = decodeURIComponent(escape(atob(b64)));
    accounts = JSON.parse(jsonStr);
  } catch {
    accounts = [];
  }

  const header = el('div', { class: 'app-bar' }, [el('div', { class: 'app-bar__title' }, `${workplaceName} 계좌`)]);

  const body =
    accounts.length === 0
      ? el('div', { class: 'empty-state' }, '등록된 계좌가 없습니다.')
      : el('div', { class: 'page account-popup-page' }, accounts.map((a) => renderAccountCard(a)));

  root.replaceChildren(el('div', { class: 'screen' }, [header, body]));
}

function renderAccountCard(account) {
  const qrRow =
    account.qrCodes && account.qrCodes.length > 0
      ? el(
          'div',
          { class: 'qr-chip-row' },
          account.qrCodes.map((qr) =>
            el('button', { class: 'qr-chip qr-chip--popup', onclick: () => openQrPreview(qr) }, [
              el('img', { src: qr.qrImage, alt: qr.name, class: 'qr-chip__img qr-chip__img--lg' }),
              el('span', { class: 'qr-chip__name' }, qr.name),
            ]),
          ),
        )
      : null;

  return el('div', { class: 'card account-popup-card' }, [
    el('div', { class: 'account-popup-card__name' }, account.accountName),
    el('div', { class: 'account-popup-card__number' }, `${account.bankName} ${account.accountNumber}`),
    qrRow,
  ]);
}

function openQrPreview(qr) {
  openModal({
    title: qr.name,
    render: ({ body, footer, close }) => {
      body.append(el('img', { src: qr.qrImage, alt: qr.name, class: 'qr-preview-img' }));
      footer.append(el('button', { class: 'btn btn--ghost', onclick: close }, '닫기'));
    },
  });
}
