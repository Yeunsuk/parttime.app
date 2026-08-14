import { el } from '../utils.js';

// Flutter의 showDialog(AlertDialog)에 대응하는 범용 모달.
// render({body, footer, close})가 실제 내용을 채운다.
export function openModal({ title, render, wide }) {
  const titleEl = el('div', { class: 'modal-title' }, title);
  const bodyEl = el('div', { class: 'modal-body' });
  const footerEl = el('div', { class: 'modal-footer' });
  const box = el('div', { class: `modal-box ${wide ? 'modal-box--wide' : ''}` }, [titleEl, bodyEl, footerEl]);
  const backdrop = el('div', { class: 'modal-backdrop' }, [box]);

  const close = () => backdrop.remove();
  backdrop.addEventListener('mousedown', (e) => {
    if (e.target === backdrop) close();
  });

  document.body.append(backdrop);
  render({ body: bodyEl, footer: footerEl, close });
  return close;
}

export function modalCloseButton(label = '닫기') {
  return (close) => el('button', { class: 'btn btn--ghost', onclick: close }, label);
}
