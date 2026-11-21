enum TreatmentPlanStatus {
  draft,
  active,
  completed,
  canceled,
}

enum TreatmentItemStatus {
  pending,
  inProgress,
  completed,
  canceled,
}

class TreatmentPlan {
  final String id;
  final String patientId;
  final String description;
  final List<TreatmentItem> items;
  final TreatmentPlanStatus status;
  final DateTime createdAt;

  const TreatmentPlan({
    required this.id,
    required this.patientId,
    required this.description,
    required this.items,
    required this.status,
    required this.createdAt,
  });

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    return TreatmentPlan(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      description: json['description'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => TreatmentItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      status: TreatmentPlanStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'draft'),
        orElse: () => TreatmentPlanStatus.draft,
      ),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'description': description,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  TreatmentPlan copyWith({
    String? id,
    String? patientId,
    String? description,
    List<TreatmentItem>? items,
    TreatmentPlanStatus? status,
    DateTime? createdAt,
  }) {
    return TreatmentPlan(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      description: description ?? this.description,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TreatmentItem {
  final String id;
  final String procedureId;
  final String procedureName;
  final int? toothNumber;
  final TreatmentItemStatus status;
  final String? observation;

  const TreatmentItem({
    required this.id,
    required this.procedureId,
    required this.procedureName,
    this.toothNumber,
    required this.status,
    this.observation,
  });

  factory TreatmentItem.fromJson(Map<String, dynamic> json) {
    return TreatmentItem(
      id: json['id'] as String? ?? '',
      procedureId: json['procedureId'] as String? ?? '',
      procedureName: json['procedureName'] as String? ?? '',
      toothNumber: json['toothNumber'] as int?,
      status: TreatmentItemStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => TreatmentItemStatus.pending,
      ),
      observation: json['observation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'procedureId': procedureId,
        'procedureName': procedureName,
        'toothNumber': toothNumber,
        'status': status.name,
        'observation': observation,
      };

  TreatmentItem copyWith({
    String? id,
    String? procedureId,
    String? procedureName,
    int? toothNumber,
    TreatmentItemStatus? status,
    String? observation,
  }) {
    return TreatmentItem(
      id: id ?? this.id,
      procedureId: procedureId ?? this.procedureId,
      procedureName: procedureName ?? this.procedureName,
      toothNumber: toothNumber ?? this.toothNumber,
      status: status ?? this.status,
      observation: observation ?? this.observation,
    );
  }
}
