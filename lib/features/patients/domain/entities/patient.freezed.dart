// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Patient _$PatientFromJson(Map<String, dynamic> json) {
  return _Patient.fromJson(json);
}

/// @nodoc
mixin _$Patient {
  String get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get cpf => throw _privateConstructorUsedError;
  DateTime get birthDate => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  PatientAddress? get address => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get lgpdConsent => throw _privateConstructorUsedError;
  bool get isSynced => throw _privateConstructorUsedError;

  /// Serializes this Patient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientCopyWith<Patient> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientCopyWith<$Res> {
  factory $PatientCopyWith(Patient value, $Res Function(Patient) then) =
      _$PatientCopyWithImpl<$Res, Patient>;
  @useResult
  $Res call(
      {String id,
      String fullName,
      String cpf,
      DateTime birthDate,
      String? email,
      String? phone,
      String? gender,
      PatientAddress? address,
      DateTime createdAt,
      DateTime? updatedAt,
      bool lgpdConsent,
      bool isSynced});

  $PatientAddressCopyWith<$Res>? get address;
}

/// @nodoc
class _$PatientCopyWithImpl<$Res, $Val extends Patient>
    implements $PatientCopyWith<$Res> {
  _$PatientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? cpf = null,
    Object? birthDate = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? gender = freezed,
    Object? address = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? lgpdConsent = null,
    Object? isSynced = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      cpf: null == cpf
          ? _value.cpf
          : cpf // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as PatientAddress?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lgpdConsent: null == lgpdConsent
          ? _value.lgpdConsent
          : lgpdConsent // ignore: cast_nullable_to_non_nullable
              as bool,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PatientAddressCopyWith<$Res>? get address {
    if (_value.address == null) {
      return null;
    }

    return $PatientAddressCopyWith<$Res>(_value.address!, (value) {
      return _then(_value.copyWith(address: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PatientImplCopyWith<$Res> implements $PatientCopyWith<$Res> {
  factory _$$PatientImplCopyWith(
          _$PatientImpl value, $Res Function(_$PatientImpl) then) =
      __$$PatientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fullName,
      String cpf,
      DateTime birthDate,
      String? email,
      String? phone,
      String? gender,
      PatientAddress? address,
      DateTime createdAt,
      DateTime? updatedAt,
      bool lgpdConsent,
      bool isSynced});

  @override
  $PatientAddressCopyWith<$Res>? get address;
}

/// @nodoc
class __$$PatientImplCopyWithImpl<$Res>
    extends _$PatientCopyWithImpl<$Res, _$PatientImpl>
    implements _$$PatientImplCopyWith<$Res> {
  __$$PatientImplCopyWithImpl(
      _$PatientImpl _value, $Res Function(_$PatientImpl) _then)
      : super(_value, _then);

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? cpf = null,
    Object? birthDate = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? gender = freezed,
    Object? address = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? lgpdConsent = null,
    Object? isSynced = null,
  }) {
    return _then(_$PatientImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      cpf: null == cpf
          ? _value.cpf
          : cpf // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as PatientAddress?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lgpdConsent: null == lgpdConsent
          ? _value.lgpdConsent
          : lgpdConsent // ignore: cast_nullable_to_non_nullable
              as bool,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientImpl implements _Patient {
  const _$PatientImpl(
      {required this.id,
      required this.fullName,
      required this.cpf,
      required this.birthDate,
      this.email,
      this.phone,
      this.gender,
      this.address,
      required this.createdAt,
      this.updatedAt,
      this.lgpdConsent = false,
      this.isSynced = true});

  factory _$PatientImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientImplFromJson(json);

  @override
  final String id;
  @override
  final String fullName;
  @override
  final String cpf;
  @override
  final DateTime birthDate;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? gender;
  @override
  final PatientAddress? address;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool lgpdConsent;
  @override
  @JsonKey()
  final bool isSynced;

  @override
  String toString() {
    return 'Patient(id: $id, fullName: $fullName, cpf: $cpf, birthDate: $birthDate, email: $email, phone: $phone, gender: $gender, address: $address, createdAt: $createdAt, updatedAt: $updatedAt, lgpdConsent: $lgpdConsent, isSynced: $isSynced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.cpf, cpf) || other.cpf == cpf) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lgpdConsent, lgpdConsent) ||
                other.lgpdConsent == lgpdConsent) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fullName,
      cpf,
      birthDate,
      email,
      phone,
      gender,
      address,
      createdAt,
      updatedAt,
      lgpdConsent,
      isSynced);

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      __$$PatientImplCopyWithImpl<_$PatientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientImplToJson(
      this,
    );
  }
}

abstract class _Patient implements Patient {
  const factory _Patient(
      {required final String id,
      required final String fullName,
      required final String cpf,
      required final DateTime birthDate,
      final String? email,
      final String? phone,
      final String? gender,
      final PatientAddress? address,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final bool lgpdConsent,
      final bool isSynced}) = _$PatientImpl;

  factory _Patient.fromJson(Map<String, dynamic> json) = _$PatientImpl.fromJson;

  @override
  String get id;
  @override
  String get fullName;
  @override
  String get cpf;
  @override
  DateTime get birthDate;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get gender;
  @override
  PatientAddress? get address;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  bool get lgpdConsent;
  @override
  bool get isSynced;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PatientAddress _$PatientAddressFromJson(Map<String, dynamic> json) {
  return _PatientAddress.fromJson(json);
}

/// @nodoc
mixin _$PatientAddress {
  String get street => throw _privateConstructorUsedError;
  String get number => throw _privateConstructorUsedError;
  String? get complement => throw _privateConstructorUsedError;
  String get neighborhood => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String get zipCode => throw _privateConstructorUsedError;

  /// Serializes this PatientAddress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PatientAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientAddressCopyWith<PatientAddress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientAddressCopyWith<$Res> {
  factory $PatientAddressCopyWith(
          PatientAddress value, $Res Function(PatientAddress) then) =
      _$PatientAddressCopyWithImpl<$Res, PatientAddress>;
  @useResult
  $Res call(
      {String street,
      String number,
      String? complement,
      String neighborhood,
      String city,
      String state,
      String zipCode});
}

/// @nodoc
class _$PatientAddressCopyWithImpl<$Res, $Val extends PatientAddress>
    implements $PatientAddressCopyWith<$Res> {
  _$PatientAddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PatientAddress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? street = null,
    Object? number = null,
    Object? complement = freezed,
    Object? neighborhood = null,
    Object? city = null,
    Object? state = null,
    Object? zipCode = null,
  }) {
    return _then(_value.copyWith(
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      complement: freezed == complement
          ? _value.complement
          : complement // ignore: cast_nullable_to_non_nullable
              as String?,
      neighborhood: null == neighborhood
          ? _value.neighborhood
          : neighborhood // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      zipCode: null == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatientAddressImplCopyWith<$Res>
    implements $PatientAddressCopyWith<$Res> {
  factory _$$PatientAddressImplCopyWith(_$PatientAddressImpl value,
          $Res Function(_$PatientAddressImpl) then) =
      __$$PatientAddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String street,
      String number,
      String? complement,
      String neighborhood,
      String city,
      String state,
      String zipCode});
}

/// @nodoc
class __$$PatientAddressImplCopyWithImpl<$Res>
    extends _$PatientAddressCopyWithImpl<$Res, _$PatientAddressImpl>
    implements _$$PatientAddressImplCopyWith<$Res> {
  __$$PatientAddressImplCopyWithImpl(
      _$PatientAddressImpl _value, $Res Function(_$PatientAddressImpl) _then)
      : super(_value, _then);

  /// Create a copy of PatientAddress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? street = null,
    Object? number = null,
    Object? complement = freezed,
    Object? neighborhood = null,
    Object? city = null,
    Object? state = null,
    Object? zipCode = null,
  }) {
    return _then(_$PatientAddressImpl(
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      complement: freezed == complement
          ? _value.complement
          : complement // ignore: cast_nullable_to_non_nullable
              as String?,
      neighborhood: null == neighborhood
          ? _value.neighborhood
          : neighborhood // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      zipCode: null == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientAddressImpl implements _PatientAddress {
  const _$PatientAddressImpl(
      {required this.street,
      required this.number,
      this.complement,
      required this.neighborhood,
      required this.city,
      required this.state,
      required this.zipCode});

  factory _$PatientAddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientAddressImplFromJson(json);

  @override
  final String street;
  @override
  final String number;
  @override
  final String? complement;
  @override
  final String neighborhood;
  @override
  final String city;
  @override
  final String state;
  @override
  final String zipCode;

  @override
  String toString() {
    return 'PatientAddress(street: $street, number: $number, complement: $complement, neighborhood: $neighborhood, city: $city, state: $state, zipCode: $zipCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientAddressImpl &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.complement, complement) ||
                other.complement == complement) &&
            (identical(other.neighborhood, neighborhood) ||
                other.neighborhood == neighborhood) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, street, number, complement,
      neighborhood, city, state, zipCode);

  /// Create a copy of PatientAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientAddressImplCopyWith<_$PatientAddressImpl> get copyWith =>
      __$$PatientAddressImplCopyWithImpl<_$PatientAddressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientAddressImplToJson(
      this,
    );
  }
}

abstract class _PatientAddress implements PatientAddress {
  const factory _PatientAddress(
      {required final String street,
      required final String number,
      final String? complement,
      required final String neighborhood,
      required final String city,
      required final String state,
      required final String zipCode}) = _$PatientAddressImpl;

  factory _PatientAddress.fromJson(Map<String, dynamic> json) =
      _$PatientAddressImpl.fromJson;

  @override
  String get street;
  @override
  String get number;
  @override
  String? get complement;
  @override
  String get neighborhood;
  @override
  String get city;
  @override
  String get state;
  @override
  String get zipCode;

  /// Create a copy of PatientAddress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientAddressImplCopyWith<_$PatientAddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
