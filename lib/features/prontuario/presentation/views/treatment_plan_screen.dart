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
  void _showAddProcedureDialog() {
    String? selectedProcedure;
    int? toothNumber;
    double value = 0.0;
    final obsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Procedimento'),
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Valor (R$)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (v) => value = double.tryParse(v) ?? 0.0,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: obsController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Observações / Detalhes', border: OutlineInputBorder()),
              ),
            ],
          ),
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
                  observation: obsController.text,
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
      floatingActionButton: planAsync.maybeWhen(
        data: (plans) => plans.isNotEmpty ? FloatingActionButton.extended(
          onPressed: _showAddProcedureDialog,
          label: const Text('Novo Procedimento'),
          icon: const Icon(Icons.add),
        ) : null,
        orElse: () => null,
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
          const Text('Nenhum plano para este paciente.', style: TextStyle(color: Colors.grey)),
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
    );
  }

  Widget _buildItemsList(List<TreatmentItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return ListTile(
          title: Text(item.procedureName),
          subtitle: item.observation != null ? Text(item.observation!) : null,
          trailing: Text('R$ ${item.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          leading: item.toothNumber != null ? CircleAvatar(child: Text(item.toothNumber.toString())) : const Icon(Icons.medical_services_outlined),
        );
      },
    );
  }

  Widget _buildFooter(TreatmentPlan plan) {
    final total = plan.items.fold<double>(0, (sum, item) => sum + item.value);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Estimado:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('R$ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }
}
