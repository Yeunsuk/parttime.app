import 'dart:convert';

import 'package:flutter/material.dart';
import '../domain/account_model.dart';
import 'account_cards.dart';

// 좌측 상단 '계좌' 버튼으로 여는 팝업 창 전용 화면. 로그인이나 API 호출 없이,
// URL에 그대로 담아 전달받은 계좌 데이터만 보여준다 — 팝업이 앱을 통째로 다시
// 로딩하고 인증을 거칠 필요가 없도록 하기 위함이다.
class AccountPopupScreen extends StatelessWidget {
  final String workplaceName;
  final List<AccountModel> accounts;

  const AccountPopupScreen({
    super.key,
    required this.workplaceName,
    required this.accounts,
  });

  // data 쿼리 파라미터(계좌 목록을 JSON 직렬화 후 base64url로 인코딩한 문자열)를
  // 디코딩한다. 형식이 잘못됐으면 빈 목록으로 취급한다.
  factory AccountPopupScreen.fromEncoded({
    required String workplaceName,
    required String encoded,
  }) {
    List<AccountModel> accounts = const [];
    try {
      final jsonStr = utf8.decode(base64Url.decode(encoded));
      final list = jsonDecode(jsonStr) as List;
      accounts = list
          .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      accounts = const [];
    }
    return AccountPopupScreen(workplaceName: workplaceName, accounts: accounts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$workplaceName 계좌')),
      body: AccountCards(accounts: accounts),
    );
  }
}
