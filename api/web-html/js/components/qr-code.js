// vendor/qrcode.js + vendor/qrcode_UTF8.js는 index.html에서 일반 <script>로 먼저
// 로드되어 전역 window.qrcode를 만든다 (kazuhikoarase/qrcode-generator, MIT).
// Flutter의 QrPainter(version: QrVersions.auto)와 동일하게 typeNumber=0(자동)을 쓴다.
export function generateQrDataUrl(text, { cellSize = 6, margin = 4 } = {}) {
  const qr = window.qrcode(0, 'M');
  qr.addData(text);
  qr.make();
  return qr.createDataURL(cellSize, margin);
}
