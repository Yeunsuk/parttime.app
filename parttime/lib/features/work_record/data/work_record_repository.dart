import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/app_exception.dart';
import '../domain/work_record_model.dart';
import 'work_record_api.dart';

part 'work_record_repository.g.dart';

@riverpod
WorkRecordRepository workRecordRepository(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return WorkRecordRepository(WorkRecordApi(dio));
}

class WorkRecordRepository {
  final WorkRecordApi _api;
  WorkRecordRepository(this._api);

  Future<WorkStatusModel> getStatus() async {
    try {
      return await _api.getStatus();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkRecordModel> clockIn(int workplaceId) async {
    try {
      return await _api.clockIn(workplaceId);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkRecordModel> clockOut(int recordId) async {
    try {
      return await _api.clockOut(recordId);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<WorkRecordModel>> getCalendar(int year, int month) async {
    try {
      return await _api.getCalendar(year, month);
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
