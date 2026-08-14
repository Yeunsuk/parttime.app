// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayrollDetailModel _$PayrollDetailModelFromJson(Map<String, dynamic> json) =>
    _PayrollDetailModel(
      id: (json['id'] as num).toInt(),
      workerId: (json['workerId'] as num).toInt(),
      workerName: json['workerName'] as String,
      clockIn: json['clockIn'] as String,
      clockOut: json['clockOut'] as String?,
      workMinutes: (json['workMinutes'] as num).toInt(),
      wageAmount: (json['wageAmount'] as num).toInt(),
      isModified: json['isModified'] as bool,
      paymentType: json['paymentType'] as String? ?? 'TIME',
      recordCount: (json['recordCount'] as num?)?.toDouble() ?? 1.0,
      creationStatus: json['creationStatus'] as String?,
      deletionOnly: json['deletionOnly'] as bool? ?? false,
    );

Map<String, dynamic> _$PayrollDetailModelToJson(_PayrollDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workerId': instance.workerId,
      'workerName': instance.workerName,
      'clockIn': instance.clockIn,
      'clockOut': instance.clockOut,
      'workMinutes': instance.workMinutes,
      'wageAmount': instance.wageAmount,
      'isModified': instance.isModified,
      'paymentType': instance.paymentType,
      'recordCount': instance.recordCount,
      'creationStatus': instance.creationStatus,
      'deletionOnly': instance.deletionOnly,
    };

_SettlementModel _$SettlementModelFromJson(Map<String, dynamic> json) =>
    _SettlementModel(
      workerId: (json['workerId'] as num).toInt(),
      workerName: json['workerName'] as String,
      periodStart: json['periodStart'] as String,
      periodEnd: json['periodEnd'] as String,
      recordCount: (json['recordCount'] as num).toDouble(),
      totalMinutes: (json['totalMinutes'] as num).toInt(),
      totalWage: (json['totalWage'] as num).toInt(),
      paymentType: json['paymentType'] as String? ?? 'TIME',
    );

Map<String, dynamic> _$SettlementModelToJson(_SettlementModel instance) =>
    <String, dynamic>{
      'workerId': instance.workerId,
      'workerName': instance.workerName,
      'periodStart': instance.periodStart,
      'periodEnd': instance.periodEnd,
      'recordCount': instance.recordCount,
      'totalMinutes': instance.totalMinutes,
      'totalWage': instance.totalWage,
      'paymentType': instance.paymentType,
    };
