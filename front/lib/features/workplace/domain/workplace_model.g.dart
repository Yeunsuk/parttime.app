// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkplaceModel _$WorkplaceModelFromJson(Map<String, dynamic> json) =>
    _WorkplaceModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      inviteCode: json['inviteCode'] as String,
      hourlyWage: (json['hourlyWage'] as num).toInt(),
      ownerName: json['ownerName'] as String,
      memberLimit: (json['memberLimit'] as num).toInt(),
      disabledHours:
          (json['disabledHours'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      enabledMinutes:
          (json['enabledMinutes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[0, 30],
    );

Map<String, dynamic> _$WorkplaceModelToJson(_WorkplaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'inviteCode': instance.inviteCode,
      'hourlyWage': instance.hourlyWage,
      'ownerName': instance.ownerName,
      'memberLimit': instance.memberLimit,
      'disabledHours': instance.disabledHours,
      'enabledMinutes': instance.enabledMinutes,
    };

_WorkerModel _$WorkerModelFromJson(Map<String, dynamic> json) => _WorkerModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  defaultClockInHour: (json['defaultClockInHour'] as num?)?.toInt(),
  defaultClockInMinute: (json['defaultClockInMinute'] as num?)?.toInt(),
  defaultClockOutHour: (json['defaultClockOutHour'] as num?)?.toInt(),
  defaultClockOutMinute: (json['defaultClockOutMinute'] as num?)?.toInt(),
  payPeriodStartDay: (json['payPeriodStartDay'] as num?)?.toInt(),
  paymentType: json['paymentType'] as String? ?? 'TIME',
  workingDaysEnabled: json['workingDaysEnabled'] as bool? ?? false,
  workingDays:
      (json['workingDays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
);

Map<String, dynamic> _$WorkerModelToJson(_WorkerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'defaultClockInHour': instance.defaultClockInHour,
      'defaultClockInMinute': instance.defaultClockInMinute,
      'defaultClockOutHour': instance.defaultClockOutHour,
      'defaultClockOutMinute': instance.defaultClockOutMinute,
      'payPeriodStartDay': instance.payPeriodStartDay,
      'paymentType': instance.paymentType,
      'workingDaysEnabled': instance.workingDaysEnabled,
      'workingDays': instance.workingDays,
    };
