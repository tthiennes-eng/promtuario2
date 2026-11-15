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
    return Clinic(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 1,
      isActive: json['isActive'] as bool? ?? true,
      startHour: json['startHour'] as int? ?? 8,
      endHour: json['endHour'] as int? ?? 18,
      slotDurationMinutes: json['slotDurationMinutes'] as int? ?? 60,
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
}
