// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evolution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Evolution _$EvolutionFromJson(Map<String, dynamic> json) {
  return _Evolution.fromJson(json);
}

/// @nodoc
mixin _$Evolution {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get studentName => throw _privateConstructorUsedError;
  String get professorId => throw _privateConstructorUsedError;
  String get professorName => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  bool get isSignedByProfessor => throw _privateConstructorUsedError;
  DateTime? get signedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get clinicName => throw _privateConstructorUsedError;

  /// Serializes this Evolution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Evolution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EvolutionCopyWith<Evolution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EvolutionCopyWith<$Res> {
  factory $EvolutionCopyWith(Evolution value, $Res Function(Evolution) then) =
      _$EvolutionCopyWithImpl<$Res, Evolution>;
  @useResult
  $Res call(
      {String id,
      String patientId,
      String studentId,
      String studentName,
      String professorId,
      String professorName,
      String description,
      bool isSignedByProfessor,
      DateTime? signedAt,
      DateTime createdAt,
      String? clinicName});
}

/// @nodoc
class _$EvolutionCopyWithImpl<$Res, $Val extends Evolution>
    implements $EvolutionCopyWith<$Res> {
  _$EvolutionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Evolution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? studentId = null,
    Object? studentName = null,
    Object? professorId = null,
    Object? professorName = null,
    Object? description = null,
    Object? isSignedByProfessor = null,
    Object? signedAt = freezed,
    Object? createdAt = null,
    Object? clinicName = freezed,
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
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      studentName: null == studentName
          ? _value.studentName
          : studentName // ignore: cast_nullable_to_non_nullable
              as String,
      professorId: null == professorId
          ? _value.professorId
          : professorId // ignore: cast_nullable_to_non_nullable
              as String,
      professorName: null == professorName
          ? _value.professorName
          : professorName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isSignedByProfessor: null == isSignedByProfessor
          ? _value.isSignedByProfessor
          : isSignedByProfessor // ignore: cast_nullable_to_non_nullable
              as bool,
      signedAt: freezed == signedAt
          ? _value.signedAt
          : signedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      clinicName: freezed == clinicName
          ? _value.clinicName
          : clinicName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EvolutionImplCopyWith<$Res>
    implements $EvolutionCopyWith<$Res> {
  factory _$$EvolutionImplCopyWith(
          _$EvolutionImpl value, $Res Function(_$EvolutionImpl) then) =
      __$$EvolutionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String patientId,
      String studentId,
      String studentName,
      String professorId,
      String professorName,
      String description,
      bool isSignedByProfessor,
      DateTime? signedAt,
      DateTime createdAt,
      String? clinicName});
}

/// @nodoc
class __$$EvolutionImplCopyWithImpl<$Res>
    extends _$EvolutionCopyWithImpl<$Res, _$EvolutionImpl>
    implements _$$EvolutionImplCopyWith<$Res> {
  __$$EvolutionImplCopyWithImpl(
      _$EvolutionImpl _value, $Res Function(_$EvolutionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Evolution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? studentId = null,
    Object? studentName = null,
    Object? professorId = null,
    Object? professorName = null,
    Object? description = null,
    Object? isSignedByProfessor = null,
    Object? signedAt = freezed,
    Object? createdAt = null,
    Object? clinicName = freezed,
  }) {
    return _then(_$EvolutionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      studentName: null == studentName
          ? _value.studentName
          : studentName // ignore: cast_nullable_to_non_nullable
              as String,
      professorId: null == professorId
          ? _value.professorId
          : professorId // ignore: cast_nullable_to_non_nullable
              as String,
      professorName: null == professorName
          ? _value.professorName
          : professorName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isSignedByProfessor: null == isSignedByProfessor
          ? _value.isSignedByProfessor
          : isSignedByProfessor // ignore: cast_nullable_to_non_nullable
              as bool,
      signedAt: freezed == signedAt
          ? _value.signedAt
          : signedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      clinicName: freezed == clinicName
          ? _value.clinicName
          : clinicName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EvolutionImpl implements _Evolution {
  const _$EvolutionImpl(
      {required this.id,
      required this.patientId,
      required this.studentId,
      required this.studentName,
      required this.professorId,
      required this.professorName,
      required this.description,
      required this.isSignedByProfessor,
      this.signedAt,
      required this.createdAt,
      this.clinicName});

  factory _$EvolutionImpl.fromJson(Map<String, dynamic> json) =>
      _$$EvolutionImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String studentId;
  @override
  final String studentName;
  @override
  final String professorId;
  @override
  final String professorName;
  @override
  final String description;
  @override
  final bool isSignedByProfessor;
  @override
  final DateTime? signedAt;
  @override
  final DateTime createdAt;
  @override
  final String? clinicName;

  @override
  String toString() {
    return 'Evolution(id: $id, patientId: $patientId, studentId: $studentId, studentName: $studentName, professorId: $professorId, professorName: $professorName, description: $description, isSignedByProfessor: $isSignedByProfessor, signedAt: $signedAt, createdAt: $createdAt, clinicName: $clinicName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EvolutionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.professorId, professorId) ||
                other.professorId == professorId) &&
            (identical(other.professorName, professorName) ||
                other.professorName == professorName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isSignedByProfessor, isSignedByProfessor) ||
                other.isSignedByProfessor == isSignedByProfessor) &&
            (identical(other.signedAt, signedAt) ||
                other.signedAt == signedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.clinicName, clinicName) ||
                other.clinicName == clinicName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      patientId,
      studentId,
      studentName,
      professorId,
      professorName,
      description,
      isSignedByProfessor,
      signedAt,
      createdAt,
      clinicName);

  /// Create a copy of Evolution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EvolutionImplCopyWith<_$EvolutionImpl> get copyWith =>
      __$$EvolutionImplCopyWithImpl<_$EvolutionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EvolutionImplToJson(
      this,
    );
  }
}

abstract class _Evolution implements Evolution {
  const factory _Evolution(
      {required final String id,
      required final String patientId,
      required final String studentId,
      required final String studentName,
      required final String professorId,
      required final String professorName,
      required final String description,
      required final bool isSignedByProfessor,
      final DateTime? signedAt,
      required final DateTime createdAt,
      final String? clinicName}) = _$EvolutionImpl;

  factory _Evolution.fromJson(Map<String, dynamic> json) =
      _$EvolutionImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get studentId;
  @override
  String get studentName;
  @override
  String get professorId;
  @override
  String get professorName;
  @override
  String get description;
  @override
  bool get isSignedByProfessor;
  @override
  DateTime? get signedAt;
  @override
  DateTime get createdAt;
  @override
  String? get clinicName;

  /// Create a copy of Evolution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EvolutionImplCopyWith<_$EvolutionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
