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

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuarioId': usuarioId,
        'acao': acao,
        'detalhes': detalhes,
        'dataHora': dataHora.toIso8601String(),
        'ipAddress': ipAddress,
      };

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
}
