// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Appointment {

 String get id; String get patientId; String get patientName; String get doctorId; String get doctorName; String? get studentId; String? get studentName; String? get professorId; String? get professorName; DateTime get startTime; DateTime get endTime; AppointmentStatus get status; String? get procedureName; String? get notes; String get clinicId; DateTime? get arrivalTime; DateTime? get actualStartTime; DateTime? get actualEndTime;
/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentCopyWith<Appointment> get copyWith => _$AppointmentCopyWithImpl<Appointment>(this as Appointment, _$identity);

  /// Serializes this Appointment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Appointment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Appointment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.patientId, _this.patientId) || other.patientId == _this.patientId)&&(identical(other.patientName, _this.patientName) || other.patientName == _this.patientName)&&(identical(other.doctorId, _this.doctorId) || other.doctorId == _this.doctorId)&&(identical(other.doctorName, _this.doctorName) || other.doctorName == _this.doctorName)&&(identical(other.studentId, _this.studentId) || other.studentId == _this.studentId)&&(identical(other.studentName, _this.studentName) || other.studentName == _this.studentName)&&(identical(other.professorId, _this.professorId) || other.professorId == _this.professorId)&&(identical(other.professorName, _this.professorName) || other.professorName == _this.professorName)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.procedureName, _this.procedureName) || other.procedureName == _this.procedureName)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.clinicId, _this.clinicId) || other.clinicId == _this.clinicId)&&(identical(other.arrivalTime, _this.arrivalTime) || other.arrivalTime == _this.arrivalTime)&&(identical(other.actualStartTime, _this.actualStartTime) || other.actualStartTime == _this.actualStartTime)&&(identical(other.actualEndTime, _this.actualEndTime) || other.actualEndTime == _this.actualEndTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Appointment;
  return Object.hash(runtimeType,_this.id,_this.patientId,_this.patientName,_this.doctorId,_this.doctorName,_this.studentId,_this.studentName,_this.professorId,_this.professorName,_this.startTime,_this.endTime,_this.status,_this.procedureName,_this.notes,_this.clinicId,_this.arrivalTime,_this.actualStartTime,_this.actualEndTime);
}

@override
String toString() {
  final _this = this as Appointment;
  return 'Appointment(id: ${_this.id}, patientId: ${_this.patientId}, patientName: ${_this.patientName}, doctorId: ${_this.doctorId}, doctorName: ${_this.doctorName}, studentId: ${_this.studentId}, studentName: ${_this.studentName}, professorId: ${_this.professorId}, professorName: ${_this.professorName}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, status: ${_this.status}, procedureName: ${_this.procedureName}, notes: ${_this.notes}, clinicId: ${_this.clinicId}, arrivalTime: ${_this.arrivalTime}, actualStartTime: ${_this.actualStartTime}, actualEndTime: ${_this.actualEndTime})';
}


}

