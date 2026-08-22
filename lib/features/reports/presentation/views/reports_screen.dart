import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/reports_viewmodel.dart';
import '../../domain/entities/report_data.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsViewModelProvider);
    final notifier = ref.read(reportsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicadores Acadêmicos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(context, state, notifier),
          Expanded(
            child: state.metrics.when(
              data: (metrics) {
                if (metrics == null) return const Center(child: Text('Nenhum dado disponível.'));
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryGrid(metrics),
                      const SizedBox(height: 32),
                      const Text('Atendimentos por Especialidade', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildDetailedTable(context, metrics),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erro ao carregar indicadores: ${err.toString()}')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, ReportsState state, ReportsViewModel notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<Clinic>(
                  value: state.selectedClinic,
                  decoration: const InputDecoration(
                    labelText: 'Clínica',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas as Clínicas')),
                    ...state.clinics.map((c) => DropdownMenuItem(value: c, child: Text(c.name))),
                  ],
                  onChanged: (val) => notifier.selectClinic(val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Período Acadêmico', border: OutlineInputBorder(), isDense: true),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Personalizado')),
                    DropdownMenuItem(value: 1, child: Text('1º Semestre')),
                    DropdownMenuItem(value: 2, child: Text('2º Semestre')),
                  ],
                  onChanged: (val) {
                    if (val == 1) {
                      notifier.setPeriod(DateTime(DateTime.now().year, 1, 1), DateTime(DateTime.now().year, 6, 30));
                    } else if (val == 2) {
                      notifier.setPeriod(DateTime(DateTime.now().year, 7, 1), DateTime(DateTime.now().year, 12, 31));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _selectDateRange(context, state, notifier),
            icon: const Icon(Icons.date_range),
            label: Text('Intervalo: ${DateFormat('dd/MM/yy').format(state.startDate)} - ${DateFormat('dd/MM/yy').format(state.endDate)}'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 48)
            ),
          ),
        ],
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
      childAspectRatio: 1.5,
      children: [
        _reportStat('Total Atendimentos', '${metrics.totalProceduresThisMonth}', Icons.check_circle, Colors.blue),
        _reportStat('Taxa de Ocupação', '${(metrics.occupancyRate * 100).toStringAsFixed(1)}%', Icons.pie_chart, Colors.orange),
        _reportStat('Índice de Assiduidade', '${((1 - metrics.absenceRate) * 100).toStringAsFixed(1)}%', Icons.person, Colors.green),
      ],
    );
  }

  Widget _reportStat(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTable(BuildContext context, ClinicPerformanceMetrics metrics) {
    final List<SpecialtyProduction> productions = metrics.specialtyProduction;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        width: double.infinity,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Especialidade')),
            DataColumn(label: Text('Qtd')),
            DataColumn(label: Text('Eficiência')),
          ],
          rows: productions.map((p) => DataRow(cells: [
            DataCell(Text(p.specialty)),
            DataCell(Text(p.appointmentCount.toString())),
            DataCell(_buildEfficiencyIndicator(p.efficiencyRate)),
          ])).toList(),
        ),
      ),
    );
  }

  Widget _buildEfficiencyIndicator(double rate) {
    Color color = rate > 0.8 ? Colors.green : (rate > 0.5 ? Colors.orange : Colors.red);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('${(rate * 100).toStringAsFixed(0)}%'),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context, ReportsState state, ReportsViewModel notifier) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: state.startDate, end: state.endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      notifier.setPeriod(picked.start, picked.end);
    }
  }
}
