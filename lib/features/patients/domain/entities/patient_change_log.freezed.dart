// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_change_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PatientChangeLog _$PatientChangeLogFromJson(Map<String, dynamic> json) {
  return _PatientChangeLog.fromJson(json);
}

/// @nodoc
mixin _$PatientChangeLog {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get changesJson => throw _privateConstructorUsedError;

  /// Serializes this PatientChangeLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PatientChangeLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientChangeLogCopyWith<PatientChangeLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientChangeLogCopyWith<$Res> {
  factory $PatientChangeLogCopyWith(
          PatientChangeLog value, $Res Function(PatientChangeLog) then) =
      _$PatientChangeLogCopyWithImpl<$Res, PatientChangeLog>;
  @useResult
  $Res call(
      {String id,
      String patientId,
      String userId,
      String userName,
      DateTime timestamp,
      String changesJson});
}

/// @nodoc
class _$PatientChangeLogCopyWithImpl<$Res, $Val extends PatientChangeLog>
    implements $PatientChangeLogCopyWith<$Res> {
  _$PatientChangeLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PatientChangeLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? userId = null,
    Object? userName = null,
    Object? timestamp = null,
    Object? changesJson = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      changesJson: null == changesJson
          ? _value.changesJson
          : changesJson // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatientChangeLogImplCopyWith<$Res>
    implements $PatientChangeLogCopyWith<$Res> {
  factory _$$PatientChangeLogImplCopyWith(_$PatientChangeLogImpl value,
          $Res Function(_$PatientChangeLogImpl) then) =
      __$$PatientChangeLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String patientId,
      String userId,
      String userName,
      DateTime timestamp,
      String changesJson});
}

/// @nodoc
class __$$PatientChangeLogImplCopyWithImpl<$Res>
    extends _$PatientChangeLogCopyWithImpl<$Res, _$PatientChangeLogImpl>
    implements _$$PatientChangeLogImplCopyWith<$Res> {
  __$$PatientChangeLogImplCopyWithImpl(_$PatientChangeLogImpl _value,
      $Res Function(_$PatientChangeLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of PatientChangeLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? userId = null,
    Object? userName = null,
    Object? timestamp = null,
    Object? changesJson = null,
  }) {
    return _then(_$PatientChangeLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      changesJson: null == changesJson
          ? _value.changesJson
          : changesJson // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientChangeLogImpl implements _PatientChangeLog {
  const _$PatientChangeLogImpl(
      {required this.id,
      required this.patientId,
      required this.userId,
      required this.userName,
      required this.timestamp,
      required this.changesJson});

  factory _$PatientChangeLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientChangeLogImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final DateTime timestamp;
  @override
  final String changesJson;

  @override
  String toString() {
    return 'PatientChangeLog(id: $id, patientId: $patientId, userId: $userId, userName: $userName, timestamp: $timestamp, changesJson: $changesJson)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientChangeLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.changesJson, changesJson) ||
                other.changesJson == changesJson));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, patientId, userId, userName, timestamp, changesJson);

  /// Create a copy of PatientChangeLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientChangeLogImplCopyWith<_$PatientChangeLogImpl> get copyWith =>
      __$$PatientChangeLogImplCopyWithImpl<_$PatientChangeLogImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientChangeLogImplToJson(
      this,
    );
  }
}

abstract class _PatientChangeLog implements PatientChangeLog {
  const factory _PatientChangeLog(
      {required final String id,
      required final String patientId,
      required final String userId,
      required final String userName,
      required final DateTime timestamp,
      required final String changesJson}) = _$PatientChangeLogImpl;

  factory _PatientChangeLog.fromJson(Map<String, dynamic> json) =
      _$PatientChangeLogImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  DateTime get timestamp;
  @override
  String get changesJson;

  /// Create a copy of PatientChangeLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientChangeLogImplCopyWith<_$PatientChangeLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
