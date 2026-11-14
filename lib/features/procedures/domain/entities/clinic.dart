import 'package:freezed_annotation/freezed_annotation.dart';

// part 'clinic.freezed.dart';
// part 'clinic.g.dart';

@freezed
class Clinic {
  final String id;
  final String name;
  final String description;
  final String location;
  final int capacity;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const Clinic({
    required this.id,
    required this.name,
    this.description = '',
    this.location = '',
    this.capacity = 1,
    this.isActive = true,
    this.metadata,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 1,
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'location': location,
    'capacity': capacity,
    'isActive': isActive,
    'metadata': metadata,
  };
}
