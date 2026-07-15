import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../dashboard/presentation/viewmodels/dashboard_viewmodel.dart';

/// Tela de Relatórios e Indicadores de Gestão.
/// Fornece uma visão analítica da produção da clínica, faltas e atendimentos.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios & Indicadores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Exportar PDF',
            onPressed: () => _exportReport(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: dashboardAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(context),
              const SizedBox(height: 32),
              _buildSummaryGrid(stats),
              const SizedBox(height: 32),
              _buildChartSection(context, stats.growthData),
              const SizedBox(height: 32),
              _buildDetailedTable(context),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro ao carregar dados: $err')),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Colors.blue),
            const SizedBox(width: 16),
            const Text('Período:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {},
              child: const Text('Últimos 30 dias'),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_alt_outlined),
              label: const Text('Filtrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(dynamic stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2,
      children: [
        _buildReportCard('Produtividade', '${stats.proceduresThisMonth}', Icons.trending_up, Colors.green),
        _buildReportCard('Taxa de Ocupação', '84%', Icons.pie_chart, Colors.orange),
        _buildReportCard('Índice de Faltas', '12%', Icons.person_off, Colors.red),
      ],
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, List<dynamic> growthData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Evolução de Atendimentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              height: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: growthData.map((d) => _buildBar(d.month, d.count)).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBar(String label, int value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 50,
          height: value.toDouble() * 3,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildDetailedTable(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Produção por Especialidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Especialidade')),
              DataColumn(label: Text('Atendimentos')),
              DataColumn(label: Text('Valor Gerado')),
              DataColumn(label: Text('Eficiência')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Endodontia')),
                DataCell(Text('42')),
                DataCell(Text('R\$ 12.450,00')),
                DataCell(Text('92%')),
              ]),
              DataRow(cells: [
                DataCell(Text('Cirurgia')),
                DataCell(Text('28')),
                DataCell(Text('R\$ 8.900,00')),
                DataCell(Text('88%')),
              ]),
              DataRow(cells: [
                DataCell(Text('Prótese')),
                DataCell(Text('15')),
                DataCell(Text('R\$ 22.300,00')),
                DataCell(Text('75%')),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  void _exportReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gerando relatório consolidado...')),
    );
  }
}
