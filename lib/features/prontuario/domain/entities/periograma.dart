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
  // 6 pontos: 0:MV, 1:V, 2:DV (Vestibular) | 3:ML, 4:L, 5:DL (Lingual/Palatina)
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

  Map<String, dynamic> toMap() => {
    'id': id,
    'patientId': patientId,
    'date': date.toIso8601String(),
    'tipo': tipo.name,
    'dentes': dentes.map((d) => d.toMap()).toList(),
  };

  factory PeriogramaModel.fromMap(Map<String, dynamic> map) => PeriogramaModel(
    id: map['id'],
    patientId: map['patientId'],
    date: DateTime.parse(map['date']),
    tipo: TipoExamePeriodontal.values.byName(map['tipo']),
    dentes: (map['dentes'] as List).map((d) => DenteSondagem.fromMap(d)).toList(),
  );

  String toJson() => jsonEncode(toMap());
}
