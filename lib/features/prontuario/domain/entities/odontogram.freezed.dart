// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'odontogram.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ToothCondition _$ToothConditionFromJson(Map<String, dynamic> json) {
  return _ToothCondition.fromJson(json);
}

/// @nodoc
mixin _$ToothCondition {
  int get toothNumber => throw _privateConstructorUsedError;
  List<ToothSurface> get surfaces => throw _privateConstructorUsedError;
  ConditionType get condition => throw _privateConstructorUsedError;
  String? get observation => throw _privateConstructorUsedError;
  DateTime? get lastUpdate => throw _privateConstructorUsedError;

  /// Serializes this ToothCondition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ToothCondition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ToothConditionCopyWith<ToothCondition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToothConditionCopyWith<$Res> {
  factory $ToothConditionCopyWith(
          ToothCondition value, $Res Function(ToothCondition) then) =
      _$ToothConditionCopyWithImpl<$Res, ToothCondition>;
  @useResult
  $Res call(
      {int toothNumber,
      List<ToothSurface> surfaces,
      ConditionType condition,
      String? observation,
      DateTime? lastUpdate});
}

/// @nodoc
class _$ToothConditionCopyWithImpl<$Res, $Val extends ToothCondition>
    implements $ToothConditionCopyWith<$Res> {
  _$ToothConditionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ToothCondition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toothNumber = null,
    Object? surfaces = null,
    Object? condition = null,
    Object? observation = freezed,
    Object? lastUpdate = freezed,
  }) {
    return _then(_value.copyWith(
      toothNumber: null == toothNumber
          ? _value.toothNumber
          : toothNumber // ignore: cast_nullable_to_non_nullable
              as int,
      surfaces: null == surfaces
          ? _value.surfaces
          : surfaces // ignore: cast_nullable_to_non_nullable
              as List<ToothSurface>,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as ConditionType,
      observation: freezed == observation
          ? _value.observation
          : observation // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ToothConditionImplCopyWith<$Res>
    implements $ToothConditionCopyWith<$Res> {
  factory _$$ToothConditionImplCopyWith(_$ToothConditionImpl value,
          $Res Function(_$ToothConditionImpl) then) =
      __$$ToothConditionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int toothNumber,
      List<ToothSurface> surfaces,
      ConditionType condition,
      String? observation,
      DateTime? lastUpdate});
}

/// @nodoc
class __$$ToothConditionImplCopyWithImpl<$Res>
    extends _$ToothConditionCopyWithImpl<$Res, _$ToothConditionImpl>
    implements _$$ToothConditionImplCopyWith<$Res> {
  __$$ToothConditionImplCopyWithImpl(
      _$ToothConditionImpl _value, $Res Function(_$ToothConditionImpl) _then)
      : super(_value, _then);

  /// Create a copy of ToothCondition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toothNumber = null,
    Object? surfaces = null,
    Object? condition = null,
    Object? observation = freezed,
    Object? lastUpdate = freezed,
  }) {
    return _then(_$ToothConditionImpl(
      toothNumber: null == toothNumber
          ? _value.toothNumber
          : toothNumber // ignore: cast_nullable_to_non_nullable
              as int,
      surfaces: null == surfaces
          ? _value._surfaces
          : surfaces // ignore: cast_nullable_to_non_nullable
              as List<ToothSurface>,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as ConditionType,
      observation: freezed == observation
          ? _value.observation
          : observation // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ToothConditionImpl implements _ToothCondition {
  const _$ToothConditionImpl(
      {required this.toothNumber,
      required final List<ToothSurface> surfaces,
      required this.condition,
      this.observation,
      this.lastUpdate})
      : _surfaces = surfaces;

  factory _$ToothConditionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToothConditionImplFromJson(json);

  @override
  final int toothNumber;
  final List<ToothSurface> _surfaces;
  @override
  List<ToothSurface> get surfaces {
    if (_surfaces is EqualUnmodifiableListView) return _surfaces;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_surfaces);
  }

  @override
  final ConditionType condition;
  @override
  final String? observation;
  @override
  final DateTime? lastUpdate;

  @override
  String toString() {
    return 'ToothCondition(toothNumber: $toothNumber, surfaces: $surfaces, condition: $condition, observation: $observation, lastUpdate: $lastUpdate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToothConditionImpl &&
            (identical(other.toothNumber, toothNumber) ||
                other.toothNumber == toothNumber) &&
            const DeepCollectionEquality().equals(other._surfaces, _surfaces) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.observation, observation) ||
                other.observation == observation) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      toothNumber,
      const DeepCollectionEquality().hash(_surfaces),
      condition,
      observation,
      lastUpdate);

  /// Create a copy of ToothCondition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToothConditionImplCopyWith<_$ToothConditionImpl> get copyWith =>
      __$$ToothConditionImplCopyWithImpl<_$ToothConditionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ToothConditionImplToJson(
      this,
    );
  }
}

