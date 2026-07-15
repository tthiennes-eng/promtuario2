import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/prescription.dart';
import '../viewmodels/documents_viewmodel.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class PrescriptionScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PrescriptionScreen({super.key, required this.patientId});

  @override
  ConsumerState<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends ConsumerState<PrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<PrescriptionItem> _items = [];
  final _observationsController = TextEditingController();

  final _medicineController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  void _addItem() {
    if (_medicineController.text.isNotEmpty && _dosageController.text.isNotEmpty) {
      setState(() {
        _items.add(PrescriptionItem(
          medicineName: _medicineController.text,
          dosage: _dosageController.text,
          instructions: _instructionsController.text,
        ));
        _medicineController.clear();
        _dosageController.clear();
        _instructionsController.clear();
      });
    }
  }

  void _submit() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um medicamento.')),
      );
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final user = authState.user;

    if (user == null) return;

    final prescription = Prescription(
      id: const Uuid().v4(),
      patientId: widget.patientId,
      doctorId: user.id,
      doctorName: user.name,
      date: DateTime.now(),
      items: List.from(_items),
      observations: _observationsController.text,
      clinicId: const Uuid().v4(), // Seria obtido do contexto da clínica
    );

    ref.read(documentsViewModelProvider(widget.patientId).notifier)
       .emitPrescription(prescription)
       .then((_) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receita emitida com sucesso!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emitir Receita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Medicamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _medicineController,
                        decoration: const InputDecoration(labelText: 'Medicamento'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dosageController,
                              decoration: const InputDecoration(labelText: 'Dosagem'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _instructionsController,
                              decoration: const InputDecoration(labelText: 'Instruções'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Item'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_items.isNotEmpty) ...[
                const Text('Itens da Receita', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      title: Text(item.medicineName),
                      subtitle: Text('${item.dosage} - ${item.instructions}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => setState(() => _items.removeAt(index)),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),
              TextFormField(
                controller: _observationsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações Adicionais',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('Gerar Receita PDF & Salvar', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
