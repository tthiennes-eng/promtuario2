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
        title: const Text('Configuração de Unidades/Clínicas'),
      ),
      body: clinicsAsync.when(
        data: (clinics) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clinics.length,
          itemBuilder: (context, index) {
            final clinic = clinics[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: clinic.isActive ? const Color(0xFF006494).withOpacity(0.1) : Colors.grey.shade100,
                  child: Icon(
                    Icons.business,
                    color: clinic.isActive ? const Color(0xFF006494) : Colors.grey,
                  ),
                ),
                title: Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${clinic.location ?? "Sem local"} • ${clinic.capacity} consultórios'),
                    Text('Funcionamento: ${clinic.startHour}h às ${clinic.endHour}h • Slots: ${clinic.slotDurationMinutes}min', 
                      style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  ],
                ),
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
        label: const Text('Cadastrar Clínica'),
        icon: const Icon(Icons.add_business),
      ),
    );
  }

  void _showEditClinicDialog(BuildContext context, WidgetRef ref, Clinic? clinic) {
    final nameController = TextEditingController(text: clinic?.name);
    final locationController = TextEditingController(text: clinic?.location);
    final descController = TextEditingController(text: clinic?.description);
    final capacityController = TextEditingController(text: clinic?.capacity.toString() ?? '1');
    final startController = TextEditingController(text: clinic?.startHour.toString() ?? '8');
    final endController = TextEditingController(text: clinic?.endHour.toString() ?? '18');
    final slotController = TextEditingController(text: clinic?.slotDurationMinutes.toString() ?? '60');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(clinic == null ? 'Nova Clínica Escola' : 'Editar Parâmetros da Clínica'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome da Clínica (Ex: Clínica Integrada I)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Localização/Bloco', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: capacityController,
                      decoration: const InputDecoration(labelText: 'Cadeiras', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: slotController,
                      decoration: const InputDecoration(labelText: 'Duração (min)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startController,
                      decoration: const InputDecoration(labelText: 'Hora Início', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      decoration: const InputDecoration(labelText: 'Hora Fim', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Observações Administrativas', border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final newClinic = Clinic(
                id: clinic?.id ?? '', // Será gerado no VM se vazio
                name: nameController.text,
                location: locationController.text,
                description: descController.text,
                capacity: int.tryParse(capacityController.text) ?? 1,
                startHour: int.tryParse(startController.text) ?? 8,
                endHour: int.tryParse(endController.text) ?? 18,
                slotDurationMinutes: int.tryParse(slotController.text) ?? 60,
                isActive: clinic?.isActive ?? true,
                metadata: clinic?.metadata ?? {},
              );

              if (clinic == null) {
                ref.read(clinicsViewModelProvider.notifier).saveClinic(newClinic);
              } else {
                ref.read(clinicsViewModelProvider.notifier).saveClinic(newClinic);
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar Alterações'),
          ),
        ],
      ),
    );
  }
}
