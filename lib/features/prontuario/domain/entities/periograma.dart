import 'dart:convert';

enum TipoExamePeriodontal { primeiro, reavaliacao, manutencao }

class PontoSondagem {
  int profundidade; // PS
  int recessao; // MG
  int nivelInsercao; // NIC
  bool sangramento; // SS
  bool supuracao; // SUP
  bool placa; // PL

  PontoSondagem({
    this.profundidade = 0,
    this.recessao = 0,
    this.nivelInsercao = 0,
    this.sangramento = false,
    this.supuracao = false,
    this.placa = false,
  });

  Map<String, dynamic> toMap() => {
    'profundidade': profundidade,
    'recessao': recessao,
    'nivelInsercao': nivelInsercao,
    'sangramento': sangramento,
    'supuracao': supuracao,
    'placa': placa,
  };

  factory PontoSondagem.fromMap(Map<String, dynamic> map) => PontoSondagem(
    profundidade: map['profundidade'] ?? 0,
    recessao: map['recessao'] ?? 0,
    nivelInsercao: map['nivelInsercao'] ?? 0,
    sangramento: map['sangramento'] ?? false,
    supuracao: map['supuracao'] ?? false,
    placa: map['placa'] ?? false,
  );
}

class DenteSondagem {
  final int toothNumber;
  final List<PontoSondagem> pontos;
  int mobilidade; // 0, 1, 2, 3
  String furca; // N/A, I, II, III

  DenteSondagem({
    required this.toothNumber,
    List<PontoSondagem>? pontos,
    this.mobilidade = 0,
    this.furca = "N/A",
  }) : this.pontos = pontos ?? List.generate(6, (_) => PontoSondagem());

  Map<String, dynamic> toMap() => {
    'toothNumber': toothNumber,
    'pontos': pontos.map((p) => p.toMap()).toList(),
    'mobilidade': mobilidade,
    'furca': furca,
  };

  factory DenteSondagem.fromMap(Map<String, dynamic> map) => DenteSondagem(
    toothNumber: map['toothNumber'],
    pontos: (map['pontos'] as List).map((p) => PontoSondagem.fromMap(p)).toList(),
    mobilidade: map['mobilidade'] ?? 0,
    furca: map['furca'] ?? "N/A",
  );
}

class PeriogramaModel {
  String id;
  String patientId;
  DateTime date;
  TipoExamePeriodontal tipo;
  List<DenteSondagem> dentes;

  PeriogramaModel({
    required this.id,
    required this.patientId,
    required this.date,
    this.tipo = TipoExamePeriodontal.primeiro,
    required this.dentes,
  });

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

  Map<String, dynamic> toMap() => {
    'id': id,
    'patientId': patientId,
    'date': date.toIso8601String(),
    'tipo': tipo.name,
    'dentes': dentes.map((d) => d.toMap()).toList(),
  };

  factory PeriogramaModel.fromMap(Map<String, dynamic> map) => PeriogramaModel(
    id: (map['id'] ?? map['Id'])?.toString() ?? '',
    patientId: (map['patientId'] ?? map['PatientId'])?.toString() ?? '',
    date: _safeParse(map['date'] ?? map['Date']),
    tipo: TipoExamePeriodontal.values.firstWhere(
      (e) => e.name == (map['tipo'] ?? map['Tipo']),
      orElse: () => TipoExamePeriodontal.primeiro,
    ),
    dentes: (map['dentes'] as List? ?? map['Dentes'] as List? ?? [])
        .map((d) => DenteSondagem.fromMap(Map<String, dynamic>.from(d)))
        .toList(),
  );

  String toJson() => jsonEncode(toMap());
}
