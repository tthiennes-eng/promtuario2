import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/prescription.dart';
import '../../data/services/prontuario_pdf_service.dart';
import '../viewmodels/documents_viewmodel.dart';
import '../viewmodels/endodontia_viewmodel.dart';
import '../viewmodels/prontuario_summary_provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../procedures/presentation/viewmodels/clinics_viewmodel.dart';

class PrescriptionScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const PrescriptionScreen({
    super.key,
    required this.patientId,
    this.patientName = 'Paciente',
  });

  @override
  ConsumerState<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends ConsumerState<PrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<PrescriptionItem> _items = [];
  final _observationsController = TextEditingController();
  bool _isSaving = false;
  String? _selectedClinicId;
  String? _selectedClinicName;

  final _medicineController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  static const _templates = <PrescriptionItem>[
    PrescriptionItem(
      medicineName: 'Amoxicilina 500mg',
      dosage: '1 cápsula de 8/8h por 7 dias',
      instructions: 'Uso oral. Tomar rigorosamente nos horários indicados.',
    ),
    PrescriptionItem(
      medicineName: 'Ibuprofeno 600mg',
      dosage: '1 comprimido de 8/8h por 3 dias',
      instructions: 'Uso oral, preferencialmente após as refeições.',
    ),
    PrescriptionItem(
      medicineName: 'Dipirona Sódica 500mg',
      dosage: '1 comprimido de 6/6h se dor',
      instructions: 'Uso oral em caso de dor ou febre.',
    ),
    PrescriptionItem(
      medicineName: 'Paracetamol 750mg',
      dosage: '1 comprimido de 8/8h se dor',
      instructions: 'Uso oral. Não exceder 4 comprimidos ao dia.',
    ),
    PrescriptionItem(
      medicineName: 'Digluconato de Clorexidina 0,12%',
      dosage: 'Bochechar 15ml por 1 min, 2x ao dia por 7 dias',
      instructions: 'Uso tópico (bochecho). Não ingerir. Aguardar 30 min após escovação.',
    ),
  ];

  @override
  void dispose() {
    _observationsController.dispose();
    _medicineController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  String _extractAllergy(Map<String, dynamic>? anamnese) {
    final sistemico = anamnese?['sistemico'];
    if (sistemico is! Map) return '';
    final alergia = sistemico['alergia'];
    if (alergia is Map && alergia['sim'] == true) {
      return (alergia['qual'] ?? '').toString().trim();
    }
    return '';
  }

  bool _matchesAllergy(String medicine, String allergyText) {
    if (allergyText.isEmpty || medicine.trim().isEmpty) return false;
    final medLower = medicine.toLowerCase();
    final tokens = allergyText
        .toLowerCase()
        .split(RegExp(r'[,;/\s]+'))
        .where((t) => t.length >= 3);
    for (final token in tokens) {
      if (medLower.contains(token)) return true;
      if (token.contains('penicil') && medLower.contains('amoxicil')) return true;
    }
    return false;
  }

  void _addItem({PrescriptionItem? template}) {
    final item = template ??
        (_medicineController.text.trim().isNotEmpty &&
                _dosageController.text.trim().isNotEmpty
            ? PrescriptionItem(
                medicineName: _medicineController.text.trim(),
                dosage: _dosageController.text.trim(),
                instructions: _instructionsController.text.trim(),
              )
            : null);
    if (item == null) return;

    setState(() {
      _items.add(item);
      if (template == null) {
        _medicineController.clear();
        _dosageController.clear();
        _instructionsController.clear();
      }
    });
  }

  Future<void> _exportPdf(Prescription prescription) async {
    try {
      final file = await ProntuarioPdfService.generatePrescriptionPdf(
        patientName: widget.patientName,
        prescription: prescription,
        clinicName: _selectedClinicName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF da receita salvo em: ${file.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submit(String allergyText) async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um medicamento.')),
      );
      return;
    }

    final conflicting = _items
        .where((i) => _matchesAllergy(i.medicineName, allergyText))
        .map((i) => i.medicineName)
        .toList();
    if (conflicting.isNotEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Alerta de Alergia!'),
          content: Text(
            'O paciente relatou alergia a "$allergyText".\n'
            'Possível conflito com: ${conflicting.join(", ")}.\n\n'
            'Deseja realmente emitir esta receita?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Revisar')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Emitir mesmo assim'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final authState = ref.read(authViewModelProvider);
    final user = authState.user;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final prescription = Prescription(
        id: const Uuid().v4(),
        patientId: widget.patientId,
        clinicId: _selectedClinicId ?? '00000000-0000-0000-0000-000000000000',
        items: List.from(_items),
        doctorId: user.id,
        doctorName: user.name,
        observations: _observationsController.text.trim(),
        date: DateTime.now(),
      );

      await ref
          .read(documentsViewModelProvider(widget.patientId).notifier)
          .emitPrescription(prescription);
      ref.invalidate(prontuarioSummaryProvider(widget.patientId));
      ref.invalidate(clinicalTimelineProvider(widget.patientId));

      if (mounted) {
        setState(() {
          _items.clear();
          _observationsController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receita emitida e salva no histórico!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final anamneseData = ref.watch(endodontiaViewModelProvider('anamnese_${widget.patientId}')).valueOrNull;
    final allergyText = _extractAllergy(anamneseData);
    final clinics = ref.watch(clinicsViewModelProvider).valueOrNull ?? const [];
    final docsAsync = ref.watch(documentsViewModelProvider(widget.patientId));

    final hasLiveConflict = _matchesAllergy(_medicineController.text, allergyText) ||
        _items.any((i) => _matchesAllergy(i.medicineName, allergyText));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emitir Receita'),
            Text(widget.patientName, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (allergyText.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: hasLiveConflict ? Colors.red.shade100 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade400, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade900),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hasLiveConflict
                              ? 'ATENÇÃO: Possível alergia detectada! Paciente alérgico a: $allergyText'
                              : 'ALERTA DE ALERGIA (Anamnese): $allergyText',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (clinics.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedClinicId,
                  decoration: const InputDecoration(
                    labelText: 'Clínica de Emissão',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_hospital_outlined),
                  ),
                  items: clinics
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedClinicId = val;
                      _selectedClinicName = clinics
                          .where((c) => c.id == val)
                          .map((c) => c.name)
                          .firstOrNull;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              const Text('Protocolos Rápidos', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006494))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _templates
                    .map(
                      (tpl) => ActionChip(
                        avatar: const Icon(Icons.medication_outlined, size: 16),
                        label: Text(tpl.medicineName),
                        onPressed: () => _addItem(template: tpl),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _medicineController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Medicamento',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dosageController,
                              decoration: const InputDecoration(
                                labelText: 'Dosagem / Posologia',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _instructionsController,
                              decoration: const InputDecoration(
                                labelText: 'Instruções de Uso',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () => _addItem(),
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Item'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_items.isNotEmpty) ...[
                const Text('Itens da Receita Atual', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Card(
                    child: ListTile(
                      title: Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.dosage}${item.instructions.isNotEmpty ? " • ${item.instructions}" : ""}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => setState(() => _items.removeAt(idx)),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _observationsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações / Recomendações Gerais',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isSaving ? null : () => _submit(allergyText),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Salvar e Emitir Receita'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF006494),
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Histórico de Receitas Emitidas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              docsAsync.when(
                data: (docs) {
                  final prescriptions = docs.whereType<Prescription>().toList();
                  if (prescriptions.isEmpty) {
                    return const Text(
                      'Nenhuma receita emitida anteriormente para este paciente.',
                      style: TextStyle(color: Colors.grey),
                    );
                  }
                  return Column(
                    children: prescriptions.map((rx) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${DateFormat('dd/MM/yyyy HH:mm').format(rx.createdAt)} • ${rx.doctorName}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _exportPdf(rx),
                                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                                    label: const Text('PDF'),
                                  ),
                                ],
                              ),
                              const Divider(),
                              ...rx.items.map((i) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text('• ${i.medicineName} — ${i.dosage}'),
                                  )),
                              if (rx.observations != null && rx.observations!.isNotEmpty)
                                Text(
                                  'Obs: ${rx.observations}',
                                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Erro ao carregar histórico: $err'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
