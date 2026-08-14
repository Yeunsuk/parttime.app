import 'package:dio/dio.dart';
import '../domain/payroll_model.dart';

class PayrollApi {
  final Dio _dio;
  PayrollApi(this._dio);

  // 근무지 전체 근로자 근무기록 (달력용)
  Future<List<PayrollDetailModel>> getWorkplaceRecords(
      int workplaceId, int year, int month) async {
    final res = await _dio.get(
      '/workplaces/$workplaceId/records',
      queryParameters: {'year': year, 'month': month},
    );
    return (res.data as List)
        .map((e) => PayrollDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 특정 근로자 상세 근무기록
  Future<List<PayrollDetailModel>> getWorkerDetail(
      int workplaceId, int workerId, int year, int month) async {
    final res = await _dio.get(
      '/workplaces/$workplaceId/workers/$workerId/records',
      queryParameters: {'year': year, 'month': month},
    );
    return (res.data as List)
        .map((e) => PayrollDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 근무기록 수정 (사장 권한)
  Future<PayrollDetailModel> modifyRecord(
      int recordId, String clockIn, String clockOut) async {
    final res = await _dio.patch(
      '/work-records/$recordId/modify',
      data: {'clockIn': clockIn, 'clockOut': clockOut},
    );
    return PayrollDetailModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 근무기록 추가 (사장 권한). recordCount는 횟수제 직원에게만 의미가 있다(1 또는 0.5).
  Future<PayrollDetailModel> addRecord(int workplaceId, int workerId,
      String clockIn, String clockOut, double? recordCount) async {
    final res = await _dio.post(
      '/workplaces/$workplaceId/workers/$workerId/records',
      data: {
        'clockIn': clockIn,
        'clockOut': clockOut,
        if (recordCount != null) 'recordCount': recordCount,
      },
    );
    return PayrollDetailModel.fromJson(res.data as Map<String, dynamic>);
  }

  // 근무기록 삭제 (사장 권한)
  Future<void> deleteRecord(int recordId) async {
    await _dio.delete('/work-records/$recordId');
  }

  // 근무지 소속 직원별 정산 (사장 권한)
  Future<List<SettlementModel>> getSettlement(
      int workplaceId, int year, int month) async {
    final res = await _dio.get(
      '/workplaces/$workplaceId/settlement',
      queryParameters: {'year': year, 'month': month},
    );
    return (res.data as List)
        .map((e) => SettlementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
