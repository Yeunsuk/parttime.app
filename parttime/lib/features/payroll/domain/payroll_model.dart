import 'package:freezed_annotation/freezed_annotation.dart';

part 'payroll_model.freezed.dart';
part 'payroll_model.g.dart';

// 근무기록 1건 (달력용). 근무지 전체 조회 시 여러 근로자 것이 섞여 오고,
// 특정 근로자 조회 시엔 그 근로자 것만 온다.
@freezed
abstract class PayrollDetailModel with _$PayrollDetailModel {
  const factory PayrollDetailModel({
    required int id,
    required int workerId,
    required String workerName,
    required String clockIn,
    String? clockOut,
    required int workMinutes,
    required int wageAmount,
    required bool isModified,
    @Default('TIME') String paymentType,
    @Default(1.0) double recordCount,
    // "CREATED"(근무생성으로 만들어짐), "MODIFIED"(근무수정으로 바뀜), null(둘 다 아님)
    String? creationStatus,
    // true면 실제 근무기록이 아니라, 그 날 삭제된 근무기록이 있었다는 표시용
    // placeholder다. 같은 날 다른 근무기록이 남아있어도 별도 항목으로 함께 온다.
    @Default(false) bool deletionOnly,
  }) = _PayrollDetailModel;

  factory PayrollDetailModel.fromJson(Map<String, dynamic> json) =>
      _$PayrollDetailModelFromJson(json);
}

// 근무지 소속 직원별 정산 요약 (각자 설정한 정산기간 기준)
@freezed
abstract class SettlementModel with _$SettlementModel {
  const factory SettlementModel({
    required int workerId,
    required String workerName,
    required String periodStart,
    required String periodEnd,
    required double recordCount,
    required int totalMinutes,
    required int totalWage,
    @Default('TIME') String paymentType,
  }) = _SettlementModel;

  factory SettlementModel.fromJson(Map<String, dynamic> json) =>
      _$SettlementModelFromJson(json);
}
