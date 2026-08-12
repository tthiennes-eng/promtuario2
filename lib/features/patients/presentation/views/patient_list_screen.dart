import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/procedures/presentation/viewmodels/clinics_viewmodel.dart';

class PatientListScreen extends ConsumerWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(patientListWithHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Gestão de Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(patientViewModelProvider.notifier).refresh();
              ref.invalidate(allAppointmentsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryBar(state),
          _buildSearchBar(ref),
          Expanded(
            child: state.patients.when(
              data: (patients) => patients.isEmpty
                  ? _buildEmptyState(context, ref)
                  : ListView.builder(
                      itemCount: patients.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        final history = (state.allHistory.value ?? [])
                            .where((a) => a.patientId == patient.id)
                            .toList();

                        // Histórico (Passado)
                        final past = history.where((a) => a.startTime.isBefore(DateTime.now())).toList();
                        past.sort((a, b) => b.startTime.compareTo(a.startTime));
                        final lastApp = past.isNotEmpty ? past.first : null;

                        // Agendamento (Futuro)
                        final future = history.where((a) => a.startTime.isAfter(DateTime.now())).toList();
                        future.sort((a, b) => a.startTime.compareTo(b.startTime));
                        final nextApp = future.isNotEmpty ? future.first : null;

                        return _buildDetailedPatientCard(context, ref, patient, lastApp, nextApp, history.length);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erro: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF006494),
        onPressed: () => context.push('/dashboard/patients/add'),
        label: const Text('ADMITIR PACIENTE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryBar(PatientListState state) {
    final count = state.patients.value?.length ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          _StatChip(label: 'Total', value: '$count', color: Colors.blueGrey),
          const SizedBox(width: 8),
          const _StatChip(label: 'Atendimentos Hoje', value: '4', color: Colors.green), // Exemplo fixo
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBar(
        elevation: MaterialStateProperty.all(0),
        backgroundColor: MaterialStateProperty.all(Colors.white),
        hintText: 'Pesquisar por nome ou CPF...',
        leading: const Icon(Icons.search, color: Color(0xFF006494)),
        onChanged: (val) => ref.read(patientViewModelProvider.notifier).searchPatients(val),
      ),
    );
  }

  Widget _buildDetailedPatientCard(BuildContext context, WidgetRef ref, Patient patient, Appointment? last, Appointment? next, int total) {
    final age = DateTime.now().year - patient.birthDate.year;
    
    String getClinic(String id) {
      final clinics = ref.read(clinicsViewModelProvider).value ?? [];
      try {
        return clinics.firstWhere((c) => c.id == id).name;
      } catch (_) { return id; }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () => context.push('/dashboard/patients/prontuario', extra: patient),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF006494).withOpacity(0.1),
                    child: Text(patient.fullName[0], style: const TextStyle(color: Color(0xFF006494), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('CPF: ${patient.cpf} • $age anos • ${patient.gender ?? "N/I"}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // GRID DE INFORMAÇÕES DETALHADAS (Solicitado)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAppointmentBlock('ÚLTIMO ATENDIMENTO', last, Colors.blueGrey, getClinic),
                  const SizedBox(height: 16),
                  _buildAppointmentBlock('PRÓXIMO AGENDAMENTO', next, Colors.green.shade700, getClinic),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentBlock(String label, Appointment? app, Color themeColor, String Function(String) getClinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 14, color: themeColor),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: themeColor, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 8),
        if (app != null)
          Row(
            children: [
              _infoItem(Icons.calendar_today, DateFormat('dd/MM/yyyy').format(app.startTime), themeColor),
              _infoItem(Icons.access_time, DateFormat('HH:mm').format(app.startTime), themeColor),
              _infoItem(Icons.local_hospital, getClinic(app.clinicId), themeColor),
              _infoItem(Icons.medical_services, app.procedureName ?? 'Geral', themeColor),
            ],
          )
        else
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text('Nenhum registro encontrado', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }

  Widget _infoItem(IconData icon, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color.withOpacity(0.7)),
          const SizedBox(height: 2),
          Text(value, 
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            maxLines: 1, 
            overflow: TextOverflow.ellipsis
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Pesquise por um paciente ou cadastre um novo.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
