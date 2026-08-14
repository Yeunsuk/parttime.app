import 'package:freezed_annotation/freezed_annotation.dart';

part 'workplace_model.freezed.dart';
part 'workplace_model.g.dart';

@freezed
abstract class WorkplaceModel with _$WorkplaceModel {
  const factory WorkplaceModel({
    required int id,
    required String name,
    required String inviteCode,
    required int hourlyWage,
    required String ownerName,
    required int memberLimit,
    @Default(<int>[]) List<int> disabledHours,
    @Default(<int>[0, 30]) List<int> enabledMinutes,
  }) = _WorkplaceModel;

  factory WorkplaceModel.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceModelFromJson(json);
}

// 근무지에 속한 근로자 1명 (사장의 근로자별 달력 색상 설정 등에 사용)
@freezed
abstract class WorkerModel with _$WorkerModel {
  const factory WorkerModel({
    required int id,
    required String name,
    int? defaultClockInHour,
    int? defaultClockInMinute,
    int? defaultClockOutHour,
    int? defaultClockOutMinute,
    int? payPeriodStartDay,
    @Default('TIME') String paymentType,
    // 요일설정: false(미설정)면 요일 제한 없이 항상 활성. true면 workingDays(1=월~7=일)에
    // 포함된 요일에만 활성 — 근무기록 추가 다이얼로그의 근로자 정렬 우선순위에 쓰인다.
    @Default(false) bool workingDaysEnabled,
    @Default(<int>[]) List<int> workingDays,
  }) = _WorkerModel;

  factory WorkerModel.fromJson(Map<String, dynamic> json) =>
      _$WorkerModelFromJson(json);
}
