import 'package:promt/core/utils/date_utils.dart';

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

  AuditLog copyWith({
    String? id,
    String? usuarioId,
    String? acao,
    String? detalhes,
    DateTime? dataHora,
    String? ipAddress,
  }) {
    return AuditLog(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      acao: acao ?? this.acao,
      detalhes: detalhes ?? this.detalhes,
      dataHora: dataHora ?? this.dataHora,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    String getString(List<String> keys) {
      for (final k in keys) {
        final val = json[k];
        if (val != null && val.toString().isNotEmpty) return val.toString();
      }
      return '';
    }

    return AuditLog(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      usuarioId: getString(['usuarioId', 'UsuarioId', 'usuario_id', 'userId', 'UserId']),
      acao: getString(['acao', 'Acao', 'action', 'Action']),
      detalhes: getString(['detalhes', 'Detalhes', 'details', 'Details']),
      dataHora: SafeDateParser.parse(json['dataHora'] ?? json['DataHora'] ?? json['timestamp'] ?? json['Timestamp']),
      ipAddress: (json['ipAddress'] ?? json['IpAddress'] ?? json['ip_address'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuarioId': usuarioId,
    'acao': acao,
    'detalhes': detalhes,
    'dataHora': dataHora.toIso8601String(),
    'ipAddress': ipAddress,
  };
}
