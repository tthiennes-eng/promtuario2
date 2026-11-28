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
    final rawPrice = json['basePrice'] ?? json['baseValue'] ?? json['BasePrice'] ?? json['BaseValue'];
    final rawDesc = json['description'] ?? json['Description'] ?? json['code'] ?? json['Code'];
    final rawCat = json['category'] ?? json['Category'] ?? json['specialty'] ?? json['Specialty'];
    return Procedure(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      description: rawDesc?.toString(),
      basePrice: rawPrice is num ? rawPrice.toDouble() : double.tryParse(rawPrice?.toString() ?? ''),
      category: (rawCat?.toString().trim().isNotEmpty ?? false) ? rawCat.toString().trim() : 'Geral',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'code': description ?? '',
    'basePrice': basePrice ?? 0.0,
    'baseValue': basePrice ?? 0.0,
    'category': category,
  };
}
