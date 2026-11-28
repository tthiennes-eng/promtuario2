import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/prescription.dart';
import '../../data/services/prontuario_pdf_service.dart';
import '../viewmodels/documents_viewmodel.dart';
import '../viewmodels/prontuario_summary_provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class CertificateScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const CertificateScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _daysController = TextEditingController(text: '1');
  final _cidController = TextEditingController();
  bool _isSaving = false;
  String _lastAutoText = '';

  @override
  void initState() {
    super.initState();
    _syncDefaultText('1', force: true);
  }

  void _syncDefaultText(String days, {bool force = false}) {
    final safeDays = days.trim().isEmpty ? '1' : days.trim();
    final generated =
        'Atesto para os devidos fins que o(a) Sr(a). ${widget.patientName} foi submetido(a) a tratamento odontológico nesta data, necessitando de $safeDays dia(s) de repouso.';
    if (force || _contentController.text.isEmpty || _contentController.text == _lastAutoText) {
      _contentController.text = generated;
    }
    _lastAutoText = generated;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _daysController.dispose();
    _cidController.dispose();
    super.dispose();
  }

  Future<void> _exportPdf(MedicalCertificate cert) async {
    try {
      final file = await ProntuarioPdfService.generateCertificatePdf(
        patientName: widget.patientName,
        certificate: cert,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF do atestado salvo em: ${file.path}'),
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authState = ref.read(authViewModelProvider);
      final user = authState.user;
      if (user == null) return;

      setState(() => _isSaving = true);

      try {
        final certificate = MedicalCertificate(
          id: const Uuid().v4(),
          patientId: widget.patientId,
          doctorId: user.id,
          doctorName: user.name,
          content: _contentController.text.trim(),
          daysOfRest: int.tryParse(_daysController.text.trim()) ?? 1,
          cid: _cidController.text.trim(),
          date: DateTime.now(),
        );

        await ref
            .read(documentsViewModelProvider(widget.patientId).notifier)
            .emitCertificate(certificate);
        ref.invalidate(prontuarioSummaryProvider(widget.patientId));
        ref.invalidate(clinicalTimelineProvider(widget.patientId));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Atestado emitido e salvo com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao emitir atestado: ${e.toString().replaceFirst("Exception: ", "")}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentsViewModelProvider(widget.patientId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emitir Atestado'),
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
              Text('Paciente: ${widget.patientName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Texto do Atestado',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      onChanged: _syncDefaultText,
                      decoration: const InputDecoration(
                        labelText: 'Dias de Repouso',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cidController,
                      decoration: const InputDecoration(
                        labelText: 'CID-10 (Opcional)',
                        hintText: 'Ex.: K04.0',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Gerar e Salvar Atestado'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF006494),
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Histórico de Atestados Emitidos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              docsAsync.when(
                data: (docs) {
                  final certs = docs.whereType<MedicalCertificate>().toList();
                  if (certs.isEmpty) {
                    return const Text(
                      'Nenhum atestado emitido anteriormente para este paciente.',
                      style: TextStyle(color: Colors.grey),
                    );
                  }
                  return Column(
                    children: certs.map((c) {
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
                                    '${DateFormat('dd/MM/yyyy HH:mm').format(c.createdAt)} • ${c.daysOfRest} dia(s)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _exportPdf(c),
                                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                                    label: const Text('PDF'),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Text(c.content),
                              if (c.cid != null && c.cid!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text('CID: ${c.cid}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
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
