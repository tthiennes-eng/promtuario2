import 'package:freezed_annotation/freezed_annotation.dart';

// Comentado para destravar o compilador FFI durante o impasse de geração
// part 'procedure.freezed.dart';
// part 'procedure.g.dart';

class Procedure {
  final String id;
  final String name;
  final String? description;
  final double? basePrice;
  final String category;

  const Procedure({
    required this.id,
    required this.name,
    this.description,
    this.basePrice,
    required this.category,
  });

  factory Procedure.fromJson(Map<String, dynamic> json) {
    return Procedure(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble(),
      category: json['category'] as String? ?? 'Geral',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
  };
}
