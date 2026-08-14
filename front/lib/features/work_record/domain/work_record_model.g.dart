// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkRecordModel _$WorkRecordModelFromJson(Map<String, dynamic> json) =>
    _WorkRecordModel(
      id: (json['id'] as num).toInt(),
      workplaceId: (json['workplaceId'] as num).toInt(),
      workplaceName: json['workplaceName'] as String,
      clockIn: json['clockIn'] as String,
      clockOut: json['clockOut'] as String?,
      workMinutes: (json['workMinutes'] as num?)?.toInt(),
      wageAmount: (json['wageAmount'] as num?)?.toInt(),
      isModified: json['isModified'] as bool,
      creationStatus: json['creationStatus'] as String?,
      deletedSameDay: json['deletedSameDay'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkRecordModelToJson(_WorkRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workplaceId': instance.workplaceId,
      'workplaceName': instance.workplaceName,
      'clockIn': instance.clockIn,
      'clockOut': instance.clockOut,
      'workMinutes': instance.workMinutes,
      'wageAmount': instance.wageAmount,
      'isModified': instance.isModified,
      'creationStatus': instance.creationStatus,
      'deletedSameDay': instance.deletedSameDay,
    };

_WorkStatusModel _$WorkStatusModelFromJson(Map<String, dynamic> json) =>
    _WorkStatusModel(
      isClockedIn: json['isClockedIn'] as bool,
      currentRecord: json['currentRecord'] == null
          ? null
          : WorkRecordModel.fromJson(
              json['currentRecord'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$WorkStatusModelToJson(_WorkStatusModel instance) =>
    <String, dynamic>{
      'isClockedIn': instance.isClockedIn,
      'currentRecord': instance.currentRecord,
    };
