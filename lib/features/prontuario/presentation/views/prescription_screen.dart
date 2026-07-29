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
  bool _isSaving = false;

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

  Future<void> _submit() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um medicamento.')),
      );
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final user = authState.user;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final prescription = Prescription(
        id: const Uuid().v4(),
        patientId: widget.patientId,
        doctorId: user.id,
        doctorName: user.name,
        date: DateTime.now(),
        items: List.from(_items),
        observations: _observationsController.text,
        clinicId: '00000000-0000-0000-0000-000000000000', // Valor zerado compatível com o Backend
      );

      await ref.read(documentsViewModelProvider(widget.patientId).notifier)
         .emitPrescription(prescription);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receita salva com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emitir Receita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Novo Item', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(controller: _medicineController, decoration: const InputDecoration(labelText: 'Medicamento')),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _dosageController, decoration: const InputDecoration(labelText: 'Posologia'))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: _instructionsController, decoration: const InputDecoration(labelText: 'Instruções'))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Inserir na Receita')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_items.isNotEmpty) ...[
                const Text('Medicamentos Prescritos', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._items.asMap().entries.map((entry) => Card(
                  child: ListTile(
                    title: Text(entry.value.medicineName),
                    subtitle: Text('${entry.value.dosage} - ${entry.value.instructions}'),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => setState(() => _items.removeAt(entry.key))),
                  ),
                )),
              ],
              const SizedBox(height: 24),
              TextFormField(
                controller: _observationsController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Orientações Adicionais', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: _isSaving ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Salvar Prescrição', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
