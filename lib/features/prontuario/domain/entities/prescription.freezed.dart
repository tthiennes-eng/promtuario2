// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prescription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Prescription _$PrescriptionFromJson(Map<String, dynamic> json) {
  return _Prescription.fromJson(json);
}

/// @nodoc
mixin _$Prescription {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get doctorId => throw _privateConstructorUsedError;
  String get doctorName => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  List<PrescriptionItem> get items => throw _privateConstructorUsedError;
  String? get observations => throw _privateConstructorUsedError;
  String get clinicId => throw _privateConstructorUsedError;

  /// Serializes this Prescription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Prescription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrescriptionCopyWith<Prescription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrescriptionCopyWith<$Res> {
  factory $PrescriptionCopyWith(
          Prescription value, $Res Function(Prescription) then) =
      _$PrescriptionCopyWithImpl<$Res, Prescription>;
  @useResult
  $Res call(
      {String id,
      String patientId,
      String doctorId,
      String doctorName,
      DateTime date,
      List<PrescriptionItem> items,
      String? observations,
      String clinicId});
}

/// @nodoc
class _$PrescriptionCopyWithImpl<$Res, $Val extends Prescription>
    implements $PrescriptionCopyWith<$Res> {
  _$PrescriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Prescription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? doctorName = null,
    Object? date = null,
    Object? items = null,
    Object? observations = freezed,
    Object? clinicId = null,
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
      doctorId: null == doctorId
          ? _value.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as String,
      doctorName: null == doctorName
          ? _value.doctorName
          : doctorName // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PrescriptionItem>,
      observations: freezed == observations
          ? _value.observations
          : observations // ignore: cast_nullable_to_non_nullable
              as String?,
      clinicId: null == clinicId
          ? _value.clinicId
          : clinicId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrescriptionImplCopyWith<$Res>
    implements $PrescriptionCopyWith<$Res> {
  factory _$$PrescriptionImplCopyWith(
          _$PrescriptionImpl value, $Res Function(_$PrescriptionImpl) then) =
      __$$PrescriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String patientId,
      String doctorId,
      String doctorName,
      DateTime date,
      List<PrescriptionItem> items,
      String? observations,
      String clinicId});
}

