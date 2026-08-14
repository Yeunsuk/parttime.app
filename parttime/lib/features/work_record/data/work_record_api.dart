import 'package:dio/dio.dart';
import '../domain/work_record_model.dart';

class WorkRecordApi {
  final Dio _dio;
  WorkRecordApi(this._dio);

  Future<WorkStatusModel> getStatus() async {
    final res = await _dio.get('/work-records/status');
    return WorkStatusModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<WorkRecordModel> clockIn(int workplaceId) async {
    final res = await _dio.post(
      '/work-records/clock-in',
      data: {'workplaceId': workplaceId},
    );
    return WorkRecordModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<WorkRecordModel> clockOut(int recordId) async {
    final res = await _dio.patch('/work-records/$recordId/clock-out');
    return WorkRecordModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<WorkRecordModel>> getCalendar(int year, int month) async {
    final res = await _dio.get(
      '/work-records/calendar',
      queryParameters: {'year': year, 'month': month},
    );
    return (res.data as List)
        .map((e) => WorkRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
