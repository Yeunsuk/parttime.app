import 'package:dio/dio.dart';
import '../domain/workplace_model.dart';

class WorkplaceApi {
  final Dio _dio;
  WorkplaceApi(this._dio);

  // 내 근무지 목록
  Future<List<WorkplaceModel>> getMyWorkplaces() async {
    final res = await _dio.get('/workplaces/my');
    return (res.data as List)
        .map((e) => WorkplaceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 근무지 생성 (사장)
  Future<WorkplaceModel> create(String name, int hourlyWage) async {
    final res = await _dio.post(
      '/workplaces',
      data: {'name': name, 'hourlyWage': hourlyWage},
    );
    return WorkplaceModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 초대코드로 참가 (알바생)
  Future<WorkplaceModel> join(String inviteCode) async {
    final res = await _dio.post(
      '/workplaces/join',
      data: {'inviteCode': inviteCode},
    );
    return WorkplaceModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 근무지 소속 근로자 목록 (사장 전용)
  Future<List<WorkerModel>> getWorkers(int workplaceId) async {
    final res = await _dio.get('/workplaces/$workplaceId/workers');
    return (res.data as List)
        .map((e) => WorkerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 근무지 인원제한 변경 (사장 전용)
  Future<WorkplaceModel> updateMemberLimit(int workplaceId, int memberLimit) async {
    final res = await _dio.patch(
      '/workplaces/$workplaceId/member-limit',
      data: {'memberLimit': memberLimit},
    );
    return WorkplaceModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 근무지 시간설정 변경 (사장 전용): 여기서 선택된 시(0~23)는 근무기록 생성/수정 시간
  // 목록에서 제외된다
  Future<WorkplaceModel> updateDisabledHours(
      int workplaceId, List<int> disabledHours) async {
    final res = await _dio.patch(
      '/workplaces/$workplaceId/disabled-hours',
      data: {'disabledHours': disabledHours},
    );
    return WorkplaceModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 근무지 분설정 변경 (사장 전용): 여기서 선택된 분(0~59)만 근무기록 생성/수정 시간
  // 목록에 표시된다 (기본값 0, 30분)
  Future<WorkplaceModel> updateEnabledMinutes(
      int workplaceId, List<int> enabledMinutes) async {
    final res = await _dio.patch(
      '/workplaces/$workplaceId/enabled-minutes',
      data: {'enabledMinutes': enabledMinutes},
    );
    return WorkplaceModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 직원 추가 (사장 전용): 아이디가 있으면 그 계정을, 없으면 기본 비밀번호로 새 계정을 만들어 추가
  Future<WorkerModel> addMember(int workplaceId, String employeeId) async {
    final res = await _dio.post(
      '/workplaces/$workplaceId/members',
      data: {'email': employeeId},
    );
    return WorkerModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 직원 퇴장 (사장 전용)
  Future<void> removeMember(int workplaceId, int workerId) async {
    await _dio.delete('/workplaces/$workplaceId/members/$workerId');
  }

  // 직원별 기본 근무시간 설정 (사장 전용)
  Future<WorkerModel> updateDefaultTime(
    int workplaceId,
    int workerId,
    int clockInHour,
    int clockInMinute,
    int clockOutHour,
    int clockOutMinute,
  ) async {
    final res = await _dio.patch(
      '/workplaces/$workplaceId/members/$workerId/default-time',
      data: {
        'clockInHour': clockInHour,
        'clockInMinute': clockInMinute,
        'clockOutHour': clockOutHour,
        'clockOutMinute': clockOutMinute,
      },
    );
    return WorkerModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 직원별 정산 기간 설정 (사장 전용)
  Future<WorkerModel> updatePayPeriod(
      int workplaceId, int workerId, int payPeriodStartDay) async {
    final res = await _dio.patch(
      '/workplaces/$workplaceId/members/$workerId/pay-period',
      data: {'payPeriodStartDay': payPeriodStartDay},
    );
    return WorkerModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 직원별 정산 방식 설정 (사장 전용)
  Future<WorkerModel> updatePaymentType(
      int workplaceId, int workerId, String paymentType) async {
    final res = await _dio.patch(
      '/workplaces/$workplaceId/members/$workerId/payment-type',
      data: {'paymentType': paymentType},
    );
    return WorkerModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 직원별 요일설정 (사장 전용). enabled=false면 "미설정"(요일 제한 없음).
  Future<WorkerModel> updateWorkingDays(
      int workplaceId, int workerId, bool enabled, List<int> days) async {
    final res = await _dio.patch(
      '/workplaces/$workplaceId/members/$workerId/working-days',
      data: {'enabled': enabled, 'days': days},
    );
    return WorkerModel.fromJson(res.data as Map<String, dynamic>);
  }
}