/// @nodoc
class __$$PrescriptionImplCopyWithImpl<$Res>
    extends _$PrescriptionCopyWithImpl<$Res, _$PrescriptionImpl>
    implements _$$PrescriptionImplCopyWith<$Res> {
  __$$PrescriptionImplCopyWithImpl(
      _$PrescriptionImpl _value, $Res Function(_$PrescriptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Prescription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? doctorName = null,
    Object? date = null,
    Object? items = null,
    Object? observations = freezed,
    Object? clinicId = null,
  }) {
    return _then(_$PrescriptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      doctorId: null == doctorId
          ? _value.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as String,
      doctorName: null == doctorName
          ? _value.doctorName
          : doctorName // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PrescriptionItem>,
      observations: freezed == observations
          ? _value.observations
          : observations // ignore: cast_nullable_to_non_nullable
              as String?,
      clinicId: null == clinicId
          ? _value.clinicId
          : clinicId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrescriptionImpl implements _Prescription {
  const _$PrescriptionImpl(
      {required this.id,
      required this.patientId,
      required this.doctorId,
      required this.doctorName,
      required this.date,
      required final List<PrescriptionItem> items,
      this.observations,
      required this.clinicId})
      : _items = items;

  factory _$PrescriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrescriptionImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String doctorId;
  @override
  final String doctorName;
  @override
  final DateTime date;
  final List<PrescriptionItem> _items;
  @override
  List<PrescriptionItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? observations;
  @override
  final String clinicId;

  @override
  String toString() {
    return 'Prescription(id: $id, patientId: $patientId, doctorId: $doctorId, doctorName: $doctorName, date: $date, items: $items, observations: $observations, clinicId: $clinicId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrescriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.observations, observations) ||
                other.observations == observations) &&
            (identical(other.clinicId, clinicId) ||
                other.clinicId == clinicId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      patientId,
      doctorId,
      doctorName,
      date,
      const DeepCollectionEquality().hash(_items),
      observations,
      clinicId);

  /// Create a copy of Prescription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrescriptionImplCopyWith<_$PrescriptionImpl> get copyWith =>
      __$$PrescriptionImplCopyWithImpl<_$PrescriptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrescriptionImplToJson(
      this,
    );
  }
}

abstract class _Prescription implements Prescription {
  const factory _Prescription(
      {required final String id,
      required final String patientId,
      required final String doctorId,
      required final String doctorName,
      required final DateTime date,
      required final List<PrescriptionItem> items,
      final String? observations,
      required final String clinicId}) = _$PrescriptionImpl;

  factory _Prescription.fromJson(Map<String, dynamic> json) =
      _$PrescriptionImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get doctorId;
  @override
  String get doctorName;
  @override
  DateTime get date;
  @override
  List<PrescriptionItem> get items;
  @override
  String? get observations;
  @override
  String get clinicId;

  /// Create a copy of Prescription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrescriptionImplCopyWith<_$PrescriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PrescriptionItem _$PrescriptionItemFromJson(Map<String, dynamic> json) {
  return _PrescriptionItem.fromJson(json);
}

/// @nodoc
mixin _$PrescriptionItem {
  String get medicineName => throw _privateConstructorUsedError;
  String get dosage => throw _privateConstructorUsedError;
  String get instructions => throw _privateConstructorUsedError;

  /// Serializes this PrescriptionItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrescriptionItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrescriptionItemCopyWith<PrescriptionItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrescriptionItemCopyWith<$Res> {
  factory $PrescriptionItemCopyWith(
          PrescriptionItem value, $Res Function(PrescriptionItem) then) =
      _$PrescriptionItemCopyWithImpl<$Res, PrescriptionItem>;
  @useResult
  $Res call({String medicineName, String dosage, String instructions});
}

/// @nodoc
class _$PrescriptionItemCopyWithImpl<$Res, $Val extends PrescriptionItem>
    implements $PrescriptionItemCopyWith<$Res> {
  _$PrescriptionItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrescriptionItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? medicineName = null,
    Object? dosage = null,
    Object? instructions = null,
  }) {
    return _then(_value.copyWith(
      medicineName: null == medicineName
          ? _value.medicineName
          : medicineName // ignore: cast_nullable_to_non_nullable
              as String,
      dosage: null == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrescriptionItemImplCopyWith<$Res>
    implements $PrescriptionItemCopyWith<$Res> {
  factory _$$PrescriptionItemImplCopyWith(_$PrescriptionItemImpl value,
          $Res Function(_$PrescriptionItemImpl) then) =
      __$$PrescriptionItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String medicineName, String dosage, String instructions});
}

/// @nodoc
class __$$PrescriptionItemImplCopyWithImpl<$Res>
    extends _$PrescriptionItemCopyWithImpl<$Res, _$PrescriptionItemImpl>
    implements _$$PrescriptionItemImplCopyWith<$Res> {
  __$$PrescriptionItemImplCopyWithImpl(_$PrescriptionItemImpl _value,
      $Res Function(_$PrescriptionItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of PrescriptionItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? medicineName = null,
    Object? dosage = null,
    Object? instructions = null,
  }) {
    return _then(_$PrescriptionItemImpl(
      medicineName: null == medicineName
          ? _value.medicineName
          : medicineName // ignore: cast_nullable_to_non_nullable
              as String,
      dosage: null == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrescriptionItemImpl implements _PrescriptionItem {
  const _$PrescriptionItemImpl(
      {required this.medicineName,
      required this.dosage,
      required this.instructions});

  factory _$PrescriptionItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrescriptionItemImplFromJson(json);

  @override
  final String medicineName;
  @override
  final String dosage;
  @override
  final String instructions;

  @override
  String toString() {
    return 'PrescriptionItem(medicineName: $medicineName, dosage: $dosage, instructions: $instructions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrescriptionItemImpl &&
            (identical(other.medicineName, medicineName) ||
                other.medicineName == medicineName) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, medicineName, dosage, instructions);

  /// Create a copy of PrescriptionItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrescriptionItemImplCopyWith<_$PrescriptionItemImpl> get copyWith =>
      __$$PrescriptionItemImplCopyWithImpl<_$PrescriptionItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrescriptionItemImplToJson(
      this,
    );
  }
}

abstract class _PrescriptionItem implements PrescriptionItem {
  const factory _PrescriptionItem(
      {required final String medicineName,
      required final String dosage,
      required final String instructions}) = _$PrescriptionItemImpl;

  factory _PrescriptionItem.fromJson(Map<String, dynamic> json) =
      _$PrescriptionItemImpl.fromJson;

  @override
  String get medicineName;
  @override
  String get dosage;
  @override
  String get instructions;

  /// Create a copy of PrescriptionItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrescriptionItemImplCopyWith<_$PrescriptionItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MedicalCertificate _$MedicalCertificateFromJson(Map<String, dynamic> json) {
  return _MedicalCertificate.fromJson(json);
}

/// @nodoc
mixin _$MedicalCertificate {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get doctorId => throw _privateConstructorUsedError;
  String get doctorName => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  int get daysOfRest => throw _privateConstructorUsedError;
  String get cid => throw _privateConstructorUsedError;
  String get clinicId => throw _privateConstructorUsedError;

  /// Serializes this MedicalCertificate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicalCertificate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicalCertificateCopyWith<MedicalCertificate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicalCertificateCopyWith<$Res> {
  factory $MedicalCertificateCopyWith(
          MedicalCertificate value, $Res Function(MedicalCertificate) then) =
      _$MedicalCertificateCopyWithImpl<$Res, MedicalCertificate>;
  @useResult
  $Res call(
      {String id,
      String patientId,
      String doctorId,
      String doctorName,
      DateTime date,
      String content,
      int daysOfRest,
      String cid,
      String clinicId});
}

/// @nodoc
class _$MedicalCertificateCopyWithImpl<$Res, $Val extends MedicalCertificate>
    implements $MedicalCertificateCopyWith<$Res> {
  _$MedicalCertificateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicalCertificate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? doctorName = null,
    Object? date = null,
    Object? content = null,
    Object? daysOfRest = null,
    Object? cid = null,
    Object? clinicId = null,
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
      doctorId: null == doctorId
          ? _value.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as String,
      doctorName: null == doctorName
          ? _value.doctorName
          : doctorName // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      daysOfRest: null == daysOfRest
          ? _value.daysOfRest
          : daysOfRest // ignore: cast_nullable_to_non_nullable
              as int,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      clinicId: null == clinicId
          ? _value.clinicId
          : clinicId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MedicalCertificateImplCopyWith<$Res>
    implements $MedicalCertificateCopyWith<$Res> {
  factory _$$MedicalCertificateImplCopyWith(_$MedicalCertificateImpl value,
          $Res Function(_$MedicalCertificateImpl) then) =
      __$$MedicalCertificateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String patientId,
      String doctorId,
      String doctorName,
      DateTime date,
      String content,
      int daysOfRest,
      String cid,
      String clinicId});
}

/// @nodoc
class __$$MedicalCertificateImplCopyWithImpl<$Res>
    extends _$MedicalCertificateCopyWithImpl<$Res, _$MedicalCertificateImpl>
    implements _$$MedicalCertificateImplCopyWith<$Res> {
  __$$MedicalCertificateImplCopyWithImpl(_$MedicalCertificateImpl _value,
      $Res Function(_$MedicalCertificateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MedicalCertificate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? doctorName = null,
    Object? date = null,
    Object? content = null,
    Object? daysOfRest = null,
    Object? cid = null,
    Object? clinicId = null,
  }) {
    return _then(_$MedicalCertificateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      doctorId: null == doctorId
          ? _value.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as String,
      doctorName: null == doctorName
          ? _value.doctorName
          : doctorName // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      daysOfRest: null == daysOfRest
          ? _value.daysOfRest
          : daysOfRest // ignore: cast_nullable_to_non_nullable
              as int,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      clinicId: null == clinicId
          ? _value.clinicId
          : clinicId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicalCertificateImpl implements _MedicalCertificate {
  const _$MedicalCertificateImpl(
      {required this.id,
      required this.patientId,
      required this.doctorId,
      required this.doctorName,
      required this.date,
      required this.content,
      required this.daysOfRest,
      required this.cid,
      required this.clinicId});

  factory _$MedicalCertificateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicalCertificateImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String doctorId;
  @override
  final String doctorName;
  @override
  final DateTime date;
  @override
  final String content;
  @override
  final int daysOfRest;
  @override
  final String cid;
  @override
  final String clinicId;

  @override
  String toString() {
    return 'MedicalCertificate(id: $id, patientId: $patientId, doctorId: $doctorId, doctorName: $doctorName, date: $date, content: $content, daysOfRest: $daysOfRest, cid: $cid, clinicId: $clinicId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicalCertificateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.daysOfRest, daysOfRest) ||
                other.daysOfRest == daysOfRest) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.clinicId, clinicId) ||
                other.clinicId == clinicId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, patientId, doctorId,
      doctorName, date, content, daysOfRest, cid, clinicId);

  /// Create a copy of MedicalCertificate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicalCertificateImplCopyWith<_$MedicalCertificateImpl> get copyWith =>
      __$$MedicalCertificateImplCopyWithImpl<_$MedicalCertificateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicalCertificateImplToJson(
      this,
    );
  }
}

abstract class _MedicalCertificate implements MedicalCertificate {
  const factory _MedicalCertificate(
      {required final String id,
      required final String patientId,
      required final String doctorId,
      required final String doctorName,
      required final DateTime date,
      required final String content,
      required final int daysOfRest,
      required final String cid,
      required final String clinicId}) = _$MedicalCertificateImpl;

  factory _MedicalCertificate.fromJson(Map<String, dynamic> json) =
      _$MedicalCertificateImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get doctorId;
  @override
  String get doctorName;
  @override
  DateTime get date;
  @override
  String get content;
  @override
  int get daysOfRest;
  @override
  String get cid;
  @override
  String get clinicId;

  /// Create a copy of MedicalCertificate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicalCertificateImplCopyWith<_$MedicalCertificateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
