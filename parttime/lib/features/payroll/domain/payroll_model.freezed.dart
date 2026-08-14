// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payroll_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayrollDetailModel {

 int get id; int get workerId; String get workerName; String get clockIn; String? get clockOut; int get workMinutes; int get wageAmount; bool get isModified; String get paymentType; double get recordCount; String? get creationStatus; bool get deletionOnly;
/// Create a copy of PayrollDetailModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayrollDetailModelCopyWith<PayrollDetailModel> get copyWith => _$PayrollDetailModelCopyWithImpl<PayrollDetailModel>(this as PayrollDetailModel, _$identity);

  /// Serializes this PayrollDetailModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayrollDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.workerName, workerName) || other.workerName == workerName)&&(identical(other.clockIn, clockIn) || other.clockIn == clockIn)&&(identical(other.clockOut, clockOut) || other.clockOut == clockOut)&&(identical(other.workMinutes, workMinutes) || other.workMinutes == workMinutes)&&(identical(other.wageAmount, wageAmount) || other.wageAmount == wageAmount)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.paymentType, paymentType) || other.paymentType == paymentType)&&(identical(other.recordCount, recordCount) || other.recordCount == recordCount)&&(identical(other.creationStatus, creationStatus) || other.creationStatus == creationStatus)&&(identical(other.deletionOnly, deletionOnly) || other.deletionOnly == deletionOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workerId,workerName,clockIn,clockOut,workMinutes,wageAmount,isModified,paymentType,recordCount,creationStatus,deletionOnly);

@override
String toString() {
  return 'PayrollDetailModel(id: $id, workerId: $workerId, workerName: $workerName, clockIn: $clockIn, clockOut: $clockOut, workMinutes: $workMinutes, wageAmount: $wageAmount, isModified: $isModified, paymentType: $paymentType, recordCount: $recordCount, creationStatus: $creationStatus, deletionOnly: $deletionOnly)';
}


}

