import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/patient_viewmodel.dart';
import '../../domain/entities/patient.dart';

class PatientListScreen extends ConsumerWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(patientViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Buscar por nome ou CPF...',
              leading: const Icon(Icons.search),
              onChanged: (val) => ref.read(patientViewModelProvider.notifier).searchPatients(val),
            ),
          ),
          Expanded(
            child: patientsAsync.when(
              data: (patients) => patients.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      itemCount: patients.length,
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(patient.fullName[0].toUpperCase()),
                            ),
                            title: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('CPF: ${patient.cpf}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/dashboard/patients/prontuario', extra: patient),
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erro ao carregar: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/dashboard/patients/add'),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Nenhum paciente encontrado.'),
          TextButton(
            onPressed: () => context.push('/dashboard/patients/add'),
            child: const Text('Cadastrar Primeiro Paciente'),
          ),
        ],
      ),
    );
  }
}
