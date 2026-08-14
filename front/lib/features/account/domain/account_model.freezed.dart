// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountModel {

 int get id; String get accountName; String get accountNumber; String get bankName; List<AccountQrModel> get qrCodes;
/// Create a copy of AccountModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountModelCopyWith<AccountModel> get copyWith => _$AccountModelCopyWithImpl<AccountModel>(this as AccountModel, _$identity);

  /// Serializes this AccountModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountModel&&(identical(other.id, id) || other.id == id)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&const DeepCollectionEquality().equals(other.qrCodes, qrCodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountName,accountNumber,bankName,const DeepCollectionEquality().hash(qrCodes));

@override
String toString() {
  return 'AccountModel(id: $id, accountName: $accountName, accountNumber: $accountNumber, bankName: $bankName, qrCodes: $qrCodes)';
}


}

/// @nodoc
abstract mixin class $AccountModelCopyWith<$Res>  {
  factory $AccountModelCopyWith(AccountModel value, $Res Function(AccountModel) _then) = _$AccountModelCopyWithImpl;
@useResult
$Res call({
 int id, String accountName, String accountNumber, String bankName, List<AccountQrModel> qrCodes
});




}
/// @nodoc
class _$AccountModelCopyWithImpl<$Res>
    implements $AccountModelCopyWith<$Res> {
  _$AccountModelCopyWithImpl(this._self, this._then);

  final AccountModel _self;
  final $Res Function(AccountModel) _then;

/// Create a copy of AccountModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountName = null,Object? accountNumber = null,Object? bankName = null,Object? qrCodes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,bankName: null == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String,qrCodes: null == qrCodes ? _self.qrCodes : qrCodes // ignore: cast_nullable_to_non_nullable
as List<AccountQrModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountModel].
extension AccountModelPatterns on AccountModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountModel value)  $default,){
final _that = this;
switch (_that) {
case _AccountModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountModel value)?  $default,){
final _that = this;
switch (_that) {
case _AccountModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String accountName,  String accountNumber,  String bankName,  List<AccountQrModel> qrCodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountModel() when $default != null:
return $default(_that.id,_that.accountName,_that.accountNumber,_that.bankName,_that.qrCodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String accountName,  String accountNumber,  String bankName,  List<AccountQrModel> qrCodes)  $default,) {final _that = this;
switch (_that) {
case _AccountModel():
return $default(_that.id,_that.accountName,_that.accountNumber,_that.bankName,_that.qrCodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String accountName,  String accountNumber,  String bankName,  List<AccountQrModel> qrCodes)?  $default,) {final _that = this;
switch (_that) {
case _AccountModel() when $default != null:
return $default(_that.id,_that.accountName,_that.accountNumber,_that.bankName,_that.qrCodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountModel implements AccountModel {
  const _AccountModel({required this.id, required this.accountName, required this.accountNumber, required this.bankName, final  List<AccountQrModel> qrCodes = const <AccountQrModel>[]}): _qrCodes = qrCodes;
  factory _AccountModel.fromJson(Map<String, dynamic> json) => _$AccountModelFromJson(json);

@override final  int id;
@override final  String accountName;
@override final  String accountNumber;
@override final  String bankName;
 final  List<AccountQrModel> _qrCodes;
@override@JsonKey() List<AccountQrModel> get qrCodes {
  if (_qrCodes is EqualUnmodifiableListView) return _qrCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_qrCodes);
}


/// Create a copy of AccountModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountModelCopyWith<_AccountModel> get copyWith => __$AccountModelCopyWithImpl<_AccountModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountModel&&(identical(other.id, id) || other.id == id)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&const DeepCollectionEquality().equals(other._qrCodes, _qrCodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountName,accountNumber,bankName,const DeepCollectionEquality().hash(_qrCodes));

@override
String toString() {
  return 'AccountModel(id: $id, accountName: $accountName, accountNumber: $accountNumber, bankName: $bankName, qrCodes: $qrCodes)';
}


}

/// @nodoc
abstract mixin class _$AccountModelCopyWith<$Res> implements $AccountModelCopyWith<$Res> {
  factory _$AccountModelCopyWith(_AccountModel value, $Res Function(_AccountModel) _then) = __$AccountModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String accountName, String accountNumber, String bankName, List<AccountQrModel> qrCodes
});




}
/// @nodoc
class __$AccountModelCopyWithImpl<$Res>
    implements _$AccountModelCopyWith<$Res> {
  __$AccountModelCopyWithImpl(this._self, this._then);

  final _AccountModel _self;
  final $Res Function(_AccountModel) _then;

/// Create a copy of AccountModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountName = null,Object? accountNumber = null,Object? bankName = null,Object? qrCodes = null,}) {
  return _then(_AccountModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,bankName: null == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String,qrCodes: null == qrCodes ? _self._qrCodes : qrCodes // ignore: cast_nullable_to_non_nullable
as List<AccountQrModel>,
  ));
}


}


