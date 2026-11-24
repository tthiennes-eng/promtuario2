import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log.freezed.dart';

@freezed
class AuditLog with _$AuditLog {
  const factory AuditLog({
    required String id,
    required String usuarioId,
    required String acao,
    required String detalhes,
    required DateTime dataHora,
    String? ipAddress,
  }) = _AuditLog;

  static DateTime _safeParse(dynamic v) {
    if (v == null || v.toString().trim().isEmpty || v.toString() == 'null') {
      return DateTime.now();
    }
    try {
      if (v is DateTime) return v.isUtc ? v.toLocal() : v;
      final s = v.toString();
      final dateStr = s.contains('T') || s.contains(' ') ? s : '${s}T00:00:00';
      final dt = DateTime.parse(dateStr);
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      usuarioId: (json['usuarioId'] ?? json['UsuarioId'] ?? '') as String,
      acao: (json['acao'] ?? json['Acao'] ?? '') as String,
      detalhes: (json['detalhes'] ?? json['Detalhes'] ?? '') as String,
      dataHora: _safeParse(json['dataHora'] ?? json['DataHora']),
      ipAddress: (json['ipAddress'] ?? json['IpAddress']) as String?,
    );
  }
}
