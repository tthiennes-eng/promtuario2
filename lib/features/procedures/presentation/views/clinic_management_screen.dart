import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/auth/domain/entities/user.dart';
import 'package:promt/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:promt/features/procedures/presentation/viewmodels/clinics_viewmodel.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';

class ClinicManagementScreen extends ConsumerWidget {
  const ClinicManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsync = ref.watch(clinicsViewModelProvider);
    final isAdmin = ref.watch(authViewModelProvider).user?.role == UserRole.admin;

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
            final startHour = clinic.startHourSafe;
            final endHour = clinic.endHourSafe;
            final slotDuration = clinic.slotDurationMinutesSafe;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: clinic.isActive ? const Color(0xFF006494).withValues(alpha: 0.1) : Colors.grey.shade100,
                  child: Icon(
                    Icons.business,
                    color: clinic.isActive ? const Color(0xFF006494) : Colors.grey,
                  ),
                ),
                title: Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${clinic.location.isNotEmpty ? clinic.location : "Sem local"} • ${clinic.capacity} consultórios'),
                    Text('Funcionamento: ${startHour}h às ${endHour}h • Slots: ${slotDuration}min',
                      style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  ],
                ),
                trailing: Switch(
                  value: clinic.isActive,
                  onChanged: (val) async {
                    try {
                      await ref.read(clinicsViewModelProvider.notifier).toggleClinicStatus(clinic);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao alterar status da clínica: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
                onTap: () => _showEditClinicDialog(context, ref, clinic),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showEditClinicDialog(context, ref, null),
              label: const Text('Cadastrar Clínica'),
              icon: const Icon(Icons.add_business),
            )
          : null,
    );
  }

  void _showEditClinicDialog(BuildContext context, WidgetRef ref, Clinic? clinic) {
    final nameController = TextEditingController(text: clinic?.name);
    final locationController = TextEditingController(text: clinic?.location);
    final descController = TextEditingController(text: clinic?.description);
    final capacityController = TextEditingController(text: clinic?.capacity.toString() ?? '1');
    
    // Acesso seguro para os campos de texto do diálogo
    final startHour = clinic?.startHourSafe ?? 8;
    final endHour = clinic?.endHourSafe ?? 18;
    final slotDuration = clinic?.slotDurationMinutesSafe ?? 60;

    final startController = TextEditingController(text: startHour.toString());
    final endController = TextEditingController(text: endHour.toString());
    final slotController = TextEditingController(text: slotDuration.toString());

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
                decoration: const InputDecoration(labelText: 'Nome da Clínica', border: OutlineInputBorder()),
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
            onPressed: () async {
              final trimmedName = nameController.text.trim();
              final parsedStart = int.tryParse(startController.text) ?? 8;
              final parsedEnd = int.tryParse(endController.text) ?? 18;
              if (trimmedName.length < 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Informe um nome de clínica com pelo menos 3 caracteres.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (parsedStart < 0 || parsedStart > 23 || parsedEnd < 0 || parsedEnd > 23 || parsedEnd <= parsedStart) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Horários inválidos: a hora fim deve ser maior que a hora início (0 a 23).'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newClinic = Clinic(
                id: clinic?.id ?? '',
                name: trimmedName,
                location: locationController.text.trim(),
                description: descController.text.trim(),
                capacity: (int.tryParse(capacityController.text) ?? 1).clamp(1, 500),
                startHour: parsedStart,
                endHour: parsedEnd,
                slotDurationMinutes: (int.tryParse(slotController.text) ?? 60).clamp(10, 240),
                isActive: clinic?.isActive ?? true,
                metadata: clinic?.metadata ?? {},
              );

              try {
                await ref.read(clinicsViewModelProvider.notifier).saveClinic(newClinic);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Clínica salva com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao salvar clínica: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Salvar Alterações'),
          ),
        ],
      ),
    );
  }
}
