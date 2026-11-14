import 'package:freezed_annotation/freezed_annotation.dart';

// REUPERAÇÃO DE EMERGÊNCIA: Convertido para classe normal para destravar o compilador Dart 3.5
// Após o build_runner funcionar, podemos retornar ao Freezed.

class Patient {
  final String id;
  final String fullName;
  final String cpf;
  final DateTime birthDate;
  final String? email;
  final String? phone;
  final String? gender;
  final dynamic address;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool lgpdConsent;
  final bool isSynced;

  const Patient({
    required this.id,
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
    this.isSynced = true,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      cpf: json['cpf'] as String? ?? '',
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : DateTime.now(),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      lgpdConsent: json['lgpdConsent'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'fullName': fullName};

  Patient copyWith({
    String? id,
    String? fullName,
    String? cpf,
    DateTime? birthDate,
    String? email,
    String? phone,
    String? gender,
    dynamic address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? lgpdConsent,
    bool? isSynced,
  }) {
    return Patient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      cpf: cpf ?? this.cpf,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lgpdConsent: lgpdConsent ?? this.lgpdConsent,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

class PatientAddress {
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;

  const PatientAddress({
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory PatientAddress.fromJson(Map<String, dynamic> json) {
    return PatientAddress(
      street: json['street'] as String? ?? '',
      number: json['number'] as String? ?? '',
      complement: json['complement'] as String?,
      neighborhood: json['neighborhood'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
    );
  }
}
