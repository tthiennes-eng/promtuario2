import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/prescription.dart';
import '../viewmodels/documents_viewmodel.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

/// Tela para emissão de Atestados Médicos/Odontológicos.
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

  @override
  void initState() {
    super.initState();
    _contentController.text =
        'Atesto para os devidos fins que o(a) Sr(a). ${widget.patientName} foi submetido(a) a tratamento odontológico nesta data, necessitando de _____ dia(s) de repouso.';
  }

  @override
  void dispose() {
    _contentController.dispose();
    _daysController.dispose();
    _cidController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final authState = ref.read(authViewModelProvider);
      final user = authState.user;
      if (user == null) return;

      final certificate = MedicalCertificate(
        id: const Uuid().v4(),
        patientId: widget.patientId,
        doctorId: user.id,
        doctorName: user.name,
        date: DateTime.now(),
        content: _contentController.text,
        daysOfRest: int.parse(_daysController.text),
        cid: _cidController.text,
        clinicId: const Uuid().v4(), // Mock
      );

      ref
          .read(documentsViewModelProvider(widget.patientId).notifier)
          .emitCertificate(certificate)
          .then((_) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atestado emitido com sucesso!')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emitir Atestado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paciente: ${widget.patientName}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Texto do Atestado',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Dias de Repouso',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cidController,
                      decoration: const InputDecoration(
                        labelText: 'CID (Opcional)',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.print),
                label: const Text('Gerar e Assinar Atestado'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
