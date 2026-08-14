import 'dart:html' as html;
import 'dart:typed_data';

// PNG 바이트를 Blob으로 만들어 브라우저가 파일로 내려받게 한다(임시 <a download> 클릭).
bool downloadPngBytes(Uint8List bytes, String filename) {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
  return true;
}
