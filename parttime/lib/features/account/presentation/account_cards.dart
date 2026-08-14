import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/account_model.dart';
import 'qr_chip.dart';

// 계좌 카드 목록(계좌주/은행명/계좌번호 + QR). 실시간 조회 화면과, 로그인 없이
// 데이터를 URL로 그대로 넘겨받는 팝업 화면이 함께 쓴다.
class AccountCards extends StatelessWidget {
  final List<AccountModel> accounts;
  const AccountCards({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const Center(child: Text('등록된 계좌가 없습니다.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final a = accounts[i];
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.accountName,
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                '${a.bankName} ${a.accountNumber}',
                style: const TextStyle(
                    fontSize: 18, color: AppColors.textSecondary),
              ),
              if (a.qrCodes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: a.qrCodes.map((qr) => QrChip(qr: qr)).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
