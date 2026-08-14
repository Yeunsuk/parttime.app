import 'dart:html' as html;

// 브라우저의 window.open으로 실제 별도 창(팝업)을 띄운다. 기존 창은 그대로 유지되고,
// 새 창은 자체적으로 위치 이동/크기 조절 등 독립적인 컨트롤이 가능하다.
bool openPopupWindow(String url) {
  html.window.open(
    url,
    'parttime_account_popup',
    'width=420,height=720,resizable=yes,scrollbars=yes',
  );
  return true;
}
