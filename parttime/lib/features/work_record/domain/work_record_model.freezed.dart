// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkRecordModel {

 int get id; int get workplaceId; String get workplaceName; String get clockIn; String? get clockOut; int? get workMinutes; int? get wageAmount; bool get isModified; String? get creationStatus; bool get deletedSameDay;
/// Create a copy of WorkRecordModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkRecordModelCopyWith<WorkRecordModel> get copyWith => _$WorkRecordModelCopyWithImpl<WorkRecordModel>(this as WorkRecordModel, _$identity);

  /// Serializes this WorkRecordModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.workplaceId, workplaceId) || other.workplaceId == workplaceId)&&(identical(other.workplaceName, workplaceName) || other.workplaceName == workplaceName)&&(identical(other.clockIn, clockIn) || other.clockIn == clockIn)&&(identical(other.clockOut, clockOut) || other.clockOut == clockOut)&&(identical(other.workMinutes, workMinutes) || other.workMinutes == workMinutes)&&(identical(other.wageAmount, wageAmount) || other.wageAmount == wageAmount)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.creationStatus, creationStatus) || other.creationStatus == creationStatus)&&(identical(other.deletedSameDay, deletedSameDay) || other.deletedSameDay == deletedSameDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workplaceId,workplaceName,clockIn,clockOut,workMinutes,wageAmount,isModified,creationStatus,deletedSameDay);

@override
String toString() {
  return 'WorkRecordModel(id: $id, workplaceId: $workplaceId, workplaceName: $workplaceName, clockIn: $clockIn, clockOut: $clockOut, workMinutes: $workMinutes, wageAmount: $wageAmount, isModified: $isModified, creationStatus: $creationStatus, deletedSameDay: $deletedSameDay)';
}


}

