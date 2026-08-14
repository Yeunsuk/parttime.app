import 'package:dio/dio.dart';
import '../domain/account_model.dart';

class AccountApi {
  final Dio _dio;
  AccountApi(this._dio);

  // 근무지 계좌 목록 (사장 전용)
  Future<List<AccountModel>> getAccounts(int workplaceId) async {
    final res = await _dio.get('/workplaces/$workplaceId/accounts');
    return (res.data as List)
        .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 계좌 추가 (사장 전용)
  Future<AccountModel> create(
    int workplaceId,
    String accountName,
    String accountNumber,
    String bankName,
  ) async {
    final res = await _dio.post(
      '/workplaces/$workplaceId/accounts',
      data: {
        'accountName': accountName,
        'accountNumber': accountNumber,
        'bankName': bankName,
      },
    );
    return AccountModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 계좌에 QR 추가 (사장 전용): 은행/간편결제 앱마다 QR 규격이 달라 이름을 붙여 구분한다
  Future<AccountModel> addQr(
      int workplaceId, int accountId, String name, String qrImage) async {
    final res = await _dio.post(
      '/workplaces/$workplaceId/accounts/$accountId/qrs',
      data: {'name': name, 'qrImage': qrImage},
    );
    return AccountModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 계좌 QR 삭제 (사장 전용)
  Future<AccountModel> deleteQr(int workplaceId, int accountId, int qrId) async {
    final res = await _dio
        .delete('/workplaces/$workplaceId/accounts/$accountId/qrs/$qrId');
    return AccountModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 계좌 삭제 (사장 전용)
  Future<void> delete(int workplaceId, int accountId) async {
    await _dio.delete('/workplaces/$workplaceId/accounts/$accountId');
  }
}
