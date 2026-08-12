import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../viewmodels/patient_viewmodel.dart';
import '../../domain/entities/patient.dart';

/// Tela de Listagem de Pacientes com padrão "Prontuário Profissional".
class PatientListScreen extends ConsumerWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(patientViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestão de Pacientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Base de dados clínica unificada', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(patientViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopStats(state),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              )),
              hintText: 'Pesquisar por nome, CPF ou prontuário...',
              leading: const Icon(Icons.search, color: Color(0xFF006494)),
              onChanged: (val) => ref.read(patientViewModelProvider.notifier).searchPatients(val),
            ),
          ),
          Expanded(
            child: state.patients.when(
              data: (patients) => patients.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      itemCount: patients.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        
                        // Busca histórico específico deste paciente
                        final patientHistory = state.allHistory.where((a) => a.patientId == patient.id).toList();
                        patientHistory.sort((a, b) => b.startTime.compareTo(a.startTime));
                        final lastApp = patientHistory.isNotEmpty ? patientHistory.first : null;

                        return _buildProfessionalPatientCard(context, patient, lastApp, patientHistory.length);
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

  Widget _buildTopStats(PatientListState state) {
    final count = state.patients.value?.length ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatBadge(label: 'Total de Pacientes', value: '$count', color: Colors.blueGrey),
          const SizedBox(width: 8),
          _StatBadge(label: 'Ativos', value: '$count', color: Colors.green), // Simulado
        ],
      ),
    );
  }

  Widget _buildProfessionalPatientCard(BuildContext context, Patient patient, dynamic lastApp, int totalApps) {
    final age = DateTime.now().year - patient.birthDate.year;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/dashboard/patients/prontuario', extra: patient),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF006494).withOpacity(0.1),
                    child: Text(patient.fullName[0], style: const TextStyle(color: Color(0xFF006494), fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(patient.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(width: 8),
                            _buildStatusTag(totalApps),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${patient.gender ?? "N/I"} • $age anos • CPF: ${patient.cpf}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.grey),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.history, 
                      'ÚLTIMO ATENDIMENTO', 
                      lastApp != null 
                        ? DateFormat('dd/MM/yyyy HH:mm').format(lastApp.startTime)
                        : 'Sem histórico anterior',
                      isHighlight: lastApp != null
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.assignment_turned_in_outlined, 
                      'PROCEDIMENTO', 
                      lastApp?.procedureName ?? 'Nenhum realizado',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(patient.phone ?? 'Sem telefone', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Text(
                    '$totalApps atendimentos no total',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF006494)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(int totalApps) {
    String label = totalApps == 0 ? 'NOVO' : 'EM TRATAMENTO';
    Color color = totalApps == 0 ? Colors.orange : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.blueGrey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value, 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isHighlight ? const Color(0xFF006494) : Colors.black87
          )
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Base de dados vazia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text('Cadastre o primeiro paciente para iniciar.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/dashboard/patients/add'),
            icon: const Icon(Icons.add),
            label: const Text('CADASTRAR PACIENTE'),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
