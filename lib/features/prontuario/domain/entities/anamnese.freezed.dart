// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anamnese.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Anamnese _$AnamneseFromJson(Map<String, dynamic> json) {
  return _Anamnese.fromJson(json);
}

/// @nodoc
mixin _$Anamnese {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  Map<String, dynamic> get responses =>
      throw _privateConstructorUsedError; // JSON flexível para as perguntas
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Anamnese to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Anamnese
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnamneseCopyWith<Anamnese> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnamneseCopyWith<$Res> {
  factory $AnamneseCopyWith(Anamnese value, $Res Function(Anamnese) then) =
      _$AnamneseCopyWithImpl<$Res, Anamnese>;
  @useResult
  $Res call(
      {String id,
      String patientId,
      Map<String, dynamic> responses,
      DateTime createdAt,
      String createdBy,
      DateTime? updatedAt});
}

/// @nodoc
class _$AnamneseCopyWithImpl<$Res, $Val extends Anamnese>
    implements $AnamneseCopyWith<$Res> {
  _$AnamneseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Anamnese
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? responses = null,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? updatedAt = freezed,
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
      responses: null == responses
          ? _value.responses
          : responses // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnamneseImplCopyWith<$Res>
    implements $AnamneseCopyWith<$Res> {
  factory _$$AnamneseImplCopyWith(
          _$AnamneseImpl value, $Res Function(_$AnamneseImpl) then) =
      __$$AnamneseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String patientId,
      Map<String, dynamic> responses,
      DateTime createdAt,
      String createdBy,
      DateTime? updatedAt});
}

/// @nodoc
class __$$AnamneseImplCopyWithImpl<$Res>
    extends _$AnamneseCopyWithImpl<$Res, _$AnamneseImpl>
    implements _$$AnamneseImplCopyWith<$Res> {
  __$$AnamneseImplCopyWithImpl(
      _$AnamneseImpl _value, $Res Function(_$AnamneseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Anamnese
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? responses = null,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AnamneseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      responses: null == responses
          ? _value._responses
          : responses // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnamneseImpl implements _Anamnese {
  const _$AnamneseImpl(
      {required this.id,
      required this.patientId,
      required final Map<String, dynamic> responses,
      required this.createdAt,
      required this.createdBy,
      this.updatedAt})
      : _responses = responses;

  factory _$AnamneseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnamneseImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  final Map<String, dynamic> _responses;
  @override
  Map<String, dynamic> get responses {
    if (_responses is EqualUnmodifiableMapView) return _responses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_responses);
  }

// JSON flexível para as perguntas
  @override
  final DateTime createdAt;
  @override
  final String createdBy;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Anamnese(id: $id, patientId: $patientId, responses: $responses, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnamneseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            const DeepCollectionEquality()
                .equals(other._responses, _responses) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      patientId,
      const DeepCollectionEquality().hash(_responses),
      createdAt,
      createdBy,
      updatedAt);

  /// Create a copy of Anamnese
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnamneseImplCopyWith<_$AnamneseImpl> get copyWith =>
      __$$AnamneseImplCopyWithImpl<_$AnamneseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnamneseImplToJson(
      this,
    );
  }
}

abstract class _Anamnese implements Anamnese {
  const factory _Anamnese(
      {required final String id,
      required final String patientId,
      required final Map<String, dynamic> responses,
      required final DateTime createdAt,
      required final String createdBy,
      final DateTime? updatedAt}) = _$AnamneseImpl;

  factory _Anamnese.fromJson(Map<String, dynamic> json) =
      _$AnamneseImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  Map<String, dynamic> get responses; // JSON flexível para as perguntas
  @override
  DateTime get createdAt;
  @override
  String get createdBy;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Anamnese
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnamneseImplCopyWith<_$AnamneseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
