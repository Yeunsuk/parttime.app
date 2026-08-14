// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workplace_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkplaceModel {

 int get id; String get name; String get inviteCode; int get hourlyWage; String get ownerName; int get memberLimit; List<int> get disabledHours; List<int> get enabledMinutes;
/// Create a copy of WorkplaceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkplaceModelCopyWith<WorkplaceModel> get copyWith => _$WorkplaceModelCopyWithImpl<WorkplaceModel>(this as WorkplaceModel, _$identity);

  /// Serializes this WorkplaceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkplaceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.hourlyWage, hourlyWage) || other.hourlyWage == hourlyWage)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.memberLimit, memberLimit) || other.memberLimit == memberLimit)&&const DeepCollectionEquality().equals(other.disabledHours, disabledHours)&&const DeepCollectionEquality().equals(other.enabledMinutes, enabledMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,inviteCode,hourlyWage,ownerName,memberLimit,const DeepCollectionEquality().hash(disabledHours),const DeepCollectionEquality().hash(enabledMinutes));

@override
String toString() {
  return 'WorkplaceModel(id: $id, name: $name, inviteCode: $inviteCode, hourlyWage: $hourlyWage, ownerName: $ownerName, memberLimit: $memberLimit, disabledHours: $disabledHours, enabledMinutes: $enabledMinutes)';
}


}

