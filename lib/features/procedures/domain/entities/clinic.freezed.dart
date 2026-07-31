// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Clinic _$ClinicFromJson(Map<String, dynamic> json) {
  return _Clinic.fromJson(json);
}

/// @nodoc
mixin _$Clinic {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  int get startHour => throw _privateConstructorUsedError;
  int get endHour => throw _privateConstructorUsedError;
  int get slotDurationMinutes => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this Clinic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Clinic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClinicCopyWith<Clinic> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClinicCopyWith<$Res> {
  factory $ClinicCopyWith(Clinic value, $Res Function(Clinic) then) =
      _$ClinicCopyWithImpl<$Res, Clinic>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? location,
      int capacity,
      bool isActive,
      int startHour,
      int endHour,
      int slotDurationMinutes,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$ClinicCopyWithImpl<$Res, $Val extends Clinic>
    implements $ClinicCopyWith<$Res> {
  _$ClinicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Clinic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? location = freezed,
    Object? capacity = null,
    Object? isActive = null,
    Object? startHour = null,
    Object? endHour = null,
    Object? slotDurationMinutes = null,
    Object? metadata = null,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      capacity: null == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      startHour: null == startHour
          ? _value.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as int,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as int,
      slotDurationMinutes: null == slotDurationMinutes
          ? _value.slotDurationMinutes
          : slotDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClinicImplCopyWith<$Res> implements $ClinicCopyWith<$Res> {
  factory _$$ClinicImplCopyWith(
          _$ClinicImpl value, $Res Function(_$ClinicImpl) then) =
      __$$ClinicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? location,
      int capacity,
      bool isActive,
      int startHour,
      int endHour,
      int slotDurationMinutes,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$ClinicImplCopyWithImpl<$Res>
    extends _$ClinicCopyWithImpl<$Res, _$ClinicImpl>
    implements _$$ClinicImplCopyWith<$Res> {
  __$$ClinicImplCopyWithImpl(
      _$ClinicImpl _value, $Res Function(_$ClinicImpl) _then)
      : super(_value, _then);

  /// Create a copy of Clinic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? location = freezed,
    Object? capacity = null,
    Object? isActive = null,
    Object? startHour = null,
    Object? endHour = null,
    Object? slotDurationMinutes = null,
    Object? metadata = null,
  }) {
    return _then(_$ClinicImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      capacity: null == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      startHour: null == startHour
          ? _value.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as int,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as int,
      slotDurationMinutes: null == slotDurationMinutes
          ? _value.slotDurationMinutes
          : slotDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClinicImpl implements _Clinic {
  const _$ClinicImpl(
      {required this.id,
      required this.name,
      this.description,
      this.location,
      this.capacity = 1,
      this.isActive = true,
      this.startHour = 8,
      this.endHour = 18,
      this.slotDurationMinutes = 60,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$ClinicImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClinicImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? location;
  @override
  @JsonKey()
  final int capacity;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final int startHour;
  @override
  @JsonKey()
  final int endHour;
  @override
  @JsonKey()
  final int slotDurationMinutes;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'Clinic(id: $id, name: $name, description: $description, location: $location, capacity: $capacity, isActive: $isActive, startHour: $startHour, endHour: $endHour, slotDurationMinutes: $slotDurationMinutes, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClinicImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.endHour, endHour) || other.endHour == endHour) &&
            (identical(other.slotDurationMinutes, slotDurationMinutes) ||
                other.slotDurationMinutes == slotDurationMinutes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      location,
      capacity,
      isActive,
      startHour,
      endHour,
      slotDurationMinutes,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of Clinic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClinicImplCopyWith<_$ClinicImpl> get copyWith =>
      __$$ClinicImplCopyWithImpl<_$ClinicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClinicImplToJson(
      this,
    );
  }
}

abstract class _Clinic implements Clinic {
  const factory _Clinic(
      {required final String id,
      required final String name,
      final String? description,
      final String? location,
      final int capacity,
      final bool isActive,
      final int startHour,
      final int endHour,
      final int slotDurationMinutes,
      final Map<String, dynamic> metadata}) = _$ClinicImpl;

  factory _Clinic.fromJson(Map<String, dynamic> json) = _$ClinicImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get location;
  @override
  int get capacity;
  @override
  bool get isActive;
  @override
  int get startHour;
  @override
  int get endHour;
  @override
  int get slotDurationMinutes;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of Clinic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClinicImplCopyWith<_$ClinicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
