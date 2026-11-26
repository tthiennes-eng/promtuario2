import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/prontuario_summary_provider.dart';

class ClinicalTimelineScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const ClinicalTimelineScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  ConsumerState<ClinicalTimelineScreen> createState() => _ClinicalTimelineScreenState();
}

class _ClinicalTimelineScreenState extends ConsumerState<ClinicalTimelineScreen> {
  String _selectedCategory = 'all';

  static const _categories = <String, String>{
    'all': 'Todos',
    'evolution': 'Evoluções',
    'sheet': 'Fichas / Versões',
    'appointment': 'Consultas',
    'prescription': 'Receitas',
    'certificate': 'Atestados',
    'exam': 'Exames',
  };

  IconData _iconForCategory(String category) {
    return switch (category) {
      'evolution' => Icons.history_edu_outlined,
      'sheet' => Icons.assignment_outlined,
      'appointment' => Icons.calendar_today_outlined,
      'prescription' => Icons.description_outlined,
      'certificate' => Icons.article_outlined,
      'exam' => Icons.photo_library_outlined,
      _ => Icons.event_note,
    };
  }

  Color _colorForCategory(String category) {
    return switch (category) {
      'evolution' => const Color(0xFF006494),
      'sheet' => Colors.teal,
      'appointment' => Colors.indigo,
      'prescription' => Colors.deepPurple,
      'certificate' => Colors.brown,
      'exam' => Colors.orange.shade800,
      _ => Colors.blueGrey,
    };
  }

  Future<void> _showSheetVersionsDialog(String sheetType, String title) async {
    final versions = await ref.read(
      clinicalSheetHistoryProvider((patientId: widget.patientId, sheetType: sheetType)).future,
    );
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Versões de $title'),
        content: SizedBox(
          width: 560,
          height: 420,
          child: versions.isEmpty
              ? const Center(child: Text('Nenhuma versão histórica encontrada no servidor.'))
              : ListView.separated(
                  itemCount: versions.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, idx) {
                    final v = versions[idx];
                    final ver = v['version'] ?? idx + 1;
                    final dt = DateTime.tryParse((v['createdAt'] ?? '').toString())?.toLocal();
                    final formattedDate =
                        dt != null ? DateFormat('dd/MM/yyyy HH:mm').format(dt) : '-';
                    final preview = const JsonEncoder.withIndent('  ').convert(v['data'] ?? {});
                    return ExpansionTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.teal.shade50,
                        child: Text('v$ver', style: TextStyle(fontSize: 11, color: Colors.teal.shade900, fontWeight: FontWeight.bold)),
                      ),
                      title: Text('Versão $ver'),
                      subtitle: Text('Salvo em $formattedDate'),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          color: Colors.grey.shade100,
                          child: SelectableText(
                            preview.length > 1500 ? '${preview.substring(0, 1500)}...' : preview,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(clinicalTimelineProvider(widget.patientId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Linha do Tempo Clínica'),
            Text(widget.patientName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(clinicalTimelineProvider(widget.patientId)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.entries.map((entry) {
                final selected = _selectedCategory == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = entry.key),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: timelineAsync.when(
              data: (events) {
                final filtered = _selectedCategory == 'all'
                    ? events
                    : events.where((e) => (e['category'] ?? '') == _selectedCategory).toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum evento clínico registrado nesta categoria.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final e = filtered[index];
                    final category = (e['category'] ?? '').toString();
                    final color = _colorForCategory(category);
                    final dt = DateTime.tryParse((e['date'] ?? '').toString())?.toLocal();
                    final dateText = dt != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(dt)
                        : '';
                    final badge = e['badge']?.toString();
                    final metadata = e['metadata']?.toString();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(_iconForCategory(category), color: color, size: 20),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                (e['title'] ?? '').toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            if (badge != null && badge.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  badge,
                                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text((e['description'] ?? '').toString(), maxLines: 3, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(
                              metadata != null && metadata.isNotEmpty && category != 'sheet'
                                  ? '$dateText • $metadata'
                                  : dateText,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: category == 'sheet' && metadata != null
                            ? TextButton(
                                onPressed: () => _showSheetVersionsDialog(
                                  metadata,
                                  (e['title'] ?? metadata).toString(),
                                ),
                                child: const Text('Versões'),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erro ao carregar linha do tempo: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