/// @nodoc
abstract mixin class $WorkplaceModelCopyWith<$Res>  {
  factory $WorkplaceModelCopyWith(WorkplaceModel value, $Res Function(WorkplaceModel) _then) = _$WorkplaceModelCopyWithImpl;
@useResult
$Res call({
 int id, String name, String inviteCode, int hourlyWage, String ownerName, int memberLimit, List<int> disabledHours, List<int> enabledMinutes
});




}
/// @nodoc
class _$WorkplaceModelCopyWithImpl<$Res>
    implements $WorkplaceModelCopyWith<$Res> {
  _$WorkplaceModelCopyWithImpl(this._self, this._then);

  final WorkplaceModel _self;
  final $Res Function(WorkplaceModel) _then;

/// Create a copy of WorkplaceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? inviteCode = null,Object? hourlyWage = null,Object? ownerName = null,Object? memberLimit = null,Object? disabledHours = null,Object? enabledMinutes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,hourlyWage: null == hourlyWage ? _self.hourlyWage : hourlyWage // ignore: cast_nullable_to_non_nullable
as int,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,memberLimit: null == memberLimit ? _self.memberLimit : memberLimit // ignore: cast_nullable_to_non_nullable
as int,disabledHours: null == disabledHours ? _self.disabledHours : disabledHours // ignore: cast_nullable_to_non_nullable
as List<int>,enabledMinutes: null == enabledMinutes ? _self.enabledMinutes : enabledMinutes // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkplaceModel].
extension WorkplaceModelPatterns on WorkplaceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkplaceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkplaceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkplaceModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkplaceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkplaceModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkplaceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String inviteCode,  int hourlyWage,  String ownerName,  int memberLimit,  List<int> disabledHours,  List<int> enabledMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkplaceModel() when $default != null:
return $default(_that.id,_that.name,_that.inviteCode,_that.hourlyWage,_that.ownerName,_that.memberLimit,_that.disabledHours,_that.enabledMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String inviteCode,  int hourlyWage,  String ownerName,  int memberLimit,  List<int> disabledHours,  List<int> enabledMinutes)  $default,) {final _that = this;
switch (_that) {
case _WorkplaceModel():
return $default(_that.id,_that.name,_that.inviteCode,_that.hourlyWage,_that.ownerName,_that.memberLimit,_that.disabledHours,_that.enabledMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String inviteCode,  int hourlyWage,  String ownerName,  int memberLimit,  List<int> disabledHours,  List<int> enabledMinutes)?  $default,) {final _that = this;
switch (_that) {
case _WorkplaceModel() when $default != null:
return $default(_that.id,_that.name,_that.inviteCode,_that.hourlyWage,_that.ownerName,_that.memberLimit,_that.disabledHours,_that.enabledMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkplaceModel implements WorkplaceModel {
  const _WorkplaceModel({required this.id, required this.name, required this.inviteCode, required this.hourlyWage, required this.ownerName, required this.memberLimit, final  List<int> disabledHours = const <int>[], final  List<int> enabledMinutes = const <int>[0, 30]}): _disabledHours = disabledHours,_enabledMinutes = enabledMinutes;
  factory _WorkplaceModel.fromJson(Map<String, dynamic> json) => _$WorkplaceModelFromJson(json);

@override final  int id;
@override final  String name;
@override final  String inviteCode;
@override final  int hourlyWage;
@override final  String ownerName;
@override final  int memberLimit;
 final  List<int> _disabledHours;
@override@JsonKey() List<int> get disabledHours {
  if (_disabledHours is EqualUnmodifiableListView) return _disabledHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_disabledHours);
}

 final  List<int> _enabledMinutes;
@override@JsonKey() List<int> get enabledMinutes {
  if (_enabledMinutes is EqualUnmodifiableListView) return _enabledMinutes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_enabledMinutes);
}


/// Create a copy of WorkplaceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkplaceModelCopyWith<_WorkplaceModel> get copyWith => __$WorkplaceModelCopyWithImpl<_WorkplaceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkplaceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkplaceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.hourlyWage, hourlyWage) || other.hourlyWage == hourlyWage)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.memberLimit, memberLimit) || other.memberLimit == memberLimit)&&const DeepCollectionEquality().equals(other._disabledHours, _disabledHours)&&const DeepCollectionEquality().equals(other._enabledMinutes, _enabledMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,inviteCode,hourlyWage,ownerName,memberLimit,const DeepCollectionEquality().hash(_disabledHours),const DeepCollectionEquality().hash(_enabledMinutes));

@override
String toString() {
  return 'WorkplaceModel(id: $id, name: $name, inviteCode: $inviteCode, hourlyWage: $hourlyWage, ownerName: $ownerName, memberLimit: $memberLimit, disabledHours: $disabledHours, enabledMinutes: $enabledMinutes)';
}


}

/// @nodoc
abstract mixin class _$WorkplaceModelCopyWith<$Res> implements $WorkplaceModelCopyWith<$Res> {
  factory _$WorkplaceModelCopyWith(_WorkplaceModel value, $Res Function(_WorkplaceModel) _then) = __$WorkplaceModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String inviteCode, int hourlyWage, String ownerName, int memberLimit, List<int> disabledHours, List<int> enabledMinutes
});




}
/// @nodoc
class __$WorkplaceModelCopyWithImpl<$Res>
    implements _$WorkplaceModelCopyWith<$Res> {
  __$WorkplaceModelCopyWithImpl(this._self, this._then);

  final _WorkplaceModel _self;
  final $Res Function(_WorkplaceModel) _then;

/// Create a copy of WorkplaceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? inviteCode = null,Object? hourlyWage = null,Object? ownerName = null,Object? memberLimit = null,Object? disabledHours = null,Object? enabledMinutes = null,}) {
  return _then(_WorkplaceModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,hourlyWage: null == hourlyWage ? _self.hourlyWage : hourlyWage // ignore: cast_nullable_to_non_nullable
as int,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,memberLimit: null == memberLimit ? _self.memberLimit : memberLimit // ignore: cast_nullable_to_non_nullable
as int,disabledHours: null == disabledHours ? _self._disabledHours : disabledHours // ignore: cast_nullable_to_non_nullable
as List<int>,enabledMinutes: null == enabledMinutes ? _self._enabledMinutes : enabledMinutes // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$WorkerModel {

 int get id; String get name; int? get defaultClockInHour; int? get defaultClockInMinute; int? get defaultClockOutHour; int? get defaultClockOutMinute; int? get payPeriodStartDay; String get paymentType; bool get workingDaysEnabled; List<int> get workingDays;
/// Create a copy of WorkerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerModelCopyWith<WorkerModel> get copyWith => _$WorkerModelCopyWithImpl<WorkerModel>(this as WorkerModel, _$identity);

  /// Serializes this WorkerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.defaultClockInHour, defaultClockInHour) || other.defaultClockInHour == defaultClockInHour)&&(identical(other.defaultClockInMinute, defaultClockInMinute) || other.defaultClockInMinute == defaultClockInMinute)&&(identical(other.defaultClockOutHour, defaultClockOutHour) || other.defaultClockOutHour == defaultClockOutHour)&&(identical(other.defaultClockOutMinute, defaultClockOutMinute) || other.defaultClockOutMinute == defaultClockOutMinute)&&(identical(other.payPeriodStartDay, payPeriodStartDay) || other.payPeriodStartDay == payPeriodStartDay)&&(identical(other.paymentType, paymentType) || other.paymentType == paymentType)&&(identical(other.workingDaysEnabled, workingDaysEnabled) || other.workingDaysEnabled == workingDaysEnabled)&&const DeepCollectionEquality().equals(other.workingDays, workingDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,defaultClockInHour,defaultClockInMinute,defaultClockOutHour,defaultClockOutMinute,payPeriodStartDay,paymentType,workingDaysEnabled,const DeepCollectionEquality().hash(workingDays));

@override
String toString() {
  return 'WorkerModel(id: $id, name: $name, defaultClockInHour: $defaultClockInHour, defaultClockInMinute: $defaultClockInMinute, defaultClockOutHour: $defaultClockOutHour, defaultClockOutMinute: $defaultClockOutMinute, payPeriodStartDay: $payPeriodStartDay, paymentType: $paymentType, workingDaysEnabled: $workingDaysEnabled, workingDays: $workingDays)';
}


}

/// @nodoc
abstract mixin class $WorkerModelCopyWith<$Res>  {
  factory $WorkerModelCopyWith(WorkerModel value, $Res Function(WorkerModel) _then) = _$WorkerModelCopyWithImpl;
@useResult
$Res call({
 int id, String name, int? defaultClockInHour, int? defaultClockInMinute, int? defaultClockOutHour, int? defaultClockOutMinute, int? payPeriodStartDay, String paymentType, bool workingDaysEnabled, List<int> workingDays
});




}
/// @nodoc
class _$WorkerModelCopyWithImpl<$Res>
    implements $WorkerModelCopyWith<$Res> {
  _$WorkerModelCopyWithImpl(this._self, this._then);

  final WorkerModel _self;
  final $Res Function(WorkerModel) _then;

/// Create a copy of WorkerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? defaultClockInHour = freezed,Object? defaultClockInMinute = freezed,Object? defaultClockOutHour = freezed,Object? defaultClockOutMinute = freezed,Object? payPeriodStartDay = freezed,Object? paymentType = null,Object? workingDaysEnabled = null,Object? workingDays = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,defaultClockInHour: freezed == defaultClockInHour ? _self.defaultClockInHour : defaultClockInHour // ignore: cast_nullable_to_non_nullable
as int?,defaultClockInMinute: freezed == defaultClockInMinute ? _self.defaultClockInMinute : defaultClockInMinute // ignore: cast_nullable_to_non_nullable
as int?,defaultClockOutHour: freezed == defaultClockOutHour ? _self.defaultClockOutHour : defaultClockOutHour // ignore: cast_nullable_to_non_nullable
as int?,defaultClockOutMinute: freezed == defaultClockOutMinute ? _self.defaultClockOutMinute : defaultClockOutMinute // ignore: cast_nullable_to_non_nullable
as int?,payPeriodStartDay: freezed == payPeriodStartDay ? _self.payPeriodStartDay : payPeriodStartDay // ignore: cast_nullable_to_non_nullable
as int?,paymentType: null == paymentType ? _self.paymentType : paymentType // ignore: cast_nullable_to_non_nullable
as String,workingDaysEnabled: null == workingDaysEnabled ? _self.workingDaysEnabled : workingDaysEnabled // ignore: cast_nullable_to_non_nullable
as bool,workingDays: null == workingDays ? _self.workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkerModel].
extension WorkerModelPatterns on WorkerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkerModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkerModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int? defaultClockInHour,  int? defaultClockInMinute,  int? defaultClockOutHour,  int? defaultClockOutMinute,  int? payPeriodStartDay,  String paymentType,  bool workingDaysEnabled,  List<int> workingDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkerModel() when $default != null:
return $default(_that.id,_that.name,_that.defaultClockInHour,_that.defaultClockInMinute,_that.defaultClockOutHour,_that.defaultClockOutMinute,_that.payPeriodStartDay,_that.paymentType,_that.workingDaysEnabled,_that.workingDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int? defaultClockInHour,  int? defaultClockInMinute,  int? defaultClockOutHour,  int? defaultClockOutMinute,  int? payPeriodStartDay,  String paymentType,  bool workingDaysEnabled,  List<int> workingDays)  $default,) {final _that = this;
switch (_that) {
case _WorkerModel():
return $default(_that.id,_that.name,_that.defaultClockInHour,_that.defaultClockInMinute,_that.defaultClockOutHour,_that.defaultClockOutMinute,_that.payPeriodStartDay,_that.paymentType,_that.workingDaysEnabled,_that.workingDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int? defaultClockInHour,  int? defaultClockInMinute,  int? defaultClockOutHour,  int? defaultClockOutMinute,  int? payPeriodStartDay,  String paymentType,  bool workingDaysEnabled,  List<int> workingDays)?  $default,) {final _that = this;
switch (_that) {
case _WorkerModel() when $default != null:
return $default(_that.id,_that.name,_that.defaultClockInHour,_that.defaultClockInMinute,_that.defaultClockOutHour,_that.defaultClockOutMinute,_that.payPeriodStartDay,_that.paymentType,_that.workingDaysEnabled,_that.workingDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkerModel implements WorkerModel {
  const _WorkerModel({required this.id, required this.name, this.defaultClockInHour, this.defaultClockInMinute, this.defaultClockOutHour, this.defaultClockOutMinute, this.payPeriodStartDay, this.paymentType = 'TIME', this.workingDaysEnabled = false, final  List<int> workingDays = const <int>[]}): _workingDays = workingDays;
  factory _WorkerModel.fromJson(Map<String, dynamic> json) => _$WorkerModelFromJson(json);

@override final  int id;
@override final  String name;
@override final  int? defaultClockInHour;
@override final  int? defaultClockInMinute;
@override final  int? defaultClockOutHour;
@override final  int? defaultClockOutMinute;
@override final  int? payPeriodStartDay;
@override@JsonKey() final  String paymentType;
@override@JsonKey() final  bool workingDaysEnabled;
 final  List<int> _workingDays;
@override@JsonKey() List<int> get workingDays {
  if (_workingDays is EqualUnmodifiableListView) return _workingDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workingDays);
}


/// Create a copy of WorkerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerModelCopyWith<_WorkerModel> get copyWith => __$WorkerModelCopyWithImpl<_WorkerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.defaultClockInHour, defaultClockInHour) || other.defaultClockInHour == defaultClockInHour)&&(identical(other.defaultClockInMinute, defaultClockInMinute) || other.defaultClockInMinute == defaultClockInMinute)&&(identical(other.defaultClockOutHour, defaultClockOutHour) || other.defaultClockOutHour == defaultClockOutHour)&&(identical(other.defaultClockOutMinute, defaultClockOutMinute) || other.defaultClockOutMinute == defaultClockOutMinute)&&(identical(other.payPeriodStartDay, payPeriodStartDay) || other.payPeriodStartDay == payPeriodStartDay)&&(identical(other.paymentType, paymentType) || other.paymentType == paymentType)&&(identical(other.workingDaysEnabled, workingDaysEnabled) || other.workingDaysEnabled == workingDaysEnabled)&&const DeepCollectionEquality().equals(other._workingDays, _workingDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,defaultClockInHour,defaultClockInMinute,defaultClockOutHour,defaultClockOutMinute,payPeriodStartDay,paymentType,workingDaysEnabled,const DeepCollectionEquality().hash(_workingDays));

@override
String toString() {
  return 'WorkerModel(id: $id, name: $name, defaultClockInHour: $defaultClockInHour, defaultClockInMinute: $defaultClockInMinute, defaultClockOutHour: $defaultClockOutHour, defaultClockOutMinute: $defaultClockOutMinute, payPeriodStartDay: $payPeriodStartDay, paymentType: $paymentType, workingDaysEnabled: $workingDaysEnabled, workingDays: $workingDays)';
}


}

/// @nodoc
abstract mixin class _$WorkerModelCopyWith<$Res> implements $WorkerModelCopyWith<$Res> {
  factory _$WorkerModelCopyWith(_WorkerModel value, $Res Function(_WorkerModel) _then) = __$WorkerModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int? defaultClockInHour, int? defaultClockInMinute, int? defaultClockOutHour, int? defaultClockOutMinute, int? payPeriodStartDay, String paymentType, bool workingDaysEnabled, List<int> workingDays
});




}
/// @nodoc
class __$WorkerModelCopyWithImpl<$Res>
    implements _$WorkerModelCopyWith<$Res> {
  __$WorkerModelCopyWithImpl(this._self, this._then);

  final _WorkerModel _self;
  final $Res Function(_WorkerModel) _then;

/// Create a copy of WorkerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? defaultClockInHour = freezed,Object? defaultClockInMinute = freezed,Object? defaultClockOutHour = freezed,Object? defaultClockOutMinute = freezed,Object? payPeriodStartDay = freezed,Object? paymentType = null,Object? workingDaysEnabled = null,Object? workingDays = null,}) {
  return _then(_WorkerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,defaultClockInHour: freezed == defaultClockInHour ? _self.defaultClockInHour : defaultClockInHour // ignore: cast_nullable_to_non_nullable
as int?,defaultClockInMinute: freezed == defaultClockInMinute ? _self.defaultClockInMinute : defaultClockInMinute // ignore: cast_nullable_to_non_nullable
as int?,defaultClockOutHour: freezed == defaultClockOutHour ? _self.defaultClockOutHour : defaultClockOutHour // ignore: cast_nullable_to_non_nullable
as int?,defaultClockOutMinute: freezed == defaultClockOutMinute ? _self.defaultClockOutMinute : defaultClockOutMinute // ignore: cast_nullable_to_non_nullable
as int?,payPeriodStartDay: freezed == payPeriodStartDay ? _self.payPeriodStartDay : payPeriodStartDay // ignore: cast_nullable_to_non_nullable
as int?,paymentType: null == paymentType ? _self.paymentType : paymentType // ignore: cast_nullable_to_non_nullable
as String,workingDaysEnabled: null == workingDaysEnabled ? _self.workingDaysEnabled : workingDaysEnabled // ignore: cast_nullable_to_non_nullable
as bool,workingDays: null == workingDays ? _self._workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
