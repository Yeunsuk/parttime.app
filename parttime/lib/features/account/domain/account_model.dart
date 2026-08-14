import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_model.freezed.dart';
part 'account_model.g.dart';

// 근무지 계좌 1건. 은행/간편결제 앱마다 QR 규격이 달라 여러 개를 이름으로
// 구분해 등록할 수 있다(qrCodes).
@freezed
abstract class AccountModel with _$AccountModel {
  const factory AccountModel({
    required int id,
    required String accountName,
    required String accountNumber,
    required String bankName,
    @Default(<AccountQrModel>[]) List<AccountQrModel> qrCodes,
  }) = _AccountModel;

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);
}

// 계좌에 등록된 QR 1건. qrImage는 "data:image/png;base64,..." 형태의 data URI.
@freezed
abstract class AccountQrModel with _$AccountQrModel {
  const factory AccountQrModel({
    required int id,
    required String name,
    required String qrImage,
  }) = _AccountQrModel;

  factory AccountQrModel.fromJson(Map<String, dynamic> json) =>
      _$AccountQrModelFromJson(json);
}
