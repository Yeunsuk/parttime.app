// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountModel _$AccountModelFromJson(Map<String, dynamic> json) =>
    _AccountModel(
      id: (json['id'] as num).toInt(),
      accountName: json['accountName'] as String,
      accountNumber: json['accountNumber'] as String,
      bankName: json['bankName'] as String,
      qrCodes:
          (json['qrCodes'] as List<dynamic>?)
              ?.map((e) => AccountQrModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AccountQrModel>[],
    );

Map<String, dynamic> _$AccountModelToJson(_AccountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountName': instance.accountName,
      'accountNumber': instance.accountNumber,
      'bankName': instance.bankName,
      'qrCodes': instance.qrCodes,
    };

_AccountQrModel _$AccountQrModelFromJson(Map<String, dynamic> json) =>
    _AccountQrModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      qrImage: json['qrImage'] as String,
    );

Map<String, dynamic> _$AccountQrModelToJson(_AccountQrModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'qrImage': instance.qrImage,
    };
