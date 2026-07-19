// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'procedure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Procedure _$ProcedureFromJson(Map<String, dynamic> json) {
  return _Procedure.fromJson(json);
}

/// @nodoc
mixin _$Procedure {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  double get baseValue => throw _privateConstructorUsedError;
  String get specialty =>
      throw _privateConstructorUsedError; // Corresponding to the Specialty enum on backend
  int get estimatedTimeMinutes => throw _privateConstructorUsedError;

  /// Serializes this Procedure to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Procedure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProcedureCopyWith<Procedure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProcedureCopyWith<$Res> {
  factory $ProcedureCopyWith(Procedure value, $Res Function(Procedure) then) =
      _$ProcedureCopyWithImpl<$Res, Procedure>;
  @useResult
  $Res call(
      {String id,
      String name,
      String code,
      double baseValue,
      String specialty,
      int estimatedTimeMinutes});
}

/// @nodoc
class _$ProcedureCopyWithImpl<$Res, $Val extends Procedure>
    implements $ProcedureCopyWith<$Res> {
  _$ProcedureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Procedure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? baseValue = null,
    Object? specialty = null,
    Object? estimatedTimeMinutes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      baseValue: null == baseValue
          ? _value.baseValue
          : baseValue // ignore: cast_nullable_to_non_nullable
              as double,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedTimeMinutes: null == estimatedTimeMinutes
          ? _value.estimatedTimeMinutes
          : estimatedTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProcedureImplCopyWith<$Res>
    implements $ProcedureCopyWith<$Res> {
  factory _$$ProcedureImplCopyWith(
          _$ProcedureImpl value, $Res Function(_$ProcedureImpl) then) =
      __$$ProcedureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String code,
      double baseValue,
      String specialty,
      int estimatedTimeMinutes});
}

/// @nodoc
class __$$ProcedureImplCopyWithImpl<$Res>
    extends _$ProcedureCopyWithImpl<$Res, _$ProcedureImpl>
    implements _$$ProcedureImplCopyWith<$Res> {
  __$$ProcedureImplCopyWithImpl(
      _$ProcedureImpl _value, $Res Function(_$ProcedureImpl) _then)
      : super(_value, _then);

  /// Create a copy of Procedure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? baseValue = null,
    Object? specialty = null,
    Object? estimatedTimeMinutes = null,
  }) {
    return _then(_$ProcedureImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      baseValue: null == baseValue
          ? _value.baseValue
          : baseValue // ignore: cast_nullable_to_non_nullable
              as double,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedTimeMinutes: null == estimatedTimeMinutes
          ? _value.estimatedTimeMinutes
          : estimatedTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProcedureImpl implements _Procedure {
  const _$ProcedureImpl(
      {required this.id,
      required this.name,
      required this.code,
      required this.baseValue,
      required this.specialty,
      required this.estimatedTimeMinutes});

  factory _$ProcedureImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProcedureImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String code;
  @override
  final double baseValue;
  @override
  final String specialty;
// Corresponding to the Specialty enum on backend
  @override
  final int estimatedTimeMinutes;

  @override
  String toString() {
    return 'Procedure(id: $id, name: $name, code: $code, baseValue: $baseValue, specialty: $specialty, estimatedTimeMinutes: $estimatedTimeMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcedureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.baseValue, baseValue) ||
                other.baseValue == baseValue) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.estimatedTimeMinutes, estimatedTimeMinutes) ||
                other.estimatedTimeMinutes == estimatedTimeMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, code, baseValue, specialty, estimatedTimeMinutes);

  /// Create a copy of Procedure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcedureImplCopyWith<_$ProcedureImpl> get copyWith =>
      __$$ProcedureImplCopyWithImpl<_$ProcedureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProcedureImplToJson(
      this,
    );
  }
}

abstract class _Procedure implements Procedure {
  const factory _Procedure(
      {required final String id,
      required final String name,
      required final String code,
      required final double baseValue,
      required final String specialty,
      required final int estimatedTimeMinutes}) = _$ProcedureImpl;

  factory _Procedure.fromJson(Map<String, dynamic> json) =
      _$ProcedureImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get code;
  @override
  double get baseValue;
  @override
  String get specialty; // Corresponding to the Specialty enum on backend
  @override
  int get estimatedTimeMinutes;

  /// Create a copy of Procedure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcedureImplCopyWith<_$ProcedureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
