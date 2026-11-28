import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:promt/features/auth/domain/entities/user.dart';
import 'package:promt/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:promt/features/procedures/presentation/viewmodels/procedures_viewmodel.dart';
import 'package:promt/features/prontuario/data/services/prontuario_pdf_service.dart';
import 'package:promt/features/prontuario/domain/entities/treatment_plan.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/prontuario_summary_provider.dart';
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
  static const List<String> _defaultProcedures = [
    'Avaliação Clínica',
    'Profilaxia (Limpeza)',
    'Restauração de Resina',
    'Tratamento Endodôntico (Canal)',
    'Exodontia Simples',
    'Exodontia de Terceiro Molar',
    'Raspagem Periodontal',
    'Aplicação de Flúor',
    'Radiografia Periapical',
    'Prótese Total',
    'Prótese Parcial Removível (PPR)',
    'Cirurgia Periodontal',
    'Urgência / Emergência',
  ];

  bool _isSaving = false;

  String _itemStatusLabel(TreatmentItemStatus status) {
    return switch (status) {
      TreatmentItemStatus.pending => 'Pendente',
      TreatmentItemStatus.inProgress => 'Em andamento',
      TreatmentItemStatus.completed => 'Concluído',
      TreatmentItemStatus.canceled => 'Cancelado',
    };
  }

  Color _itemStatusColor(TreatmentItemStatus status) {
    return switch (status) {
      TreatmentItemStatus.pending => Colors.orange.shade800,
      TreatmentItemStatus.inProgress => Colors.blue.shade700,
      TreatmentItemStatus.completed => Colors.green.shade700,
      TreatmentItemStatus.canceled => Colors.grey.shade600,
    };
  }

  String _planStatusLabel(TreatmentPlanStatus status) {
    return switch (status) {
      TreatmentPlanStatus.draft => 'Rascunho (aguardando aprovação)',
      TreatmentPlanStatus.approved => 'Aprovado pelo Professor',
      TreatmentPlanStatus.inProgress => 'Em Andamento',
      TreatmentPlanStatus.active => 'Ativo',
      TreatmentPlanStatus.completed => 'Concluído',
      TreatmentPlanStatus.canceled => 'Cancelado',
    };
  }

  bool _canApprove(User? user) {
    if (user == null) return false;
    return user.role == UserRole.professor ||
        user.role == UserRole.admin ||
        user.role == UserRole.coordenador;
  }

  Future<void> _showAddProcedureDialog() async {
    String? selectedProcedure;
    int? toothNumber;
    final obsController = TextEditingController();

    final procedures = ref.read(proceduresViewModelProvider).valueOrNull ?? const [];
    final options = procedures.isEmpty
        ? _defaultProcedures
        : <String>{...procedures.map((p) => p.name), ..._defaultProcedures}.toList();

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Novo Procedimento no Plano'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedProcedure,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Procedimento',
                      border: OutlineInputBorder(),
                    ),
                    items: options
                        .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedProcedure = v),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Dente (Elemento - Opcional)',
                      hintText: 'Ex.: 16',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => toothNumber = int.tryParse(v),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: obsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observações Técnicas',
                      hintText: 'Descreva a indicação clínica do procedimento...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (selectedProcedure == null) return;
                      setDialogState(() => _isSaving = true);
                      try {
                        final newItem = TreatmentItem(
                          id: const Uuid().v4(),
                          procedureId: const Uuid().v4(),
                          procedureName: selectedProcedure!,
                          toothNumber: toothNumber,
                          observation: obsController.text.trim(),
                          status: TreatmentItemStatus.pending,
                        );
                        await ref
                            .read(treatmentPlanViewModelProvider(widget.patientId).notifier)
                            .addItem(newItem);
                        ref.invalidate(prontuarioSummaryProvider(widget.patientId));
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Procedimento adicionado ao plano!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
                          );
                        }
                      } finally {
                        _isSaving = false;
                        if (dialogContext.mounted) {
                          setDialogState(() {});
                        }
                      }
                    },
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Adicionar ao Plano'),
            ),
          ],
        ),
      ),
    );
    obsController.dispose();
  }

  Future<void> _changeItemStatus(
    TreatmentPlan plan,
    TreatmentItem item,
    TreatmentItemStatus newStatus,
  ) async {
    try {
      await ref
          .read(treatmentPlanViewModelProvider(widget.patientId).notifier)
          .updateItemStatus(plan.id, item.id, newStatus);
      ref.invalidate(prontuarioSummaryProvider(widget.patientId));

      if (newStatus == TreatmentItemStatus.completed && mounted) {
        final toothText = item.toothNumber != null ? ' no elemento ${item.toothNumber}' : '';
        final draft =
            'Procedimento "${item.procedureName}"$toothText concluído conforme Plano de Tratamento.'
            '${item.observation != null && item.observation!.isNotEmpty ? " Observações: ${item.observation}" : ""}';
        final createEvolution = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Procedimento Concluído'),
            content: const Text(
              'Deseja registrar automaticamente a Evolução Clínica para este procedimento?',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Agora não')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Registrar Evolução'),
              ),
            ],
          ),
        );
        if (createEvolution == true && mounted) {
          final encodedDraft = Uri.encodeQueryComponent(draft);
          final encodedName = Uri.encodeQueryComponent(widget.patientName);
          context.push(
            '/dashboard/patients/prontuario/evolution?patientId=${widget.patientId}&patientName=$encodedName&initialDescription=$encodedDraft',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportPdf(TreatmentPlan plan) async {
    try {
      final file = await ProntuarioPdfService.generateTreatmentPlanPdf(
        patientName: widget.patientName,
        plan: plan,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF do plano salvo em: ${file.path}'),
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

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(treatmentPlanViewModelProvider(widget.patientId));
    final currentUser = ref.watch(authViewModelProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Plano de Tratamento'),
            Text(widget.patientName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          if (planAsync.valueOrNull != null && planAsync.valueOrNull!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Exportar Plano em PDF',
              onPressed: () => _exportPdf(planAsync.valueOrNull!.first),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF006494),
        onPressed: _showAddProcedureDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Adicionar Procedimento', style: TextStyle(color: Colors.white)),
      ),
      body: planAsync.when(
        data: (plans) {
          if (plans.isEmpty) return _buildEmptyState();
          final plan = plans.first;
          return Column(
            children: [
              _buildPlanHeader(plan, currentUser),
              Expanded(child: _buildItemsList(plan)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro ao carregar: $err')),
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
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showAddProcedureDialog,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Primeiro Procedimento'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHeader(TreatmentPlan plan, User? currentUser) {
    final activeItems = plan.items.where((i) => i.status != TreatmentItemStatus.canceled).toList();
    final completedCount = activeItems.where((i) => i.status == TreatmentItemStatus.completed).length;
    final progress = activeItems.isEmpty ? 0.0 : completedCount / activeItems.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _planStatusLabel(plan.status),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006494),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount de ${activeItems.length} procedimento(s) concluído(s)',
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              if (plan.status == TreatmentPlanStatus.draft && _canApprove(currentUser))
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(treatmentPlanViewModelProvider(widget.patientId).notifier)
                          .approvePlan(plan.id);
                      ref.invalidate(prontuarioSummaryProvider(widget.patientId));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Plano de tratamento aprovado!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao aprovar: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.verified_outlined, size: 18),
                  label: const Text('Aprovar Plano'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(TreatmentPlan plan) {
    if (plan.items.isEmpty) {
      return const Center(child: Text('Nenhum procedimento adicionado neste plano.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: plan.items.length,
      itemBuilder: (context, index) {
        final item = plan.items[index];
        final color = _itemStatusColor(item.status);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Text(
                item.toothNumber != null ? '${item.toothNumber}' : 'G',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            title: Text(
              item.procedureName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: item.status == TreatmentItemStatus.canceled
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.observation != null && item.observation!.isNotEmpty)
                  Text(item.observation!),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _itemStatusLabel(item.status),
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) async {
                if (action == 'delete') {
                  await ref
                      .read(treatmentPlanViewModelProvider(widget.patientId).notifier)
                      .removeItem(plan.id, item.id);
                  ref.invalidate(prontuarioSummaryProvider(widget.patientId));
                } else {
                  final target = TreatmentItemStatus.values.firstWhere((s) => s.name == action);
                  await _changeItemStatus(plan, item, target);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'pending', child: Text('Marcar Pendente')),
                const PopupMenuItem(value: 'inProgress', child: Text('Marcar Em andamento')),
                const PopupMenuItem(value: 'completed', child: Text('Marcar Concluído')),
                const PopupMenuItem(value: 'canceled', child: Text('Cancelar item')),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Remover', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
