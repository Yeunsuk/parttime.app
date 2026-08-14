import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/app_exception.dart';
import '../domain/workplace_model.dart';
import 'workplace_api.dart';

part 'workplace_repository.g.dart';

@riverpod
WorkplaceRepository workplaceRepository(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return WorkplaceRepository(WorkplaceApi(dio));
}

class WorkplaceRepository {
  final WorkplaceApi _api;
  WorkplaceRepository(this._api);

  Future<List<WorkplaceModel>> getMyWorkplaces() async {
    try {
      return await _api.getMyWorkplaces();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkplaceModel> create(String name, int hourlyWage) async {
    try {
      return await _api.create(name, hourlyWage);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkplaceModel> join(String inviteCode) async {
    try {
      return await _api.join(inviteCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<WorkerModel>> getWorkers(int workplaceId) async {
    try {
      return await _api.getWorkers(workplaceId);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkplaceModel> updateMemberLimit(int workplaceId, int memberLimit) async {
    try {
      return await _api.updateMemberLimit(workplaceId, memberLimit);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkplaceModel> updateDisabledHours(
      int workplaceId, List<int> disabledHours) async {
    try {
      return await _api.updateDisabledHours(workplaceId, disabledHours);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkplaceModel> updateEnabledMinutes(
      int workplaceId, List<int> enabledMinutes) async {
    try {
      return await _api.updateEnabledMinutes(workplaceId, enabledMinutes);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkerModel> addMember(int workplaceId, String employeeId) async {
    try {
      return await _api.addMember(workplaceId, employeeId);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> removeMember(int workplaceId, int workerId) async {
    try {
      await _api.removeMember(workplaceId, workerId);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkerModel> updateDefaultTime(
    int workplaceId,
    int workerId,
    int clockInHour,
    int clockInMinute,
    int clockOutHour,
    int clockOutMinute,
  ) async {
    try {
      return await _api.updateDefaultTime(
          workplaceId, workerId, clockInHour, clockInMinute, clockOutHour, clockOutMinute);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkerModel> updatePayPeriod(
      int workplaceId, int workerId, int payPeriodStartDay) async {
    try {
      return await _api.updatePayPeriod(workplaceId, workerId, payPeriodStartDay);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkerModel> updatePaymentType(
      int workplaceId, int workerId, String paymentType) async {
    try {
      return await _api.updatePaymentType(workplaceId, workerId, paymentType);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<WorkerModel> updateWorkingDays(
      int workplaceId, int workerId, bool enabled, List<int> days) async {
    try {
      return await _api.updateWorkingDays(workplaceId, workerId, enabled, days);
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
