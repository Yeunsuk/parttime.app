import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/app_exception.dart';
import '../domain/account_model.dart';
import 'account_api.dart';

part 'account_repository.g.dart';

@riverpod
AccountRepository accountRepository(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return AccountRepository(AccountApi(dio));
}

class AccountRepository {
  final AccountApi _api;
  AccountRepository(this._api);

  Future<List<AccountModel>> getAccounts(int workplaceId) async {
    try {
      return await _api.getAccounts(workplaceId);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AccountModel> create(
    int workplaceId,
    String accountName,
    String accountNumber,
    String bankName,
  ) async {
    try {
      return await _api.create(workplaceId, accountName, accountNumber, bankName);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AccountModel> addQr(
      int workplaceId, int accountId, String name, String qrImage) async {
    try {
      return await _api.addQr(workplaceId, accountId, name, qrImage);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AccountModel> deleteQr(int workplaceId, int accountId, int qrId) async {
    try {
      return await _api.deleteQr(workplaceId, accountId, qrId);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> delete(int workplaceId, int accountId) async {
    try {
      await _api.delete(workplaceId, accountId);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const UnauthorizedException();
    final message = e.response?.data?['message'] as String? ?? e.message ?? '알 수 없는 오류';
    return ServerException(message: message, statusCode: statusCode);
  }
}
