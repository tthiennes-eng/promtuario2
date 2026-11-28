import 'package:uuid/uuid.dart';

class Clinic {
  final String id;
  final String name;
  final String description;
  final String location;
  final int capacity;
  final bool isActive;
  final int startHour;
  final int endHour;
  final int slotDurationMinutes;
  final Map<String, dynamic>? metadata;

  const Clinic({
    required this.id,
    required this.name,
    this.description = '',
    this.location = '',
    this.capacity = 1,
    this.isActive = true,
    this.startHour = 8,
    this.endHour = 18,
    this.slotDurationMinutes = 60,
    this.metadata,
  });

  int get startHourSafe => startHour.clamp(0, 23);
  int get endHourSafe => endHour.clamp(0, 23);
  int get slotDurationMinutesSafe => slotDurationMinutes <= 0 ? 60 : slotDurationMinutes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Clinic && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Clinic copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    int? capacity,
    bool? isActive,
    int? startHour,
    int? endHour,
    int? slotDurationMinutes,
    Map<String, dynamic>? metadata,
  }) {
    return Clinic(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Clinic.fromJson(Map<String, dynamic> json) {
    String idValue = json['id']?.toString() ?? '';
    if (idValue.isEmpty && json['_id'] != null) idValue = json['_id'].toString();

    int intValue(String key, int fallback) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return fallback;
    }

    return Clinic(
      id: idValue,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      capacity: intValue('capacity', intValue('maxCapacity', 1)),
      isActive: json['isActive'] as bool? ?? true,
      startHour: intValue('startHour', 8),
      endHour: intValue('endHour', 18),
      slotDurationMinutes: intValue('slotDurationMinutes', 60),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'location': location,
    'capacity': capacity,
    'isActive': isActive,
    'startHour': startHour,
    'endHour': endHour,
    'slotDurationMinutes': slotDurationMinutes,
    'metadata': metadata,
  };

  static const Map<String, int> _romanOrder = {
    'i': 1,
    'ii': 2,
    'iii': 3,
    'iv': 4,
    'v': 5,
    'vi': 6,
    'vii': 7,
    'viii': 8,
    'ix': 9,
    'x': 10,
  };

  static final RegExp _numberedClinicPattern = RegExp(
    r'^clinica\s+(i|ii|iii|iv|v|vi|vii|viii|ix|x|\d+)$',
  );

  static String normalizeName(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static int? _sequenceNumber(String name) {
    final normalized = normalizeName(name);
    final match = _numberedClinicPattern.firstMatch(normalized);
    if (match == null) return null;
    final token = match.group(1)!;
    return _romanOrder[token] ?? int.tryParse(token);
  }

  static int compareNames(String a, String b) {
    final seqA = _sequenceNumber(a);
    final seqB = _sequenceNumber(b);
    if (seqA != null && seqB != null) {
      final diff = seqA.compareTo(seqB);
      if (diff != 0) return diff;
    } else if (seqA != null) {
      return -1;
    } else if (seqB != null) {
      return 1;
    }
    return normalizeName(a).compareTo(normalizeName(b));
  }

  static List<Clinic> sortBySequence(Iterable<Clinic> clinics) {
    final list = List<Clinic>.from(clinics);
    list.sort((a, b) => compareNames(a.name, b.name));
    final seen = <String>{};
    final unique = <Clinic>[];
    for (final clinic in list) {
      final key = normalizeName(clinic.name);
      if (key.isEmpty || seen.add(key)) {
        unique.add(clinic);
      }
    }
    return unique;
  }

  static const List<String> defaultNames = [
    'Clinica I',
    'Clinica II',
    'Clinica III',
    'Clinica IV',
    'Clinica V',
    'Clinica Integrada Infantil',
    'Clinica de Emergência',
    'Clinica Integrada Adulto I',
    'Clinica Integrada Adulto II',
    'Clinica de DTM',
    'Clinica de Odontopediatria',
  ];

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static String deterministicId(String name) {
    return const Uuid().v5(Uuid.NAMESPACE_URL, 'promtuario-clinic:$name');
  }

  static String resolveDisplayName({
    required String clinicId,
    String? clinicName,
    required Iterable<Clinic> clinics,
  }) {
    final trimmedName = clinicName?.trim() ?? '';
    if (trimmedName.isNotEmpty && !_uuidPattern.hasMatch(trimmedName)) {
      return trimmedName;
    }

    final trimmedId = clinicId.trim();
    if (trimmedId.isEmpty) return 'Clínica não informada';

    for (final clinic in clinics) {
      if (clinic.id == trimmedId && clinic.name.trim().isNotEmpty) {
        return clinic.name;
      }
    }

    for (final clinic in clinics) {
      if (deterministicId(clinic.name) == trimmedId) {
        return clinic.name;
      }
    }

    for (final name in defaultNames) {
      if (deterministicId(name) == trimmedId) {
        return name;
      }
    }

    if (!_uuidPattern.hasMatch(trimmedId)) {
      return trimmedId;
    }

    return 'Clínica não informada';
  }
}
