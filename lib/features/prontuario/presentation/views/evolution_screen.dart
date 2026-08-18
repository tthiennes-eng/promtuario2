import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/evolution_viewmodel.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../users/presentation/viewmodels/user_management_viewmodel.dart';
import '../../../auth/domain/entities/user.dart';

class EvolutionScreen extends ConsumerWidget {
  final String patientId;
  final String patientName;

  const EvolutionScreen({super.key, required this.patientId, required this.patientName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evolutionsAsync = ref.watch(evolutionViewModelProvider(patientId));
    final currentUser = ref.watch(authViewModelProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Evolução Clínica"),
            Text(patientName, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: evolutionsAsync.when(
                data: (evolutions) => evolutions.isEmpty 
                    ? const Center(child: Text('Nenhuma evolução clínica registrada.'))
                    : ListView.builder(
                        itemCount: evolutions.length,
                        itemBuilder: (context, index) {
                          final evolution = evolutions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${DateFormat('dd/MM/yyyy HH:mm').format(evolution.createdAt)} - ${evolution.clinicName ?? "Clínica Geral"}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      _buildStatusTag(evolution.isSignedByProfessor),
                                    ],
                                  ),
                                  const Divider(),
                                  Text(evolution.description),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 14, color: Colors.blueGrey),
                                      const SizedBox(width: 4),
                                      Text('Prof: ${evolution.professorName}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                                      const Spacer(),
                                      Text('Aluno: ${evolution.studentName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                  if (!evolution.isSignedByProfessor && currentUser?.role == UserRole.professor)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: FilledButton.icon(
                                        onPressed: () => ref.read(evolutionViewModelProvider(patientId).notifier).signEvolution(evolution.id),
                                        icon: const Icon(Icons.verified_user_outlined),
                                        label: const Text('Assinar Evolução'),
                                        style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Erro ao carregar histórico: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEvolutionDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova Evolução'),
      ),
    );
  }

  Widget _buildStatusTag(bool signed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: signed ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        signed ? 'Assinado' : 'Pendente',
        style: TextStyle(color: signed ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddEvolutionDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    String? selectedProfessorId;
    final professorsAsync = ref.read(userManagementViewModelProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Evolução Clínica'),
        content: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                professorsAsync.when(
                  data: (users) {
                    final professors = users.where((u) => u.role == UserRole.professor).toList();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Professor Supervisor'),
                      items: professors.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                      onChanged: (val) => setState(() => selectedProfessorId = val),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Erro ao carregar supervisores'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: 'Descreva detalhadamente o atendimento...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty && selectedProfessorId != null) {
                await ref.read(evolutionViewModelProvider(patientId).notifier)
                    .addEvolution(controller.text, selectedProfessorId!);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Salvar Evolução'),
          ),
        ],
      ),
    );
  }
}
