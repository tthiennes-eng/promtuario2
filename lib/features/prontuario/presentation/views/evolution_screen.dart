import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/evolution_viewmodel.dart';
import '../viewmodels/prontuario_summary_provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../users/presentation/viewmodels/user_management_viewmodel.dart';
import '../../../procedures/presentation/viewmodels/clinics_viewmodel.dart';
import '../../../auth/domain/entities/user.dart';

class EvolutionScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;
  final String? initialDescription;

  const EvolutionScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    this.initialDescription,
  });

  @override
  ConsumerState<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends ConsumerState<EvolutionScreen> {
  static const _templates = <String, String>{
    'SOAP': 'S (Subjetivo): Paciente relata...\nO (Objetivo): Ao exame clínico observou-se...\nA (Avaliação): Diagnóstico / evolução...\nP (Plano): Procedimento realizado e conduta para próxima sessão...',
    'Restauração': 'Realizada profilaxia prévia, anestesia infiltrativa, isolamento absoluto, remoção de tecido cariado, condicionamento ácido, aplicação de adesivo e restauração em resina composta. Ajuste oclusal e polimento realizados.',
    'Endodontia': 'Anestesia local, isolamento absoluto, acesso coronário, odontometria, preparo químico-mecânico com hipoclorito de sódio, medicação intracanal e selamento provisório. Paciente orientado quanto aos cuidados.',
    'Periodontia': 'Realizada raspagem e alisamento radicular supragengival/subgengival, profilaxia com pasta profilática e orientação de higiene oral (técnica de Bass modificada e uso de fio dental).',
    'Exodontia': 'Anestesia infiltrativa/bloqueio regional, sindesmotomia, luxação e exodontia sem intercorrências, curetagem alveolar, irrigação com soro fisiológico e sutura simples. Orientações pós-operatórias entregues.',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialDescription != null && widget.initialDescription!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showAddEvolutionDialog(initialText: widget.initialDescription);
        }
      });
    }
  }

  bool _canSign(User? user) {
    if (user == null) return false;
    return user.role == UserRole.professor ||
        user.role == UserRole.admin ||
        user.role == UserRole.coordenador;
  }

  @override
  Widget build(BuildContext context) {
    final evolutionsAsync = ref.watch(evolutionViewModelProvider(widget.patientId));
    final currentUser = ref.watch(authViewModelProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Evolução Clínica'),
            Text(widget.patientName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(evolutionViewModelProvider(widget.patientId).notifier).refresh(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: evolutionsAsync.when(
          data: (evolutions) => evolutions.isEmpty
              ? const Center(child: Text('Nenhuma evolução clínica registrada.'))
              : ListView.builder(
                  itemCount: evolutions.length,
                  itemBuilder: (context, index) {
                    final evolution = evolutions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${DateFormat('dd/MM/yyyy HH:mm').format(evolution.createdAt)} • ${evolution.clinicName ?? "Clínica Geral"}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _buildStatusTag(evolution.isSignedByProfessor),
                              ],
                            ),
                            const Divider(),
                            Text(evolution.description, style: const TextStyle(height: 1.4)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 14, color: Colors.blueGrey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Prof: ${evolution.professorName ?? "Não inf."}',
                                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                                  ),
                                ),
                                Text(
                                  'Aluno: ${evolution.studentName ?? "Não inf."}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            if (evolution.isSignedByProfessor && evolution.signedAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Assinado digitalmente em ${DateFormat('dd/MM/yyyy HH:mm').format(evolution.signedAt!)}',
                                  style: TextStyle(fontSize: 11, color: Colors.green.shade800, fontWeight: FontWeight.w500),
                                ),
                              ),
                            if (!evolution.isSignedByProfessor && _canSign(currentUser))
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(evolutionViewModelProvider(widget.patientId).notifier)
                                          .signEvolution(evolution.id);
                                      ref.invalidate(prontuarioSummaryProvider(widget.patientId));
                                      ref.invalidate(clinicalTimelineProvider(widget.patientId));
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Evolução assinada digitalmente!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Erro ao assinar: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.verified_user_outlined),
                                  label: const Text('Assinar Evolução'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF006494),
                                    minimumSize: const Size(double.infinity, 40),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Erro ao carregar histórico: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF006494),
        onPressed: () => _showAddEvolutionDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Evolução', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatusTag(bool signed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: signed ? Colors.green.withValues(alpha: 0.12) : Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        signed ? 'Assinado' : 'Pendente',
        style: TextStyle(
          color: signed ? Colors.green.shade800 : Colors.orange.shade900,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddEvolutionDialog({String? initialText}) {
    final controller = TextEditingController(text: initialText ?? '');
    String? selectedProfessorId;
    String? selectedClinicId;
    bool isSubmitting = false;

    final usersAsync = ref.read(userManagementViewModelProvider);
    final clinics = ref.read(clinicsViewModelProvider).valueOrNull ?? const [];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nova Evolução Clínica'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (clinics.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      initialValue: selectedClinicId,
                      decoration: const InputDecoration(
                        labelText: 'Clínica do Atendimento',
                        border: OutlineInputBorder(),
                      ),
                      items: clinics
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (val) => setDialogState(() => selectedClinicId = val),
                    ),
                    const SizedBox(height: 12),
                  ],
                  usersAsync.when(
                    data: (users) {
                      final supervisors = users
                          .where((u) =>
                              u.role == UserRole.professor ||
                              u.role == UserRole.admin ||
                              u.role == UserRole.coordenador)
                          .toList();
                      return DropdownButtonFormField<String>(
                        initialValue: selectedProfessorId,
                        decoration: const InputDecoration(
                          labelText: 'Professor Supervisor',
                          border: OutlineInputBorder(),
                        ),
                        items: supervisors
                            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                            .toList(),
                        onChanged: (val) => setDialogState(() => selectedProfessorId = val),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Não foi possível carregar supervisores'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Modelos Rápidos',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF006494)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _templates.entries.map((entry) {
                      return ActionChip(
                        label: Text(entry.key, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          controller.text = entry.value;
                          setDialogState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Descrição Clínica',
                      hintText: 'Descreva detalhadamente o atendimento realizado...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          StatefulBuilder(
            builder: (context, setBtnState) => FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (controller.text.trim().isEmpty) return;
                      setBtnState(() => isSubmitting = true);
                      try {
                        await ref
                            .read(evolutionViewModelProvider(widget.patientId).notifier)
                            .addEvolution(
                              controller.text.trim(),
                              selectedProfessorId ?? '',
                              clinicId: selectedClinicId,
                            );
                        ref.invalidate(prontuarioSummaryProvider(widget.patientId));
                        ref.invalidate(clinicalTimelineProvider(widget.patientId));
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } catch (e) {
                        setBtnState(() => isSubmitting = false);
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text('Erro ao salvar evolução: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Registrar'),
            ),
          ),
        ],
      ),
    );
  }
}
