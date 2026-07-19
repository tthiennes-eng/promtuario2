// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wait_list_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WaitListEntry _$WaitListEntryFromJson(Map<String, dynamic> json) {
  return _WaitListEntry.fromJson(json);
}

/// @nodoc
mixin _$WaitListEntry {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get patientName => throw _privateConstructorUsedError;
  String get clinicId => throw _privateConstructorUsedError;
  String get specialty => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;
  String? get observation => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WaitListEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WaitListEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WaitListEntryCopyWith<WaitListEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WaitListEntryCopyWith<$Res> {
  factory $WaitListEntryCopyWith(
          WaitListEntry value, $Res Function(WaitListEntry) then) =
      _$WaitListEntryCopyWithImpl<$Res, WaitListEntry>;
  @useResult
  $Res call(
      {String id,
      String patientId,
      String patientName,
      String clinicId,
      String specialty,
      String priority,
      String? observation,
      DateTime createdAt});
}

/// @nodoc
class _$WaitListEntryCopyWithImpl<$Res, $Val extends WaitListEntry>
    implements $WaitListEntryCopyWith<$Res> {
  _$WaitListEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WaitListEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? patientName = null,
    Object? clinicId = null,
    Object? specialty = null,
    Object? priority = null,
    Object? observation = freezed,
    Object? createdAt = null,
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
      patientName: null == patientName
          ? _value.patientName
          : patientName // ignore: cast_nullable_to_non_nullable
              as String,
      clinicId: null == clinicId
          ? _value.clinicId
          : clinicId // ignore: cast_nullable_to_non_nullable
              as String,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      observation: freezed == observation
          ? _value.observation
          : observation // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WaitListEntryImplCopyWith<$Res>
    implements $WaitListEntryCopyWith<$Res> {
  factory _$$WaitListEntryImplCopyWith(
          _$WaitListEntryImpl value, $Res Function(_$WaitListEntryImpl) then) =
      __$$WaitListEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String patientId,
      String patientName,
      String clinicId,
      String specialty,
      String priority,
      String? observation,
      DateTime createdAt});
}

/// @nodoc
class __$$WaitListEntryImplCopyWithImpl<$Res>
    extends _$WaitListEntryCopyWithImpl<$Res, _$WaitListEntryImpl>
    implements _$$WaitListEntryImplCopyWith<$Res> {
  __$$WaitListEntryImplCopyWithImpl(
      _$WaitListEntryImpl _value, $Res Function(_$WaitListEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of WaitListEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? patientName = null,
    Object? clinicId = null,
    Object? specialty = null,
    Object? priority = null,
    Object? observation = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$WaitListEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      patientName: null == patientName
          ? _value.patientName
          : patientName // ignore: cast_nullable_to_non_nullable
              as String,
      clinicId: null == clinicId
          ? _value.clinicId
          : clinicId // ignore: cast_nullable_to_non_nullable
              as String,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      observation: freezed == observation
          ? _value.observation
          : observation // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WaitListEntryImpl implements _WaitListEntry {
  const _$WaitListEntryImpl(
      {required this.id,
      required this.patientId,
      required this.patientName,
      required this.clinicId,
      required this.specialty,
      required this.priority,
      this.observation,
      required this.createdAt});

  factory _$WaitListEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WaitListEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String patientName;
  @override
  final String clinicId;
  @override
  final String specialty;
  @override
  final String priority;
  @override
  final String? observation;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'WaitListEntry(id: $id, patientId: $patientId, patientName: $patientName, clinicId: $clinicId, specialty: $specialty, priority: $priority, observation: $observation, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WaitListEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.clinicId, clinicId) ||
                other.clinicId == clinicId) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.observation, observation) ||
                other.observation == observation) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, patientId, patientName,
      clinicId, specialty, priority, observation, createdAt);

  /// Create a copy of WaitListEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WaitListEntryImplCopyWith<_$WaitListEntryImpl> get copyWith =>
      __$$WaitListEntryImplCopyWithImpl<_$WaitListEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WaitListEntryImplToJson(
      this,
    );
  }
}

abstract class _WaitListEntry implements WaitListEntry {
  const factory _WaitListEntry(
      {required final String id,
      required final String patientId,
      required final String patientName,
      required final String clinicId,
      required final String specialty,
      required final String priority,
      final String? observation,
      required final DateTime createdAt}) = _$WaitListEntryImpl;

  factory _WaitListEntry.fromJson(Map<String, dynamic> json) =
      _$WaitListEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get patientName;
  @override
  String get clinicId;
  @override
  String get specialty;
  @override
  String get priority;
  @override
  String? get observation;
  @override
  DateTime get createdAt;

  /// Create a copy of WaitListEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WaitListEntryImplCopyWith<_$WaitListEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
