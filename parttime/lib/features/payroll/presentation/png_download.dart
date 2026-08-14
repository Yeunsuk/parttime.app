import 'dart:typed_data';

import 'png_download_stub.dart' if (dart.library.html) 'png_download_web.dart' as impl;

// PNG 바이트를 파일로 다운로드한다. 웹이 아닌 플랫폼에서는 false를 반환하므로
// 호출한 쪽에서 안내 메시지 등으로 대체해야 한다.
bool downloadPng(Uint8List bytes, String filename) => impl.downloadPngBytes(bytes, filename);