/// @nodoc
abstract mixin class $AppointmentCopyWith<$Res>  {
  factory $AppointmentCopyWith(Appointment value, $Res Function(Appointment) _then) = _$AppointmentCopyWithImpl;
@useResult
$Res call({
 String id, String patientId, String patientName, String doctorId, String doctorName, String? studentId, String? studentName, String? professorId, String? professorName, DateTime startTime, DateTime endTime, AppointmentStatus status, String? procedureName, String? notes, String clinicId, DateTime? arrivalTime, DateTime? actualStartTime, DateTime? actualEndTime
});




}
/// @nodoc
class _$AppointmentCopyWithImpl<$Res>
    implements $AppointmentCopyWith<$Res> {
  _$AppointmentCopyWithImpl(this._self, this._then);

  final Appointment _self;
  final $Res Function(Appointment) _then;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? patientId = null,Object? patientName = null,Object? doctorId = null,Object? doctorName = null,Object? studentId = freezed,Object? studentName = freezed,Object? professorId = freezed,Object? professorName = freezed,Object? startTime = null,Object? endTime = null,Object? status = null,Object? procedureName = freezed,Object? notes = freezed,Object? clinicId = null,Object? arrivalTime = freezed,Object? actualStartTime = freezed,Object? actualEndTime = freezed,}) {
  return _then(Appointment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,professorId: freezed == professorId ? _self.professorId : professorId // ignore: cast_nullable_to_non_nullable
as String?,professorName: freezed == professorName ? _self.professorName : professorName // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppointmentStatus,procedureName: freezed == procedureName ? _self.procedureName : procedureName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,clinicId: null == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as String,arrivalTime: freezed == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,actualStartTime: freezed == actualStartTime ? _self.actualStartTime : actualStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,actualEndTime: freezed == actualEndTime ? _self.actualEndTime : actualEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Appointment].
extension AppointmentPatterns on Appointment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Appointment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Appointment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Appointment value)  $default,){
final _that = this;
switch (_that) {
case _Appointment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Appointment value)?  $default,){
final _that = this;
switch (_that) {
case _Appointment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String patientId,  String patientName,  String doctorId,  String doctorName,  String? studentId,  String? studentName,  String? professorId,  String? professorName,  DateTime startTime,  DateTime endTime,  AppointmentStatus status,  String? procedureName,  String? notes,  String clinicId,  DateTime? arrivalTime,  DateTime? actualStartTime,  DateTime? actualEndTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that.id,_that.patientId,_that.patientName,_that.doctorId,_that.doctorName,_that.studentId,_that.studentName,_that.professorId,_that.professorName,_that.startTime,_that.endTime,_that.status,_that.procedureName,_that.notes,_that.clinicId,_that.arrivalTime,_that.actualStartTime,_that.actualEndTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String patientId,  String patientName,  String doctorId,  String doctorName,  String? studentId,  String? studentName,  String? professorId,  String? professorName,  DateTime startTime,  DateTime endTime,  AppointmentStatus status,  String? procedureName,  String? notes,  String clinicId,  DateTime? arrivalTime,  DateTime? actualStartTime,  DateTime? actualEndTime)  $default,) {final _that = this;
switch (_that) {
case _Appointment():
return $default(_that.id,_that.patientId,_that.patientName,_that.doctorId,_that.doctorName,_that.studentId,_that.studentName,_that.professorId,_that.professorName,_that.startTime,_that.endTime,_that.status,_that.procedureName,_that.notes,_that.clinicId,_that.arrivalTime,_that.actualStartTime,_that.actualEndTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String patientId,  String patientName,  String doctorId,  String doctorName,  String? studentId,  String? studentName,  String? professorId,  String? professorName,  DateTime startTime,  DateTime endTime,  AppointmentStatus status,  String? procedureName,  String? notes,  String clinicId,  DateTime? arrivalTime,  DateTime? actualStartTime,  DateTime? actualEndTime)?  $default,) {final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that.id,_that.patientId,_that.patientName,_that.doctorId,_that.doctorName,_that.studentId,_that.studentName,_that.professorId,_that.professorName,_that.startTime,_that.endTime,_that.status,_that.procedureName,_that.notes,_that.clinicId,_that.arrivalTime,_that.actualStartTime,_that.actualEndTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Appointment implements Appointment {
  const _Appointment({required this.id, required this.patientId, required this.patientName, required this.doctorId, required this.doctorName, this.studentId, this.studentName, this.professorId, this.professorName, required this.startTime, required this.endTime, required this.status, this.procedureName, this.notes, required this.clinicId, this.arrivalTime, this.actualStartTime, this.actualEndTime});
  factory _Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);

@override final  String id;
@override final  String patientId;
@override final  String patientName;
@override final  String doctorId;
@override final  String doctorName;
@override final  String? studentId;
@override final  String? studentName;
@override final  String? professorId;
@override final  String? professorName;
@override final  DateTime startTime;
@override final  DateTime endTime;
@override final  AppointmentStatus status;
@override final  String? procedureName;
@override final  String? notes;
@override final  String clinicId;
@override final  DateTime? arrivalTime;
@override final  DateTime? actualStartTime;
@override final  DateTime? actualEndTime;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentCopyWith<_Appointment> get copyWith => __$AppointmentCopyWithImpl<_Appointment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Appointment&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.professorId, professorId) || other.professorId == professorId)&&(identical(other.professorName, professorName) || other.professorName == professorName)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.procedureName, procedureName) || other.procedureName == procedureName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.clinicId, clinicId) || other.clinicId == clinicId)&&(identical(other.arrivalTime, arrivalTime) || other.arrivalTime == arrivalTime)&&(identical(other.actualStartTime, actualStartTime) || other.actualStartTime == actualStartTime)&&(identical(other.actualEndTime, actualEndTime) || other.actualEndTime == actualEndTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,patientId,patientName,doctorId,doctorName,studentId,studentName,professorId,professorName,startTime,endTime,status,procedureName,notes,clinicId,arrivalTime,actualStartTime,actualEndTime);
}

@override
String toString() {
    return 'Appointment(id: $id, patientId: $patientId, patientName: $patientName, doctorId: $doctorId, doctorName: $doctorName, studentId: $studentId, studentName: $studentName, professorId: $professorId, professorName: $professorName, startTime: $startTime, endTime: $endTime, status: $status, procedureName: $procedureName, notes: $notes, clinicId: $clinicId, arrivalTime: $arrivalTime, actualStartTime: $actualStartTime, actualEndTime: $actualEndTime)';
}


}

/// @nodoc
abstract mixin class _$AppointmentCopyWith<$Res> implements $AppointmentCopyWith<$Res> {
  factory _$AppointmentCopyWith(_Appointment value, $Res Function(_Appointment) _then) = __$AppointmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String patientId, String patientName, String doctorId, String doctorName, String? studentId, String? studentName, String? professorId, String? professorName, DateTime startTime, DateTime endTime, AppointmentStatus status, String? procedureName, String? notes, String clinicId, DateTime? arrivalTime, DateTime? actualStartTime, DateTime? actualEndTime
});




}
/// @nodoc
class __$AppointmentCopyWithImpl<$Res>
    implements _$AppointmentCopyWith<$Res> {
  __$AppointmentCopyWithImpl(this._self, this._then);

  final _Appointment _self;
  final $Res Function(_Appointment) _then;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? patientId = null,Object? patientName = null,Object? doctorId = null,Object? doctorName = null,Object? studentId = freezed,Object? studentName = freezed,Object? professorId = freezed,Object? professorName = freezed,Object? startTime = null,Object? endTime = null,Object? status = null,Object? procedureName = freezed,Object? notes = freezed,Object? clinicId = null,Object? arrivalTime = freezed,Object? actualStartTime = freezed,Object? actualEndTime = freezed,}) {
  return _then(_Appointment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,professorId: freezed == professorId ? _self.professorId : professorId // ignore: cast_nullable_to_non_nullable
as String?,professorName: freezed == professorName ? _self.professorName : professorName // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppointmentStatus,procedureName: freezed == procedureName ? _self.procedureName : procedureName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,clinicId: null == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as String,arrivalTime: freezed == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,actualStartTime: freezed == actualStartTime ? _self.actualStartTime : actualStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,actualEndTime: freezed == actualEndTime ? _self.actualEndTime : actualEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
