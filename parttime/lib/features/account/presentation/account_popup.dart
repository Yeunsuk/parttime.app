import 'account_popup_stub.dart'
    if (dart.library.html) 'account_popup_web.dart' as impl;

// 계좌 화면을 별도 브라우저 창(팝업)으로 연다. 웹이 아닌 플랫폼에서는 false를
// 반환하므로, 호출한 쪽에서 일반 화면 이동으로 대체해야 한다.
bool openAccountPopup(String url) => impl.openPopupWindow(url);