/// @nodoc
abstract mixin class $WorkRecordModelCopyWith<$Res>  {
  factory $WorkRecordModelCopyWith(WorkRecordModel value, $Res Function(WorkRecordModel) _then) = _$WorkRecordModelCopyWithImpl;
@useResult
$Res call({
 int id, int workplaceId, String workplaceName, String clockIn, String? clockOut, int? workMinutes, int? wageAmount, bool isModified, String? creationStatus, bool deletedSameDay
});




}
/// @nodoc
class _$WorkRecordModelCopyWithImpl<$Res>
    implements $WorkRecordModelCopyWith<$Res> {
  _$WorkRecordModelCopyWithImpl(this._self, this._then);

  final WorkRecordModel _self;
  final $Res Function(WorkRecordModel) _then;

/// Create a copy of WorkRecordModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workplaceId = null,Object? workplaceName = null,Object? clockIn = null,Object? clockOut = freezed,Object? workMinutes = freezed,Object? wageAmount = freezed,Object? isModified = null,Object? creationStatus = freezed,Object? deletedSameDay = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,workplaceId: null == workplaceId ? _self.workplaceId : workplaceId // ignore: cast_nullable_to_non_nullable
as int,workplaceName: null == workplaceName ? _self.workplaceName : workplaceName // ignore: cast_nullable_to_non_nullable
as String,clockIn: null == clockIn ? _self.clockIn : clockIn // ignore: cast_nullable_to_non_nullable
as String,clockOut: freezed == clockOut ? _self.clockOut : clockOut // ignore: cast_nullable_to_non_nullable
as String?,workMinutes: freezed == workMinutes ? _self.workMinutes : workMinutes // ignore: cast_nullable_to_non_nullable
as int?,wageAmount: freezed == wageAmount ? _self.wageAmount : wageAmount // ignore: cast_nullable_to_non_nullable
as int?,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,creationStatus: freezed == creationStatus ? _self.creationStatus : creationStatus // ignore: cast_nullable_to_non_nullable
as String?,deletedSameDay: null == deletedSameDay ? _self.deletedSameDay : deletedSameDay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkRecordModel].
extension WorkRecordModelPatterns on WorkRecordModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkRecordModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkRecordModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkRecordModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkRecordModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkRecordModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkRecordModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int workplaceId,  String workplaceName,  String clockIn,  String? clockOut,  int? workMinutes,  int? wageAmount,  bool isModified,  String? creationStatus,  bool deletedSameDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkRecordModel() when $default != null:
return $default(_that.id,_that.workplaceId,_that.workplaceName,_that.clockIn,_that.clockOut,_that.workMinutes,_that.wageAmount,_that.isModified,_that.creationStatus,_that.deletedSameDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int workplaceId,  String workplaceName,  String clockIn,  String? clockOut,  int? workMinutes,  int? wageAmount,  bool isModified,  String? creationStatus,  bool deletedSameDay)  $default,) {final _that = this;
switch (_that) {
case _WorkRecordModel():
return $default(_that.id,_that.workplaceId,_that.workplaceName,_that.clockIn,_that.clockOut,_that.workMinutes,_that.wageAmount,_that.isModified,_that.creationStatus,_that.deletedSameDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int workplaceId,  String workplaceName,  String clockIn,  String? clockOut,  int? workMinutes,  int? wageAmount,  bool isModified,  String? creationStatus,  bool deletedSameDay)?  $default,) {final _that = this;
switch (_that) {
case _WorkRecordModel() when $default != null:
return $default(_that.id,_that.workplaceId,_that.workplaceName,_that.clockIn,_that.clockOut,_that.workMinutes,_that.wageAmount,_that.isModified,_that.creationStatus,_that.deletedSameDay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkRecordModel implements WorkRecordModel {
  const _WorkRecordModel({required this.id, required this.workplaceId, required this.workplaceName, required this.clockIn, this.clockOut, this.workMinutes, this.wageAmount, required this.isModified, this.creationStatus, this.deletedSameDay = false});
  factory _WorkRecordModel.fromJson(Map<String, dynamic> json) => _$WorkRecordModelFromJson(json);

@override final  int id;
@override final  int workplaceId;
@override final  String workplaceName;
@override final  String clockIn;
@override final  String? clockOut;
@override final  int? workMinutes;
@override final  int? wageAmount;
@override final  bool isModified;
@override final  String? creationStatus;
@override@JsonKey() final  bool deletedSameDay;

/// Create a copy of WorkRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkRecordModelCopyWith<_WorkRecordModel> get copyWith => __$WorkRecordModelCopyWithImpl<_WorkRecordModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkRecordModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.workplaceId, workplaceId) || other.workplaceId == workplaceId)&&(identical(other.workplaceName, workplaceName) || other.workplaceName == workplaceName)&&(identical(other.clockIn, clockIn) || other.clockIn == clockIn)&&(identical(other.clockOut, clockOut) || other.clockOut == clockOut)&&(identical(other.workMinutes, workMinutes) || other.workMinutes == workMinutes)&&(identical(other.wageAmount, wageAmount) || other.wageAmount == wageAmount)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.creationStatus, creationStatus) || other.creationStatus == creationStatus)&&(identical(other.deletedSameDay, deletedSameDay) || other.deletedSameDay == deletedSameDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workplaceId,workplaceName,clockIn,clockOut,workMinutes,wageAmount,isModified,creationStatus,deletedSameDay);

@override
String toString() {
  return 'WorkRecordModel(id: $id, workplaceId: $workplaceId, workplaceName: $workplaceName, clockIn: $clockIn, clockOut: $clockOut, workMinutes: $workMinutes, wageAmount: $wageAmount, isModified: $isModified, creationStatus: $creationStatus, deletedSameDay: $deletedSameDay)';
}


}

/// @nodoc
abstract mixin class _$WorkRecordModelCopyWith<$Res> implements $WorkRecordModelCopyWith<$Res> {
  factory _$WorkRecordModelCopyWith(_WorkRecordModel value, $Res Function(_WorkRecordModel) _then) = __$WorkRecordModelCopyWithImpl;
@override @useResult
$Res call({
 int id, int workplaceId, String workplaceName, String clockIn, String? clockOut, int? workMinutes, int? wageAmount, bool isModified, String? creationStatus, bool deletedSameDay
});




}
/// @nodoc
class __$WorkRecordModelCopyWithImpl<$Res>
    implements _$WorkRecordModelCopyWith<$Res> {
  __$WorkRecordModelCopyWithImpl(this._self, this._then);

  final _WorkRecordModel _self;
  final $Res Function(_WorkRecordModel) _then;

/// Create a copy of WorkRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workplaceId = null,Object? workplaceName = null,Object? clockIn = null,Object? clockOut = freezed,Object? workMinutes = freezed,Object? wageAmount = freezed,Object? isModified = null,Object? creationStatus = freezed,Object? deletedSameDay = null,}) {
  return _then(_WorkRecordModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,workplaceId: null == workplaceId ? _self.workplaceId : workplaceId // ignore: cast_nullable_to_non_nullable
as int,workplaceName: null == workplaceName ? _self.workplaceName : workplaceName // ignore: cast_nullable_to_non_nullable
as String,clockIn: null == clockIn ? _self.clockIn : clockIn // ignore: cast_nullable_to_non_nullable
as String,clockOut: freezed == clockOut ? _self.clockOut : clockOut // ignore: cast_nullable_to_non_nullable
as String?,workMinutes: freezed == workMinutes ? _self.workMinutes : workMinutes // ignore: cast_nullable_to_non_nullable
as int?,wageAmount: freezed == wageAmount ? _self.wageAmount : wageAmount // ignore: cast_nullable_to_non_nullable
as int?,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,creationStatus: freezed == creationStatus ? _self.creationStatus : creationStatus // ignore: cast_nullable_to_non_nullable
as String?,deletedSameDay: null == deletedSameDay ? _self.deletedSameDay : deletedSameDay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$WorkStatusModel {

 bool get isClockedIn; WorkRecordModel? get currentRecord;
/// Create a copy of WorkStatusModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkStatusModelCopyWith<WorkStatusModel> get copyWith => _$WorkStatusModelCopyWithImpl<WorkStatusModel>(this as WorkStatusModel, _$identity);

  /// Serializes this WorkStatusModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkStatusModel&&(identical(other.isClockedIn, isClockedIn) || other.isClockedIn == isClockedIn)&&(identical(other.currentRecord, currentRecord) || other.currentRecord == currentRecord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isClockedIn,currentRecord);

@override
String toString() {
  return 'WorkStatusModel(isClockedIn: $isClockedIn, currentRecord: $currentRecord)';
}


}

/// @nodoc
abstract mixin class $WorkStatusModelCopyWith<$Res>  {
  factory $WorkStatusModelCopyWith(WorkStatusModel value, $Res Function(WorkStatusModel) _then) = _$WorkStatusModelCopyWithImpl;
@useResult
$Res call({
 bool isClockedIn, WorkRecordModel? currentRecord
});


$WorkRecordModelCopyWith<$Res>? get currentRecord;

}
/// @nodoc
class _$WorkStatusModelCopyWithImpl<$Res>
    implements $WorkStatusModelCopyWith<$Res> {
  _$WorkStatusModelCopyWithImpl(this._self, this._then);

  final WorkStatusModel _self;
  final $Res Function(WorkStatusModel) _then;

/// Create a copy of WorkStatusModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isClockedIn = null,Object? currentRecord = freezed,}) {
  return _then(_self.copyWith(
isClockedIn: null == isClockedIn ? _self.isClockedIn : isClockedIn // ignore: cast_nullable_to_non_nullable
as bool,currentRecord: freezed == currentRecord ? _self.currentRecord : currentRecord // ignore: cast_nullable_to_non_nullable
as WorkRecordModel?,
  ));
}
/// Create a copy of WorkStatusModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkRecordModelCopyWith<$Res>? get currentRecord {
    if (_self.currentRecord == null) {
    return null;
  }

  return $WorkRecordModelCopyWith<$Res>(_self.currentRecord!, (value) {
    return _then(_self.copyWith(currentRecord: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkStatusModel].
extension WorkStatusModelPatterns on WorkStatusModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkStatusModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkStatusModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkStatusModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkStatusModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkStatusModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkStatusModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isClockedIn,  WorkRecordModel? currentRecord)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkStatusModel() when $default != null:
return $default(_that.isClockedIn,_that.currentRecord);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isClockedIn,  WorkRecordModel? currentRecord)  $default,) {final _that = this;
switch (_that) {
case _WorkStatusModel():
return $default(_that.isClockedIn,_that.currentRecord);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isClockedIn,  WorkRecordModel? currentRecord)?  $default,) {final _that = this;
switch (_that) {
case _WorkStatusModel() when $default != null:
return $default(_that.isClockedIn,_that.currentRecord);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkStatusModel implements WorkStatusModel {
  const _WorkStatusModel({required this.isClockedIn, this.currentRecord});
  factory _WorkStatusModel.fromJson(Map<String, dynamic> json) => _$WorkStatusModelFromJson(json);

@override final  bool isClockedIn;
@override final  WorkRecordModel? currentRecord;

/// Create a copy of WorkStatusModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkStatusModelCopyWith<_WorkStatusModel> get copyWith => __$WorkStatusModelCopyWithImpl<_WorkStatusModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkStatusModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkStatusModel&&(identical(other.isClockedIn, isClockedIn) || other.isClockedIn == isClockedIn)&&(identical(other.currentRecord, currentRecord) || other.currentRecord == currentRecord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isClockedIn,currentRecord);

@override
String toString() {
  return 'WorkStatusModel(isClockedIn: $isClockedIn, currentRecord: $currentRecord)';
}


}

/// @nodoc
abstract mixin class _$WorkStatusModelCopyWith<$Res> implements $WorkStatusModelCopyWith<$Res> {
  factory _$WorkStatusModelCopyWith(_WorkStatusModel value, $Res Function(_WorkStatusModel) _then) = __$WorkStatusModelCopyWithImpl;
@override @useResult
$Res call({
 bool isClockedIn, WorkRecordModel? currentRecord
});


@override $WorkRecordModelCopyWith<$Res>? get currentRecord;

}
/// @nodoc
class __$WorkStatusModelCopyWithImpl<$Res>
    implements _$WorkStatusModelCopyWith<$Res> {
  __$WorkStatusModelCopyWithImpl(this._self, this._then);

  final _WorkStatusModel _self;
  final $Res Function(_WorkStatusModel) _then;

/// Create a copy of WorkStatusModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isClockedIn = null,Object? currentRecord = freezed,}) {
  return _then(_WorkStatusModel(
isClockedIn: null == isClockedIn ? _self.isClockedIn : isClockedIn // ignore: cast_nullable_to_non_nullable
as bool,currentRecord: freezed == currentRecord ? _self.currentRecord : currentRecord // ignore: cast_nullable_to_non_nullable
as WorkRecordModel?,
  ));
}

/// Create a copy of WorkStatusModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkRecordModelCopyWith<$Res>? get currentRecord {
    if (_self.currentRecord == null) {
    return null;
  }

  return $WorkRecordModelCopyWith<$Res>(_self.currentRecord!, (value) {
    return _then(_self.copyWith(currentRecord: value));
  });
}
}

// dart format on