abstract class _ToothCondition implements ToothCondition {
  const factory _ToothCondition(
      {required final int toothNumber,
      required final List<ToothSurface> surfaces,
      required final ConditionType condition,
      final String? observation,
      final DateTime? lastUpdate}) = _$ToothConditionImpl;

  factory _ToothCondition.fromJson(Map<String, dynamic> json) =
      _$ToothConditionImpl.fromJson;

  @override
  int get toothNumber;
  @override
  List<ToothSurface> get surfaces;
  @override
  ConditionType get condition;
  @override
  String? get observation;
  @override
  DateTime? get lastUpdate;

  /// Create a copy of ToothCondition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToothConditionImplCopyWith<_$ToothConditionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Odontogram _$OdontogramFromJson(Map<String, dynamic> json) {
  return _Odontogram.fromJson(json);
}

/// @nodoc
mixin _$Odontogram {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  List<ToothCondition> get teeth => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get updatedBy => throw _privateConstructorUsedError;

  /// Serializes this Odontogram to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Odontogram
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OdontogramCopyWith<Odontogram> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OdontogramCopyWith<$Res> {
  factory $OdontogramCopyWith(
          Odontogram value, $Res Function(Odontogram) then) =
      _$OdontogramCopyWithImpl<$Res, Odontogram>;
  @useResult
  $Res call(
      {String id,
      String patientId,
      List<ToothCondition> teeth,
      DateTime updatedAt,
      String updatedBy});
}

/// @nodoc
class _$OdontogramCopyWithImpl<$Res, $Val extends Odontogram>
    implements $OdontogramCopyWith<$Res> {
  _$OdontogramCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Odontogram
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? teeth = null,
    Object? updatedAt = null,
    Object? updatedBy = null,
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
      teeth: null == teeth
          ? _value.teeth
          : teeth // ignore: cast_nullable_to_non_nullable
              as List<ToothCondition>,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedBy: null == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OdontogramImplCopyWith<$Res>
    implements $OdontogramCopyWith<$Res> {
  factory _$$OdontogramImplCopyWith(
          _$OdontogramImpl value, $Res Function(_$OdontogramImpl) then) =
      __$$OdontogramImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String patientId,
      List<ToothCondition> teeth,
      DateTime updatedAt,
      String updatedBy});
}

/// @nodoc
class __$$OdontogramImplCopyWithImpl<$Res>
    extends _$OdontogramCopyWithImpl<$Res, _$OdontogramImpl>
    implements _$$OdontogramImplCopyWith<$Res> {
  __$$OdontogramImplCopyWithImpl(
      _$OdontogramImpl _value, $Res Function(_$OdontogramImpl) _then)
      : super(_value, _then);

  /// Create a copy of Odontogram
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? teeth = null,
    Object? updatedAt = null,
    Object? updatedBy = null,
  }) {
    return _then(_$OdontogramImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      teeth: null == teeth
          ? _value._teeth
          : teeth // ignore: cast_nullable_to_non_nullable
              as List<ToothCondition>,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedBy: null == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OdontogramImpl implements _Odontogram {
  const _$OdontogramImpl(
      {required this.id,
      required this.patientId,
      required final List<ToothCondition> teeth,
      required this.updatedAt,
      required this.updatedBy})
      : _teeth = teeth;

  factory _$OdontogramImpl.fromJson(Map<String, dynamic> json) =>
      _$$OdontogramImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  final List<ToothCondition> _teeth;
  @override
  List<ToothCondition> get teeth {
    if (_teeth is EqualUnmodifiableListView) return _teeth;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teeth);
  }

  @override
  final DateTime updatedAt;
  @override
  final String updatedBy;

  @override
  String toString() {
    return 'Odontogram(id: $id, patientId: $patientId, teeth: $teeth, updatedAt: $updatedAt, updatedBy: $updatedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OdontogramImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            const DeepCollectionEquality().equals(other._teeth, _teeth) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, patientId,
      const DeepCollectionEquality().hash(_teeth), updatedAt, updatedBy);

  /// Create a copy of Odontogram
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OdontogramImplCopyWith<_$OdontogramImpl> get copyWith =>
      __$$OdontogramImplCopyWithImpl<_$OdontogramImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OdontogramImplToJson(
      this,
    );
  }
}

abstract class _Odontogram implements Odontogram {
  const factory _Odontogram(
      {required final String id,
      required final String patientId,
      required final List<ToothCondition> teeth,
      required final DateTime updatedAt,
      required final String updatedBy}) = _$OdontogramImpl;

  factory _Odontogram.fromJson(Map<String, dynamic> json) =
      _$OdontogramImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  List<ToothCondition> get teeth;
  @override
  DateTime get updatedAt;
  @override
  String get updatedBy;

  /// Create a copy of Odontogram
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OdontogramImplCopyWith<_$OdontogramImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