/// @nodoc
abstract mixin class $PayrollDetailModelCopyWith<$Res>  {
  factory $PayrollDetailModelCopyWith(PayrollDetailModel value, $Res Function(PayrollDetailModel) _then) = _$PayrollDetailModelCopyWithImpl;
@useResult
$Res call({
 int id, int workerId, String workerName, String clockIn, String? clockOut, int workMinutes, int wageAmount, bool isModified, String paymentType, double recordCount, String? creationStatus, bool deletionOnly
});




}
/// @nodoc
class _$PayrollDetailModelCopyWithImpl<$Res>
    implements $PayrollDetailModelCopyWith<$Res> {
  _$PayrollDetailModelCopyWithImpl(this._self, this._then);

  final PayrollDetailModel _self;
  final $Res Function(PayrollDetailModel) _then;

/// Create a copy of PayrollDetailModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workerId = null,Object? workerName = null,Object? clockIn = null,Object? clockOut = freezed,Object? workMinutes = null,Object? wageAmount = null,Object? isModified = null,Object? paymentType = null,Object? recordCount = null,Object? creationStatus = freezed,Object? deletionOnly = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as int,workerName: null == workerName ? _self.workerName : workerName // ignore: cast_nullable_to_non_nullable
as String,clockIn: null == clockIn ? _self.clockIn : clockIn // ignore: cast_nullable_to_non_nullable
as String,clockOut: freezed == clockOut ? _self.clockOut : clockOut // ignore: cast_nullable_to_non_nullable
as String?,workMinutes: null == workMinutes ? _self.workMinutes : workMinutes // ignore: cast_nullable_to_non_nullable
as int,wageAmount: null == wageAmount ? _self.wageAmount : wageAmount // ignore: cast_nullable_to_non_nullable
as int,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,paymentType: null == paymentType ? _self.paymentType : paymentType // ignore: cast_nullable_to_non_nullable
as String,recordCount: null == recordCount ? _self.recordCount : recordCount // ignore: cast_nullable_to_non_nullable
as double,creationStatus: freezed == creationStatus ? _self.creationStatus : creationStatus // ignore: cast_nullable_to_non_nullable
as String?,deletionOnly: null == deletionOnly ? _self.deletionOnly : deletionOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PayrollDetailModel].
extension PayrollDetailModelPatterns on PayrollDetailModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayrollDetailModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayrollDetailModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayrollDetailModel value)  $default,){
final _that = this;
switch (_that) {
case _PayrollDetailModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayrollDetailModel value)?  $default,){
final _that = this;
switch (_that) {
case _PayrollDetailModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int workerId,  String workerName,  String clockIn,  String? clockOut,  int workMinutes,  int wageAmount,  bool isModified,  String paymentType,  double recordCount,  String? creationStatus,  bool deletionOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayrollDetailModel() when $default != null:
return $default(_that.id,_that.workerId,_that.workerName,_that.clockIn,_that.clockOut,_that.workMinutes,_that.wageAmount,_that.isModified,_that.paymentType,_that.recordCount,_that.creationStatus,_that.deletionOnly);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int workerId,  String workerName,  String clockIn,  String? clockOut,  int workMinutes,  int wageAmount,  bool isModified,  String paymentType,  double recordCount,  String? creationStatus,  bool deletionOnly)  $default,) {final _that = this;
switch (_that) {
case _PayrollDetailModel():
return $default(_that.id,_that.workerId,_that.workerName,_that.clockIn,_that.clockOut,_that.workMinutes,_that.wageAmount,_that.isModified,_that.paymentType,_that.recordCount,_that.creationStatus,_that.deletionOnly);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int workerId,  String workerName,  String clockIn,  String? clockOut,  int workMinutes,  int wageAmount,  bool isModified,  String paymentType,  double recordCount,  String? creationStatus,  bool deletionOnly)?  $default,) {final _that = this;
switch (_that) {
case _PayrollDetailModel() when $default != null:
return $default(_that.id,_that.workerId,_that.workerName,_that.clockIn,_that.clockOut,_that.workMinutes,_that.wageAmount,_that.isModified,_that.paymentType,_that.recordCount,_that.creationStatus,_that.deletionOnly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayrollDetailModel implements PayrollDetailModel {
  const _PayrollDetailModel({required this.id, required this.workerId, required this.workerName, required this.clockIn, this.clockOut, required this.workMinutes, required this.wageAmount, required this.isModified, this.paymentType = 'TIME', this.recordCount = 1.0, this.creationStatus, this.deletionOnly = false});
  factory _PayrollDetailModel.fromJson(Map<String, dynamic> json) => _$PayrollDetailModelFromJson(json);

@override final  int id;
@override final  int workerId;
@override final  String workerName;
@override final  String clockIn;
@override final  String? clockOut;
@override final  int workMinutes;
@override final  int wageAmount;
@override final  bool isModified;
@override@JsonKey() final  String paymentType;
@override@JsonKey() final  double recordCount;
@override final  String? creationStatus;
@override@JsonKey() final  bool deletionOnly;

/// Create a copy of PayrollDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayrollDetailModelCopyWith<_PayrollDetailModel> get copyWith => __$PayrollDetailModelCopyWithImpl<_PayrollDetailModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayrollDetailModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayrollDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.workerName, workerName) || other.workerName == workerName)&&(identical(other.clockIn, clockIn) || other.clockIn == clockIn)&&(identical(other.clockOut, clockOut) || other.clockOut == clockOut)&&(identical(other.workMinutes, workMinutes) || other.workMinutes == workMinutes)&&(identical(other.wageAmount, wageAmount) || other.wageAmount == wageAmount)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.paymentType, paymentType) || other.paymentType == paymentType)&&(identical(other.recordCount, recordCount) || other.recordCount == recordCount)&&(identical(other.creationStatus, creationStatus) || other.creationStatus == creationStatus)&&(identical(other.deletionOnly, deletionOnly) || other.deletionOnly == deletionOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workerId,workerName,clockIn,clockOut,workMinutes,wageAmount,isModified,paymentType,recordCount,creationStatus,deletionOnly);

@override
String toString() {
  return 'PayrollDetailModel(id: $id, workerId: $workerId, workerName: $workerName, clockIn: $clockIn, clockOut: $clockOut, workMinutes: $workMinutes, wageAmount: $wageAmount, isModified: $isModified, paymentType: $paymentType, recordCount: $recordCount, creationStatus: $creationStatus, deletionOnly: $deletionOnly)';
}


}

/// @nodoc
abstract mixin class _$PayrollDetailModelCopyWith<$Res> implements $PayrollDetailModelCopyWith<$Res> {
  factory _$PayrollDetailModelCopyWith(_PayrollDetailModel value, $Res Function(_PayrollDetailModel) _then) = __$PayrollDetailModelCopyWithImpl;
@override @useResult
$Res call({
 int id, int workerId, String workerName, String clockIn, String? clockOut, int workMinutes, int wageAmount, bool isModified, String paymentType, double recordCount, String? creationStatus, bool deletionOnly
});




}
/// @nodoc
class __$PayrollDetailModelCopyWithImpl<$Res>
    implements _$PayrollDetailModelCopyWith<$Res> {
  __$PayrollDetailModelCopyWithImpl(this._self, this._then);

  final _PayrollDetailModel _self;
  final $Res Function(_PayrollDetailModel) _then;

/// Create a copy of PayrollDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workerId = null,Object? workerName = null,Object? clockIn = null,Object? clockOut = freezed,Object? workMinutes = null,Object? wageAmount = null,Object? isModified = null,Object? paymentType = null,Object? recordCount = null,Object? creationStatus = freezed,Object? deletionOnly = null,}) {
  return _then(_PayrollDetailModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as int,workerName: null == workerName ? _self.workerName : workerName // ignore: cast_nullable_to_non_nullable
as String,clockIn: null == clockIn ? _self.clockIn : clockIn // ignore: cast_nullable_to_non_nullable
as String,clockOut: freezed == clockOut ? _self.clockOut : clockOut // ignore: cast_nullable_to_non_nullable
as String?,workMinutes: null == workMinutes ? _self.workMinutes : workMinutes // ignore: cast_nullable_to_non_nullable
as int,wageAmount: null == wageAmount ? _self.wageAmount : wageAmount // ignore: cast_nullable_to_non_nullable
as int,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,paymentType: null == paymentType ? _self.paymentType : paymentType // ignore: cast_nullable_to_non_nullable
as String,recordCount: null == recordCount ? _self.recordCount : recordCount // ignore: cast_nullable_to_non_nullable
as double,creationStatus: freezed == creationStatus ? _self.creationStatus : creationStatus // ignore: cast_nullable_to_non_nullable
as String?,deletionOnly: null == deletionOnly ? _self.deletionOnly : deletionOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SettlementModel {

 int get workerId; String get workerName; String get periodStart; String get periodEnd; double get recordCount; int get totalMinutes; int get totalWage; String get paymentType;
/// Create a copy of SettlementModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettlementModelCopyWith<SettlementModel> get copyWith => _$SettlementModelCopyWithImpl<SettlementModel>(this as SettlementModel, _$identity);

  /// Serializes this SettlementModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettlementModel&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.workerName, workerName) || other.workerName == workerName)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.recordCount, recordCount) || other.recordCount == recordCount)&&(identical(other.totalMinutes, totalMinutes) || other.totalMinutes == totalMinutes)&&(identical(other.totalWage, totalWage) || other.totalWage == totalWage)&&(identical(other.paymentType, paymentType) || other.paymentType == paymentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workerId,workerName,periodStart,periodEnd,recordCount,totalMinutes,totalWage,paymentType);

@override
String toString() {
  return 'SettlementModel(workerId: $workerId, workerName: $workerName, periodStart: $periodStart, periodEnd: $periodEnd, recordCount: $recordCount, totalMinutes: $totalMinutes, totalWage: $totalWage, paymentType: $paymentType)';
}


}

/// @nodoc
abstract mixin class $SettlementModelCopyWith<$Res>  {
  factory $SettlementModelCopyWith(SettlementModel value, $Res Function(SettlementModel) _then) = _$SettlementModelCopyWithImpl;
@useResult
$Res call({
 int workerId, String workerName, String periodStart, String periodEnd, double recordCount, int totalMinutes, int totalWage, String paymentType
});




}
/// @nodoc
class _$SettlementModelCopyWithImpl<$Res>
    implements $SettlementModelCopyWith<$Res> {
  _$SettlementModelCopyWithImpl(this._self, this._then);

  final SettlementModel _self;
  final $Res Function(SettlementModel) _then;

/// Create a copy of SettlementModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workerId = null,Object? workerName = null,Object? periodStart = null,Object? periodEnd = null,Object? recordCount = null,Object? totalMinutes = null,Object? totalWage = null,Object? paymentType = null,}) {
  return _then(_self.copyWith(
workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as int,workerName: null == workerName ? _self.workerName : workerName // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as String,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as String,recordCount: null == recordCount ? _self.recordCount : recordCount // ignore: cast_nullable_to_non_nullable
as double,totalMinutes: null == totalMinutes ? _self.totalMinutes : totalMinutes // ignore: cast_nullable_to_non_nullable
as int,totalWage: null == totalWage ? _self.totalWage : totalWage // ignore: cast_nullable_to_non_nullable
as int,paymentType: null == paymentType ? _self.paymentType : paymentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SettlementModel].
extension SettlementModelPatterns on SettlementModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettlementModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettlementModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettlementModel value)  $default,){
final _that = this;
switch (_that) {
case _SettlementModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettlementModel value)?  $default,){
final _that = this;
switch (_that) {
case _SettlementModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int workerId,  String workerName,  String periodStart,  String periodEnd,  double recordCount,  int totalMinutes,  int totalWage,  String paymentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettlementModel() when $default != null:
return $default(_that.workerId,_that.workerName,_that.periodStart,_that.periodEnd,_that.recordCount,_that.totalMinutes,_that.totalWage,_that.paymentType);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int workerId,  String workerName,  String periodStart,  String periodEnd,  double recordCount,  int totalMinutes,  int totalWage,  String paymentType)  $default,) {final _that = this;
switch (_that) {
case _SettlementModel():
return $default(_that.workerId,_that.workerName,_that.periodStart,_that.periodEnd,_that.recordCount,_that.totalMinutes,_that.totalWage,_that.paymentType);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int workerId,  String workerName,  String periodStart,  String periodEnd,  double recordCount,  int totalMinutes,  int totalWage,  String paymentType)?  $default,) {final _that = this;
switch (_that) {
case _SettlementModel() when $default != null:
return $default(_that.workerId,_that.workerName,_that.periodStart,_that.periodEnd,_that.recordCount,_that.totalMinutes,_that.totalWage,_that.paymentType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SettlementModel implements SettlementModel {
  const _SettlementModel({required this.workerId, required this.workerName, required this.periodStart, required this.periodEnd, required this.recordCount, required this.totalMinutes, required this.totalWage, this.paymentType = 'TIME'});
  factory _SettlementModel.fromJson(Map<String, dynamic> json) => _$SettlementModelFromJson(json);

@override final  int workerId;
@override final  String workerName;
@override final  String periodStart;
@override final  String periodEnd;
@override final  double recordCount;
@override final  int totalMinutes;
@override final  int totalWage;
@override@JsonKey() final  String paymentType;

/// Create a copy of SettlementModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettlementModelCopyWith<_SettlementModel> get copyWith => __$SettlementModelCopyWithImpl<_SettlementModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettlementModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettlementModel&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.workerName, workerName) || other.workerName == workerName)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.recordCount, recordCount) || other.recordCount == recordCount)&&(identical(other.totalMinutes, totalMinutes) || other.totalMinutes == totalMinutes)&&(identical(other.totalWage, totalWage) || other.totalWage == totalWage)&&(identical(other.paymentType, paymentType) || other.paymentType == paymentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workerId,workerName,periodStart,periodEnd,recordCount,totalMinutes,totalWage,paymentType);

@override
String toString() {
  return 'SettlementModel(workerId: $workerId, workerName: $workerName, periodStart: $periodStart, periodEnd: $periodEnd, recordCount: $recordCount, totalMinutes: $totalMinutes, totalWage: $totalWage, paymentType: $paymentType)';
}


}

/// @nodoc
abstract mixin class _$SettlementModelCopyWith<$Res> implements $SettlementModelCopyWith<$Res> {
  factory _$SettlementModelCopyWith(_SettlementModel value, $Res Function(_SettlementModel) _then) = __$SettlementModelCopyWithImpl;
@override @useResult
$Res call({
 int workerId, String workerName, String periodStart, String periodEnd, double recordCount, int totalMinutes, int totalWage, String paymentType
});




}
/// @nodoc
class __$SettlementModelCopyWithImpl<$Res>
    implements _$SettlementModelCopyWith<$Res> {
  __$SettlementModelCopyWithImpl(this._self, this._then);

  final _SettlementModel _self;
  final $Res Function(_SettlementModel) _then;

/// Create a copy of SettlementModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workerId = null,Object? workerName = null,Object? periodStart = null,Object? periodEnd = null,Object? recordCount = null,Object? totalMinutes = null,Object? totalWage = null,Object? paymentType = null,}) {
  return _then(_SettlementModel(
workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as int,workerName: null == workerName ? _self.workerName : workerName // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as String,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as String,recordCount: null == recordCount ? _self.recordCount : recordCount // ignore: cast_nullable_to_non_nullable
as double,totalMinutes: null == totalMinutes ? _self.totalMinutes : totalMinutes // ignore: cast_nullable_to_non_nullable
as int,totalWage: null == totalWage ? _self.totalWage : totalWage // ignore: cast_nullable_to_non_nullable
as int,paymentType: null == paymentType ? _self.paymentType : paymentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
