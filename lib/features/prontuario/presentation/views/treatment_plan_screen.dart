import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:promt/features/prontuario/domain/entities/treatment_plan.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/treatment_plan_viewmodel.dart';
import 'package:promt/features/auth/domain/entities/user.dart';
import 'package:promt/features/auth/presentation/viewmodels/auth_viewmodel.dart';

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
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddProcedureDialog() {
    String? selectedProcedure;
    int? toothNumber;
    double value = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar Procedimento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Procedimento'),
                items: const [
                  DropdownMenuItem(value: 'Limpeza', child: Text('Limpeza / Profilaxia')),
                  DropdownMenuItem(value: 'Restauração', child: Text('Restauração')),
                  DropdownMenuItem(value: 'Endodontia', child: Text('Tratamento de Canal')),
                  DropdownMenuItem(value: 'Extração', child: Text('Exodontia')),
                ],
                onChanged: (v) => selectedProcedure = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Elemento (Opcional)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => toothNumber = int.tryParse(v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Valor sugerido (R\$)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => value = double.tryParse(v) ?? 0.0,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (selectedProcedure != null) {
                  final newItem = TreatmentItem(
                    id: const Uuid().v4(),
                    procedureId: const Uuid().v4(),
                    procedureName: selectedProcedure!,
                    value: value,
                    toothNumber: toothNumber,
                    status: TreatmentItemStatus.pending,
                  );
                  ref.read(treatmentPlanViewModelProvider(widget.patientId).notifier).addItem(newItem);
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
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
              _buildFooter(plan),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProcedureDialog,
        label: const Text('Adicionar Procedimento'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FilledButton(
        onPressed: _createNewPlan,
        child: const Text('Criar Novo Plano'),
      ),
    );
  }

  void _createNewPlan() {
    final authState = ref.read(authViewModelProvider);
    final newPlan = TreatmentPlan(
      id: const Uuid().v4(),
      patientId: widget.patientId,
      description: 'Plano inicial',
      items: [],
      createdByUserId: authState.user?.id ?? 'system',
      status: TreatmentPlanStatus.draft,
      createdAt: DateTime.now(),
    );
    ref.read(treatmentPlanViewModelProvider(widget.patientId).notifier).savePlan(newPlan);
  }

  Widget _buildPlanHeader(TreatmentPlan plan) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      title: Text('Status: ${plan.status.name.toUpperCase()}'),
      subtitle: Text('Paciente: ${widget.patientName}'),
    );
  }

  Widget _buildItemsList(List<TreatmentItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) => ListTile(
        title: Text(items[i].procedureName),
        trailing: Text('R\$ ${items[i].value.toStringAsFixed(2)}'),
      ),
    );
  }

  Widget _buildFooter(TreatmentPlan plan) {
    final total = plan.items.fold<double>(0, (sum, item) => sum + item.value);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text('Total: R\$ ${total.toStringAsFixed(2)}', 
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}
