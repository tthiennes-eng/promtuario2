import 'package:freezed_annotation/freezed_annotation.dart';

// part 'audit_log.freezed.dart';
// part 'audit_log.g.dart';

@freezed
class AuditLog {
  final String id;
  final String usuarioId;
  final String acao;
  final String detalhes;
  final DateTime dataHora;
  final String? ipAddress;

  const AuditLog({
    required this.id,
    required this.usuarioId,
    required this.acao,
    required this.detalhes,
    required this.dataHora,
    this.ipAddress,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String? ?? '',
      usuarioId: json['usuarioId'] as String? ?? '',
      acao: json['acao'] as String? ?? '',
      detalhes: json['detalhes'] as String? ?? '',
      dataHora: json['dataHora'] != null ? DateTime.parse(json['dataHora']) : DateTime.now(),
      ipAddress: json['ipAddress'] as String?,
    );
  }
}
