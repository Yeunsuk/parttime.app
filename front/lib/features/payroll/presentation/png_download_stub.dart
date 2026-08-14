import 'dart:typed_data';

// 웹이 아닌 플랫폼(모바일/데스크톱 네이티브)에서는 브라우저 다운로드 개념이 없으므로
// 아무 것도 하지 않는다 — 호출한 쪽에서 false를 받으면 안내 메시지로 대체한다.
bool downloadPngBytes(Uint8List bytes, String filename) => false;
