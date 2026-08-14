import 'package:freezed_annotation/freezed_annotation.dart';

part 'work_record_model.freezed.dart';
part 'work_record_model.g.dart';

@freezed
abstract class WorkRecordModel with _$WorkRecordModel {
  const factory WorkRecordModel({
    required int id,
    required int workplaceId,
    required String workplaceName,
    required String clockIn,
    String? clockOut,
    int? workMinutes,
    int? wageAmount,
    required bool isModified,
    // "CREATED"(근무생성으로 만들어짐), "MODIFIED"(근무수정으로 바뀜), null(둘 다 아님)
    String? creationStatus,
    @Default(false) bool deletedSameDay,
  }) = _WorkRecordModel;

  factory WorkRecordModel.fromJson(Map<String, dynamic> json) =>
      _$WorkRecordModelFromJson(json);
}

@freezed
abstract class WorkStatusModel with _$WorkStatusModel {
  const factory WorkStatusModel({
    required bool isClockedIn,
    WorkRecordModel? currentRecord, // 현재 진행 중인 근무
  }) = _WorkStatusModel;

  factory WorkStatusModel.fromJson(Map<String, dynamic> json) =>
      _$WorkStatusModelFromJson(json);
}
