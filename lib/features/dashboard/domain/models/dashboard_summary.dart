class DashboardSummary {
  final int totalPacientes;
  final int agendamentosHoje;
  final int atendimentos;

  const DashboardSummary({
    required this.totalPacientes,
    required this.agendamentosHoje,
    required this.atendimentos,
  });

  DashboardSummary copyWith({
    int? totalPacientes,
    int? agendamentosHoje,
    int? atendimentos,
  }) {
    return DashboardSummary(
      totalPacientes: totalPacientes ?? this.totalPacientes,
      agendamentosHoje: agendamentosHoje ?? this.agendamentosHoje,
      atendimentos: atendimentos ?? this.atendimentos,
    );
  }

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalPacientes: (json['totalPacientes'] ?? json['TotalPacientes'] ?? 0) as int,
      agendamentosHoje: (json['agendamentosHoje'] ?? json['AgendamentosHoje'] ?? 0) as int,
      atendimentos: (json['atendimentos'] ?? json['Atendimentos'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalPacientes': totalPacientes,
    'agendamentosHoje': agendamentosHoje,
    'atendimentos': atendimentos,
  };
}
