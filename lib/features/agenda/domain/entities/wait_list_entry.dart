import 'package:freezed_annotation/freezed_annotation.dart';

// part 'wait_list_entry.freezed.dart';
// part 'wait_list_entry.g.dart';

@freezed
class WaitListEntry {
  final String id;
  final String patientId;
  final String patientName;
  final String clinicId;
  final String priority;
  final String specialty;
  final String? observation;
  final DateTime createdAt;

  const WaitListEntry({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.clinicId,
    required this.priority,
    required this.specialty,
    this.observation,
    required this.createdAt,
  });

  factory WaitListEntry.fromJson(Map<String, dynamic> json) {
    return WaitListEntry(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      clinicId: json['clinicId'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Normal',
      specialty: json['specialty'] as String? ?? '',
      observation: json['observation'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
