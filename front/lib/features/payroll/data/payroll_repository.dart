import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/app_exception.dart';
import '../domain/payroll_model.dart';
import 'payroll_api.dart';

part 'payroll_repository.g.dart';

@riverpod
PayrollRepository payrollRepository(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return PayrollRepository(PayrollApi(dio));
}

class PayrollRepository {
  final PayrollApi _api;
  PayrollRepository(this._api);

  Future<List<PayrollDetailModel>> getWorkplaceRecords(
      int workplaceId, int year, int month) async {
    try {
      return await _api.getWorkplaceRecords(workplaceId, year, month);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<PayrollDetailModel>> getWorkerDetail(
      int workplaceId, int workerId, int year, int month) async {
    try {
      return await _api.getWorkerDetail(workplaceId, workerId, year, month);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PayrollDetailModel> modifyRecord(
      int recordId, String clockIn, String clockOut) async {
    try {
      return await _api.modifyRecord(recordId, clockIn, clockOut);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PayrollDetailModel> addRecord(int workplaceId, int workerId,
      String clockIn, String clockOut, double? recordCount) async {
    try {
      return await _api.addRecord(
          workplaceId, workerId, clockIn, clockOut, recordCount);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteRecord(int recordId) async {
    try {
      await _api.deleteRecord(recordId);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<SettlementModel>> getSettlement(
      int workplaceId, int year, int month) async {
    try {
      return await _api.getSettlement(workplaceId, year, month);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const UnauthorizedException();
    final message =
        e.response?.data?['message'] as String? ?? e.message ?? '알 수 없는 오류';
    return ServerException(message: message, statusCode: statusCode);
  }
}
