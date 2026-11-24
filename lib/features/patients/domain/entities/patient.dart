import 'package:promt/core/utils/date_utils.dart';

class Patient {
  final String id;
  final String fullName;
  final String? socialName;
  final String cpf;
  final String? susNumber;
  final DateTime birthDate;
  final String? email;
  final String? phone;
  final String? gender;
  final PatientAddress? address;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool lgpdConsent;
  final bool isSynced;

  const Patient({
    required this.id,
    required this.fullName,
    this.socialName,
    required this.cpf,
    this.susNumber,
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
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      fullName: (json['fullName'] ?? json['FullName'] ?? 'Sem Nome') as String,
      socialName: (json['socialName'] ?? json['SocialName']) as String?,
      cpf: (json['cpf'] ?? json['CPF'] ?? '') as String,
      susNumber: (json['susNumber'] ?? json['SusNumber']) as String?,
      birthDate: SafeDateParser.parse(json['birthDate'] ?? json['BirthDate']),
      email: (json['email'] ?? json['Email']) as String?,
      phone: (json['phone'] ?? json['Phone']) as String?,
      gender: (json['gender'] ?? json['Gender']) as String?,
      address: json['address'] != null ? PatientAddress.fromJson(Map<String, dynamic>.from(json['address'])) : null,
      createdAt: SafeDateParser.parse(json['createdAt'] ?? json['CreatedAt']),
      updatedAt: (json['updatedAt'] ?? json['UpdatedAt']) != null ? SafeDateParser.parse(json['updatedAt'] ?? json['UpdatedAt']) : null,
      lgpdConsent: (json['lgpdConsent'] ?? json['LgpdConsent'] ?? false) as bool,
      isSynced: (json['isSynced'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'socialName': socialName,
        'cpf': cpf,
        'susNumber': susNumber,
        'birthDate': birthDate.toIso8601String(),
        'email': email,
        'phone': phone,
        'gender': gender,
        'address': address?.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'lgpdConsent': lgpdConsent,
        'isSynced': isSynced,
      };

  Patient copyWith({
    String? id,
    String? fullName,
    String? socialName,
    String? cpf,
    String? susNumber,
    DateTime? birthDate,
    String? email,
    String? phone,
    String? gender,
    PatientAddress? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? lgpdConsent,
    bool? isSynced,
  }) {
    return Patient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      socialName: socialName ?? this.socialName,
      cpf: cpf ?? this.cpf,
      susNumber: susNumber ?? this.susNumber,
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
      street: (json['street'] ?? json['Street'] ?? '') as String,
      number: (json['number'] ?? json['Number'] ?? '') as String,
      complement: (json['complement'] ?? json['Complement']) as String?,
      neighborhood: (json['neighborhood'] ?? json['Neighborhood'] ?? '') as String,
      city: (json['city'] ?? json['City'] ?? '') as String,
      state: (json['state'] ?? json['State'] ?? '') as String,
      zipCode: (json['zipCode'] ?? json['ZipCode'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'street': street,
        'number': number,
        'complement': complement,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'zipCode': zipCode,
      };
}
