import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/account_model.dart';

// "data:image/png;base64,..." 형태의 data URI에서 이미지 바이트만 뽑아낸다. 형식이
// 아니거나 디코딩에 실패하면 null을 반환한다.
Uint8List? decodeQrDataUri(String dataUri) {
  final commaIndex = dataUri.indexOf(',');
  if (commaIndex == -1) return null;
  try {
    return base64Decode(dataUri.substring(commaIndex + 1));
  } catch (_) {
    return null;
  }
}

// 계좌 QR 이미지를 이름과 함께 보여주는 칩. 탭하면 크게 볼 수 있다. 관리 화면
// (근무지 설정)과 조회 화면(계좌 목록)이 공용으로 쓴다. onDelete가 있으면 삭제
// 버튼이, 없으면 붙지 않는다.
class QrChip extends StatelessWidget {
  final AccountQrModel qr;
  final VoidCallback? onDelete;
  const QrChip({super.key, required this.qr, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final bytes = decodeQrDataUri(qr.qrImage);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: bytes == null
                ? null
                : () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(qr.name),
                        content: Image.memory(bytes),
                      ),
                    ),
            child: bytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.memory(bytes,
                        width: 32, height: 32, fit: BoxFit.cover),
                  )
                : const Icon(Icons.qr_code, size: 32),
          ),
          const SizedBox(width: 6),
          Text(qr.name, style: const TextStyle(fontSize: 12)),
          if (onDelete != null) ...[
            const SizedBox(width: 2),
            IconButton(
              icon: const Icon(Icons.close, size: 14),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}
