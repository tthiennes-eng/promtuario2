import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:promt/features/prontuario/domain/entities/treatment_plan.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/treatment_plan_viewmodel.dart';

class TreatmentPlanScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const TreatmentPlanScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  ConsumerState<TreatmentPlanScreen> createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends ConsumerState<TreatmentPlanScreen> {
  bool _isSaving = false;

  Future<void> _showAddProcedureDialog() async {
    String? selectedProcedure;
    int? toothNumber;
    final obsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Novo Procedimento Acadêmico'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Procedimento', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Limpeza', child: Text('Limpeza / Profilaxia')),
                    DropdownMenuItem(value: 'Restauração', child: Text('Restauração')),
                    DropdownMenuItem(value: 'Endodontia', child: Text('Tratamento de Canal')),
                    DropdownMenuItem(value: 'Extração', child: Text('Exodontia')),
                    DropdownMenuItem(value: 'Avaliação', child: Text('Avaliação Clínica')),
                  ],
                  onChanged: (v) => selectedProcedure = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Dente (Elemento)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => toothNumber = int.tryParse(v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: obsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Observações Técnicas', 
                    hintText: 'Descreva a necessidade do procedimento...',
                    border: OutlineInputBorder()
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: _isSaving ? null : () async {
                if (selectedProcedure != null) {
                  setDialogState(() => _isSaving = true);
                  try {
                    final newItem = TreatmentItem(
                      id: const Uuid().v4(),
                      procedureId: const Uuid().v4(),
                      procedureName: selectedProcedure!,
                      toothNumber: toothNumber,
                      observation: obsController.text,
                      status: TreatmentItemStatus.pending,
                    );
                    await ref.read(treatmentPlanViewModelProvider(widget.patientId).notifier).addItem(newItem);
                    if (mounted) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Procedimento salvo com sucesso!'), backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar: ${e.toString()}'), backgroundColor: Colors.red),
                    );
                  } finally {
                    setDialogState(() => _isSaving = false);
                  }
                }
              },
              child: _isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Adicionar ao Plano'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(treatmentPlanViewModelProvider(widget.patientId));

    return Scaffold(
      appBar: AppBar(title: const Text('Plano de Tratamento')),
      body: planAsync.when(
        data: (plans) {
          if (plans.isEmpty) return _buildEmptyState();
          final plan = plans.first;
          return Column(
            children: [
              _buildPlanHeader(plan),
              Expanded(child: _buildItemsList(plan.items)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro ao carregar plano: ${err.toString()}')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Nenhum planejamento registrado.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _showAddProcedureDialog,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Procedimento'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHeader(TreatmentPlan plan) {
    return ListTile(
      tileColor: Colors.blue.withOpacity(0.05),
      title: Text('Paciente: ${widget.patientName}', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Status do Plano: ${plan.status.name.toUpperCase()}'),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
        onPressed: _showAddProcedureDialog,
        tooltip: 'Adicionar',
      ),
    );
  }

  Widget _buildItemsList(List<TreatmentItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: item.toothNumber != null ? CircleAvatar(child: Text(item.toothNumber.toString())) : const Icon(Icons.medical_services),
            title: Text(item.procedureName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: (item.observation != null && item.observation!.isNotEmpty) 
                ? Text(item.observation!) 
                : const Text('Sem observações registradas.'),
            trailing: _buildStatusIcon(item.status),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(TreatmentItemStatus status) {
    return switch (status) {
      TreatmentItemStatus.pending => const Icon(Icons.hourglass_empty, color: Colors.orange),
      TreatmentItemStatus.inProgress => const Icon(Icons.pending, color: Colors.blue),
      TreatmentItemStatus.completed => const Icon(Icons.check_circle, color: Colors.green),
      TreatmentItemStatus.cancelled => const Icon(Icons.cancel, color: Colors.red),
    };
  }
}
