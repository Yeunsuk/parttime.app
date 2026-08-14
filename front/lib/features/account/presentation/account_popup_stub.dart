// 웹이 아닌 플랫폼(모바일/데스크톱 네이티브)에서는 별도 브라우저 창 개념이 없으므로
// 아무 것도 하지 않는다 — 호출한 쪽에서 false를 받으면 일반 화면 이동으로 대체한다.
bool openPopupWindow(String url) => false;