/// @nodoc
mixin _$AccountQrModel {

 int get id; String get name; String get qrImage;
/// Create a copy of AccountQrModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountQrModelCopyWith<AccountQrModel> get copyWith => _$AccountQrModelCopyWithImpl<AccountQrModel>(this as AccountQrModel, _$identity);

  /// Serializes this AccountQrModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountQrModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.qrImage, qrImage) || other.qrImage == qrImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,qrImage);

@override
String toString() {
  return 'AccountQrModel(id: $id, name: $name, qrImage: $qrImage)';
}


}

/// @nodoc
abstract mixin class $AccountQrModelCopyWith<$Res>  {
  factory $AccountQrModelCopyWith(AccountQrModel value, $Res Function(AccountQrModel) _then) = _$AccountQrModelCopyWithImpl;
@useResult
$Res call({
 int id, String name, String qrImage
});




}
/// @nodoc
class _$AccountQrModelCopyWithImpl<$Res>
    implements $AccountQrModelCopyWith<$Res> {
  _$AccountQrModelCopyWithImpl(this._self, this._then);

  final AccountQrModel _self;
  final $Res Function(AccountQrModel) _then;

/// Create a copy of AccountQrModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? qrImage = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,qrImage: null == qrImage ? _self.qrImage : qrImage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountQrModel].
extension AccountQrModelPatterns on AccountQrModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountQrModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountQrModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountQrModel value)  $default,){
final _that = this;
switch (_that) {
case _AccountQrModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountQrModel value)?  $default,){
final _that = this;
switch (_that) {
case _AccountQrModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String qrImage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountQrModel() when $default != null:
return $default(_that.id,_that.name,_that.qrImage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String qrImage)  $default,) {final _that = this;
switch (_that) {
case _AccountQrModel():
return $default(_that.id,_that.name,_that.qrImage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String qrImage)?  $default,) {final _that = this;
switch (_that) {
case _AccountQrModel() when $default != null:
return $default(_that.id,_that.name,_that.qrImage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountQrModel implements AccountQrModel {
  const _AccountQrModel({required this.id, required this.name, required this.qrImage});
  factory _AccountQrModel.fromJson(Map<String, dynamic> json) => _$AccountQrModelFromJson(json);

@override final  int id;
@override final  String name;
@override final  String qrImage;

/// Create a copy of AccountQrModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountQrModelCopyWith<_AccountQrModel> get copyWith => __$AccountQrModelCopyWithImpl<_AccountQrModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountQrModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountQrModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.qrImage, qrImage) || other.qrImage == qrImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,qrImage);

@override
String toString() {
  return 'AccountQrModel(id: $id, name: $name, qrImage: $qrImage)';
}


}

/// @nodoc
abstract mixin class _$AccountQrModelCopyWith<$Res> implements $AccountQrModelCopyWith<$Res> {
  factory _$AccountQrModelCopyWith(_AccountQrModel value, $Res Function(_AccountQrModel) _then) = __$AccountQrModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String qrImage
});




}
/// @nodoc
class __$AccountQrModelCopyWithImpl<$Res>
    implements _$AccountQrModelCopyWith<$Res> {
  __$AccountQrModelCopyWithImpl(this._self, this._then);

  final _AccountQrModel _self;
  final $Res Function(_AccountQrModel) _then;

/// Create a copy of AccountQrModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? qrImage = null,}) {
  return _then(_AccountQrModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,qrImage: null == qrImage ? _self.qrImage : qrImage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
