// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_change_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatientChangeLog {

 String get id; String get patientId; String get userId; String get userName; DateTime get timestamp; String get changesJson;
/// Create a copy of PatientChangeLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatientChangeLogCopyWith<PatientChangeLog> get copyWith => _$PatientChangeLogCopyWithImpl<PatientChangeLog>(this as PatientChangeLog, _$identity);

  /// Serializes this PatientChangeLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PatientChangeLog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatientChangeLog&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.patientId, _this.patientId) || other.patientId == _this.patientId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.userName, _this.userName) || other.userName == _this.userName)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp)&&(identical(other.changesJson, _this.changesJson) || other.changesJson == _this.changesJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PatientChangeLog;
  return Object.hash(runtimeType,_this.id,_this.patientId,_this.userId,_this.userName,_this.timestamp,_this.changesJson);
}

@override
String toString() {
  final _this = this as PatientChangeLog;
  return 'PatientChangeLog(id: ${_this.id}, patientId: ${_this.patientId}, userId: ${_this.userId}, userName: ${_this.userName}, timestamp: ${_this.timestamp}, changesJson: ${_this.changesJson})';
}


}

/// @nodoc
abstract mixin class $PatientChangeLogCopyWith<$Res>  {
  factory $PatientChangeLogCopyWith(PatientChangeLog value, $Res Function(PatientChangeLog) _then) = _$PatientChangeLogCopyWithImpl;
@useResult
$Res call({
 String id, String patientId, String userId, String userName, DateTime timestamp, String changesJson
});




}
/// @nodoc
class _$PatientChangeLogCopyWithImpl<$Res>
    implements $PatientChangeLogCopyWith<$Res> {
  _$PatientChangeLogCopyWithImpl(this._self, this._then);

  final PatientChangeLog _self;
  final $Res Function(PatientChangeLog) _then;

/// Create a copy of PatientChangeLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? patientId = null,Object? userId = null,Object? userName = null,Object? timestamp = null,Object? changesJson = null,}) {
  return _then(PatientChangeLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,changesJson: null == changesJson ? _self.changesJson : changesJson // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PatientChangeLog].
extension PatientChangeLogPatterns on PatientChangeLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatientChangeLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatientChangeLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatientChangeLog value)  $default,){
final _that = this;
switch (_that) {
case _PatientChangeLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatientChangeLog value)?  $default,){
final _that = this;
switch (_that) {
case _PatientChangeLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String patientId,  String userId,  String userName,  DateTime timestamp,  String changesJson)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatientChangeLog() when $default != null:
return $default(_that.id,_that.patientId,_that.userId,_that.userName,_that.timestamp,_that.changesJson);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String patientId,  String userId,  String userName,  DateTime timestamp,  String changesJson)  $default,) {final _that = this;
switch (_that) {
case _PatientChangeLog():
return $default(_that.id,_that.patientId,_that.userId,_that.userName,_that.timestamp,_that.changesJson);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String patientId,  String userId,  String userName,  DateTime timestamp,  String changesJson)?  $default,) {final _that = this;
switch (_that) {
case _PatientChangeLog() when $default != null:
return $default(_that.id,_that.patientId,_that.userId,_that.userName,_that.timestamp,_that.changesJson);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatientChangeLog implements PatientChangeLog {
  const _PatientChangeLog({required this.id, required this.patientId, required this.userId, required this.userName, required this.timestamp, required this.changesJson});
  factory _PatientChangeLog.fromJson(Map<String, dynamic> json) => _$PatientChangeLogFromJson(json);

@override final  String id;
@override final  String patientId;
@override final  String userId;
@override final  String userName;
@override final  DateTime timestamp;
@override final  String changesJson;

/// Create a copy of PatientChangeLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatientChangeLogCopyWith<_PatientChangeLog> get copyWith => __$PatientChangeLogCopyWithImpl<_PatientChangeLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatientChangeLogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatientChangeLog&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.changesJson, changesJson) || other.changesJson == changesJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,patientId,userId,userName,timestamp,changesJson);
}

@override
String toString() {
    return 'PatientChangeLog(id: $id, patientId: $patientId, userId: $userId, userName: $userName, timestamp: $timestamp, changesJson: $changesJson)';
}


}

/// @nodoc
abstract mixin class _$PatientChangeLogCopyWith<$Res> implements $PatientChangeLogCopyWith<$Res> {
  factory _$PatientChangeLogCopyWith(_PatientChangeLog value, $Res Function(_PatientChangeLog) _then) = __$PatientChangeLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String patientId, String userId, String userName, DateTime timestamp, String changesJson
});




}
/// @nodoc
class __$PatientChangeLogCopyWithImpl<$Res>
    implements _$PatientChangeLogCopyWith<$Res> {
  __$PatientChangeLogCopyWithImpl(this._self, this._then);

  final _PatientChangeLog _self;
  final $Res Function(_PatientChangeLog) _then;

/// Create a copy of PatientChangeLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? patientId = null,Object? userId = null,Object? userName = null,Object? timestamp = null,Object? changesJson = null,}) {
  return _then(_PatientChangeLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,changesJson: null == changesJson ? _self.changesJson : changesJson // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
