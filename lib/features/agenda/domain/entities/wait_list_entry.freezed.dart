// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wait_list_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WaitListEntry {

 String get id; String get patientId; String get patientName; String get clinicId; String get priority; String get specialty; String? get observation; DateTime get createdAt;
/// Create a copy of WaitListEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaitListEntryCopyWith<WaitListEntry> get copyWith => _$WaitListEntryCopyWithImpl<WaitListEntry>(this as WaitListEntry, _$identity);

  /// Serializes this WaitListEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WaitListEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WaitListEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.patientId, _this.patientId) || other.patientId == _this.patientId)&&(identical(other.patientName, _this.patientName) || other.patientName == _this.patientName)&&(identical(other.clinicId, _this.clinicId) || other.clinicId == _this.clinicId)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.specialty, _this.specialty) || other.specialty == _this.specialty)&&(identical(other.observation, _this.observation) || other.observation == _this.observation)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WaitListEntry;
  return Object.hash(runtimeType,_this.id,_this.patientId,_this.patientName,_this.clinicId,_this.priority,_this.specialty,_this.observation,_this.createdAt);
}

@override
String toString() {
  final _this = this as WaitListEntry;
  return 'WaitListEntry(id: ${_this.id}, patientId: ${_this.patientId}, patientName: ${_this.patientName}, clinicId: ${_this.clinicId}, priority: ${_this.priority}, specialty: ${_this.specialty}, observation: ${_this.observation}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $WaitListEntryCopyWith<$Res>  {
  factory $WaitListEntryCopyWith(WaitListEntry value, $Res Function(WaitListEntry) _then) = _$WaitListEntryCopyWithImpl;
@useResult
$Res call({
 String id, String patientId, String patientName, String clinicId, String priority, String specialty, String? observation, DateTime createdAt
});




}
/// @nodoc
class _$WaitListEntryCopyWithImpl<$Res>
    implements $WaitListEntryCopyWith<$Res> {
  _$WaitListEntryCopyWithImpl(this._self, this._then);

  final WaitListEntry _self;
  final $Res Function(WaitListEntry) _then;

/// Create a copy of WaitListEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? patientId = null,Object? patientName = null,Object? clinicId = null,Object? priority = null,Object? specialty = null,Object? observation = freezed,Object? createdAt = null,}) {
  return _then(WaitListEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,clinicId: null == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,observation: freezed == observation ? _self.observation : observation // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WaitListEntry].
extension WaitListEntryPatterns on WaitListEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WaitListEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WaitListEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WaitListEntry value)  $default,){
final _that = this;
switch (_that) {
case _WaitListEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WaitListEntry value)?  $default,){
final _that = this;
switch (_that) {
case _WaitListEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String patientId,  String patientName,  String clinicId,  String priority,  String specialty,  String? observation,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WaitListEntry() when $default != null:
return $default(_that.id,_that.patientId,_that.patientName,_that.clinicId,_that.priority,_that.specialty,_that.observation,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String patientId,  String patientName,  String clinicId,  String priority,  String specialty,  String? observation,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _WaitListEntry():
return $default(_that.id,_that.patientId,_that.patientName,_that.clinicId,_that.priority,_that.specialty,_that.observation,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String patientId,  String patientName,  String clinicId,  String priority,  String specialty,  String? observation,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WaitListEntry() when $default != null:
return $default(_that.id,_that.patientId,_that.patientName,_that.clinicId,_that.priority,_that.specialty,_that.observation,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WaitListEntry implements WaitListEntry {
  const _WaitListEntry({required this.id, required this.patientId, required this.patientName, required this.clinicId, required this.priority, required this.specialty, this.observation, required this.createdAt});
  factory _WaitListEntry.fromJson(Map<String, dynamic> json) => _$WaitListEntryFromJson(json);

@override final  String id;
@override final  String patientId;
@override final  String patientName;
@override final  String clinicId;
@override final  String priority;
@override final  String specialty;
@override final  String? observation;
@override final  DateTime createdAt;

/// Create a copy of WaitListEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WaitListEntryCopyWith<_WaitListEntry> get copyWith => __$WaitListEntryCopyWithImpl<_WaitListEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WaitListEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WaitListEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.clinicId, clinicId) || other.clinicId == clinicId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.observation, observation) || other.observation == observation)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,patientId,patientName,clinicId,priority,specialty,observation,createdAt);
}

@override
String toString() {
    return 'WaitListEntry(id: $id, patientId: $patientId, patientName: $patientName, clinicId: $clinicId, priority: $priority, specialty: $specialty, observation: $observation, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WaitListEntryCopyWith<$Res> implements $WaitListEntryCopyWith<$Res> {
  factory _$WaitListEntryCopyWith(_WaitListEntry value, $Res Function(_WaitListEntry) _then) = __$WaitListEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String patientId, String patientName, String clinicId, String priority, String specialty, String? observation, DateTime createdAt
});




}
/// @nodoc
class __$WaitListEntryCopyWithImpl<$Res>
    implements _$WaitListEntryCopyWith<$Res> {
  __$WaitListEntryCopyWithImpl(this._self, this._then);

  final _WaitListEntry _self;
  final $Res Function(_WaitListEntry) _then;

/// Create a copy of WaitListEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? patientId = null,Object? patientName = null,Object? clinicId = null,Object? priority = null,Object? specialty = null,Object? observation = freezed,Object? createdAt = null,}) {
  return _then(_WaitListEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,clinicId: null == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,observation: freezed == observation ? _self.observation : observation // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
