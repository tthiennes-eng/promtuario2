import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/procedures/presentation/viewmodels/clinics_viewmodel.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';

class ClinicManagementScreen extends ConsumerWidget {
  const ClinicManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsync = ref.watch(clinicsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Clínicas'),
      ),
      body: clinicsAsync.when(
        data: (clinics) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clinics.length,
          itemBuilder: (context, index) {
            final clinic = clinics[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: clinic.isActive ? Colors.green.shade100 : Colors.grey.shade200,
                  child: Icon(
                    Icons.local_hospital,
                    color: clinic.isActive ? Colors.green : Colors.grey,
                  ),
                ),
                title: Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${clinic.location ?? "Sem localização"} • ${clinic.capacity} cadeiras'),
                trailing: Switch(
                  value: clinic.isActive,
                  onChanged: (val) => ref.read(clinicsViewModelProvider.notifier).toggleClinicStatus(clinic),
                ),
                onTap: () => _showEditClinicDialog(context, ref, clinic),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditClinicDialog(context, ref, null),
        label: const Text('Nova Clínica'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showEditClinicDialog(BuildContext context, WidgetRef ref, Clinic? clinic) {
    final nameController = TextEditingController(text: clinic?.name);
    final locationController = TextEditingController(text: clinic?.location);
    final descController = TextEditingController(text: clinic?.description);
    final capacityController = TextEditingController(text: clinic?.capacity.toString() ?? '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(clinic == null ? 'Nova Clínica' : 'Editar Clínica'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome da Clínica'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Localização/Bloco'),
              ),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacidade (Cadeiras)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (clinic == null) {
                ref.read(clinicsViewModelProvider.notifier).addClinic(
                  name: nameController.text,
                  location: locationController.text,
                  description: descController.text,
                  capacity: int.tryParse(capacityController.text) ?? 1,
                );
              } else {
                ref.read(clinicsViewModelProvider.notifier).saveClinic(clinic.copyWith(
                  name: nameController.text,
                  location: locationController.text,
                  description: descController.text,
                  capacity: int.tryParse(capacityController.text) ?? 1,
                ));
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
