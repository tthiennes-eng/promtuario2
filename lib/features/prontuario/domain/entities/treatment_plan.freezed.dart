// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'treatment_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TreatmentPlan _$TreatmentPlanFromJson(Map<String, dynamic> json) {
  return _TreatmentPlan.fromJson(json);
}

/// @nodoc
mixin _$TreatmentPlan {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<TreatmentItem> get items => throw _privateConstructorUsedError;
  String get createdByUserId => throw _privateConstructorUsedError;
  TreatmentPlanStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TreatmentPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TreatmentPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TreatmentPlanCopyWith<TreatmentPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TreatmentPlanCopyWith<$Res> {
  factory $TreatmentPlanCopyWith(
          TreatmentPlan value, $Res Function(TreatmentPlan) then) =
      _$TreatmentPlanCopyWithImpl<$Res, TreatmentPlan>;
  @useResult
  $Res call(
      {String id,
      String patientId,
      String description,
      List<TreatmentItem> items,
      String createdByUserId,
      TreatmentPlanStatus status,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$TreatmentPlanCopyWithImpl<$Res, $Val extends TreatmentPlan>
    implements $TreatmentPlanCopyWith<$Res> {
  _$TreatmentPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TreatmentPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? description = null,
    Object? items = null,
    Object? createdByUserId = null,
    Object? status = null,
    Object? createdAt = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TreatmentItem>,
      createdByUserId: null == createdByUserId
          ? _value.createdByUserId
          : createdByUserId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TreatmentPlanStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TreatmentPlanImplCopyWith<$Res>
    implements $TreatmentPlanCopyWith<$Res> {
  factory _$$TreatmentPlanImplCopyWith(
          _$TreatmentPlanImpl value, $Res Function(_$TreatmentPlanImpl) then) =
      __$$TreatmentPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String patientId,
      String description,
      List<TreatmentItem> items,
      String createdByUserId,
      TreatmentPlanStatus status,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$TreatmentPlanImplCopyWithImpl<$Res>
    extends _$TreatmentPlanCopyWithImpl<$Res, _$TreatmentPlanImpl>
    implements _$$TreatmentPlanImplCopyWith<$Res> {
  __$$TreatmentPlanImplCopyWithImpl(
      _$TreatmentPlanImpl _value, $Res Function(_$TreatmentPlanImpl) _then)
      : super(_value, _then);

  /// Create a copy of TreatmentPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? description = null,
    Object? items = null,
    Object? createdByUserId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TreatmentPlanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TreatmentItem>,
      createdByUserId: null == createdByUserId
          ? _value.createdByUserId
          : createdByUserId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TreatmentPlanStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TreatmentPlanImpl implements _TreatmentPlan {
  const _$TreatmentPlanImpl(
      {required this.id,
      required this.patientId,
      required this.description,
      required final List<TreatmentItem> items,
      required this.createdByUserId,
      required this.status,
      required this.createdAt,
      this.updatedAt})
      : _items = items;

  factory _$TreatmentPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$TreatmentPlanImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String description;
  final List<TreatmentItem> _items;
  @override
  List<TreatmentItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String createdByUserId;
  @override
  final TreatmentPlanStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TreatmentPlan(id: $id, patientId: $patientId, description: $description, items: $items, createdByUserId: $createdByUserId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TreatmentPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.createdByUserId, createdByUserId) ||
                other.createdByUserId == createdByUserId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      patientId,
      description,
      const DeepCollectionEquality().hash(_items),
      createdByUserId,
      status,
      createdAt,
      updatedAt);

  /// Create a copy of TreatmentPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TreatmentPlanImplCopyWith<_$TreatmentPlanImpl> get copyWith =>
      __$$TreatmentPlanImplCopyWithImpl<_$TreatmentPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TreatmentPlanImplToJson(
      this,
    );
  }
}

abstract class _TreatmentPlan implements TreatmentPlan {
  const factory _TreatmentPlan(
      {required final String id,
      required final String patientId,
      required final String description,
      required final List<TreatmentItem> items,
      required final String createdByUserId,
      required final TreatmentPlanStatus status,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$TreatmentPlanImpl;

  factory _TreatmentPlan.fromJson(Map<String, dynamic> json) =
      _$TreatmentPlanImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get description;
  @override
  List<TreatmentItem> get items;
  @override
  String get createdByUserId;
  @override
  TreatmentPlanStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of TreatmentPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TreatmentPlanImplCopyWith<_$TreatmentPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TreatmentItem _$TreatmentItemFromJson(Map<String, dynamic> json) {
  return _TreatmentItem.fromJson(json);
}

/// @nodoc
mixin _$TreatmentItem {
  String get id => throw _privateConstructorUsedError;
  String get procedureId => throw _privateConstructorUsedError;
  String get procedureName => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  int? get toothNumber => throw _privateConstructorUsedError;
  TreatmentItemStatus get status => throw _privateConstructorUsedError;

  /// Serializes this TreatmentItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TreatmentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TreatmentItemCopyWith<TreatmentItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TreatmentItemCopyWith<$Res> {
  factory $TreatmentItemCopyWith(
          TreatmentItem value, $Res Function(TreatmentItem) then) =
      _$TreatmentItemCopyWithImpl<$Res, TreatmentItem>;
  @useResult
  $Res call(
      {String id,
      String procedureId,
      String procedureName,
      double value,
      int? toothNumber,
      TreatmentItemStatus status});
}

/// @nodoc
class _$TreatmentItemCopyWithImpl<$Res, $Val extends TreatmentItem>
    implements $TreatmentItemCopyWith<$Res> {
  _$TreatmentItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TreatmentItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? procedureId = null,
    Object? procedureName = null,
    Object? value = null,
    Object? toothNumber = freezed,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      procedureId: null == procedureId
          ? _value.procedureId
          : procedureId // ignore: cast_nullable_to_non_nullable
              as String,
      procedureName: null == procedureName
          ? _value.procedureName
          : procedureName // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      toothNumber: freezed == toothNumber
          ? _value.toothNumber
          : toothNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TreatmentItemStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TreatmentItemImplCopyWith<$Res>
    implements $TreatmentItemCopyWith<$Res> {
  factory _$$TreatmentItemImplCopyWith(
          _$TreatmentItemImpl value, $Res Function(_$TreatmentItemImpl) then) =
      __$$TreatmentItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String procedureId,
      String procedureName,
      double value,
      int? toothNumber,
      TreatmentItemStatus status});
}

/// @nodoc
class __$$TreatmentItemImplCopyWithImpl<$Res>
    extends _$TreatmentItemCopyWithImpl<$Res, _$TreatmentItemImpl>
    implements _$$TreatmentItemImplCopyWith<$Res> {
  __$$TreatmentItemImplCopyWithImpl(
      _$TreatmentItemImpl _value, $Res Function(_$TreatmentItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of TreatmentItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? procedureId = null,
    Object? procedureName = null,
    Object? value = null,
    Object? toothNumber = freezed,
    Object? status = null,
  }) {
    return _then(_$TreatmentItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      procedureId: null == procedureId
          ? _value.procedureId
          : procedureId // ignore: cast_nullable_to_non_nullable
              as String,
      procedureName: null == procedureName
          ? _value.procedureName
          : procedureName // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      toothNumber: freezed == toothNumber
          ? _value.toothNumber
          : toothNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TreatmentItemStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TreatmentItemImpl implements _TreatmentItem {
  const _$TreatmentItemImpl(
      {required this.id,
      required this.procedureId,
      required this.procedureName,
      required this.value,
      this.toothNumber,
      required this.status});

  factory _$TreatmentItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TreatmentItemImplFromJson(json);

  @override
  final String id;
  @override
  final String procedureId;
  @override
  final String procedureName;
  @override
  final double value;
  @override
  final int? toothNumber;
  @override
  final TreatmentItemStatus status;

  @override
  String toString() {
    return 'TreatmentItem(id: $id, procedureId: $procedureId, procedureName: $procedureName, value: $value, toothNumber: $toothNumber, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TreatmentItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.procedureId, procedureId) ||
                other.procedureId == procedureId) &&
            (identical(other.procedureName, procedureName) ||
                other.procedureName == procedureName) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.toothNumber, toothNumber) ||
                other.toothNumber == toothNumber) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, procedureId, procedureName, value, toothNumber, status);

  /// Create a copy of TreatmentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TreatmentItemImplCopyWith<_$TreatmentItemImpl> get copyWith =>
      __$$TreatmentItemImplCopyWithImpl<_$TreatmentItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TreatmentItemImplToJson(
      this,
    );
  }
}

abstract class _TreatmentItem implements TreatmentItem {
  const factory _TreatmentItem(
      {required final String id,
      required final String procedureId,
      required final String procedureName,
      required final double value,
      final int? toothNumber,
      required final TreatmentItemStatus status}) = _$TreatmentItemImpl;

  factory _TreatmentItem.fromJson(Map<String, dynamic> json) =
      _$TreatmentItemImpl.fromJson;

  @override
  String get id;
  @override
  String get procedureId;
  @override
  String get procedureName;
  @override
  double get value;
  @override
  int? get toothNumber;
  @override
  TreatmentItemStatus get status;

  /// Create a copy of TreatmentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TreatmentItemImplCopyWith<_$TreatmentItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
