import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/reports_viewmodel.dart';
import '../../domain/entities/report_data.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicadores Acadêmicos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reportsViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      body: reportsAsync.when(
        data: (metrics) {
          if (metrics == null) return const Center(child: Text('Nenhum dado disponível.'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryGrid(metrics),
                const SizedBox(height: 32),
                const Text('Atendimentos por Especialidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildDetailedTable(context, metrics),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro ao carregar indicadores: ${err.toString()}')),
      ),
    );
  }

  Widget _buildSummaryGrid(ClinicPerformanceMetrics metrics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2,
      children: [
        _reportStat('Total Atendimentos', '${metrics.totalProceduresThisMonth}', Icons.check_circle, Colors.blue),
        _reportStat('Taxa de Ocupação', '${(metrics.occupancyRate * 100).toStringAsFixed(1)}%', Icons.pie_chart, Colors.orange),
        _reportStat('Índice de Assiduidade', '${((1 - metrics.absenceRate) * 100).toStringAsFixed(1)}%', Icons.person, Colors.green),
      ],
    );
  }

  Widget _reportStat(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTable(BuildContext context, ClinicPerformanceMetrics metrics) {
    final List<SpecialtyProduction> productions = metrics.specialtyProduction;

    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Especialidade')),
          DataColumn(label: Text('Qtd Atendimentos')),
          DataColumn(label: Text('Eficiência Acadêmica')),
        ],
        rows: productions.map((p) => DataRow(cells: [
          DataCell(Text(p.specialty)),
          DataCell(Text(p.appointmentCount.toString())),
          DataCell(Text('${(p.efficiencyRate * 100).toStringAsFixed(0)}%')),
        ])).toList(),
      ),
    );
  }
}
