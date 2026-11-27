import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:promt/core/network/api_client.dart';

/// Exibe um modal com o histórico de versões salvas de uma ficha clínica,
/// destacando automaticamente os campos alterados entre versões consecutivas.
Future<void> showSheetHistoryDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String patientId,
  required String sheetType,
  required String sheetTitle,
}) async {
  final dio = ref.read(apiClientProvider).instance;

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.history, color: Color(0xFF006494)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Histórico de Versões — $sheetTitle',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        height: 440,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchHistory(dio, patientId, sheetType),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Não foi possível carregar o histórico de versões:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            final versions = snapshot.data ?? const [];
            if (versions.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhuma versão registrada no servidor para esta ficha ainda.',
                  style: TextStyle(color: Colors.blueGrey),
                ),
              );
            }

            return ListView.separated(
              itemCount: versions.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = versions[index];
                final ver = item['version'] ?? (versions.length - index);
                final createdAt = DateTime.tryParse((item['createdAt'] ?? '').toString())?.toLocal();
                final formattedDate = createdAt != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt)
                    : 'Data não informada';
                final currentData = item['data'] is Map
                    ? Map<String, dynamic>.from(item['data'] as Map)
                    : <String, dynamic>{};
                final previousData = (index + 1 < versions.length && versions[index + 1]['data'] is Map)
                    ? Map<String, dynamic>.from(versions[index + 1]['data'] as Map)
                    : null;

                final changes = _computeChangedFields(previousData, currentData);

                return ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                  initiallyExpanded: index == 0,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF006494).withValues(alpha: 0.12),
                    child: Text(
                      'v$ver',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006494)),
                    ),
                  ),
                  title: Text('Versão $ver', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(
                    '$formattedDate • ${changes.length} campo(s) ${previousData == null ? "registrado(s)" : "alterado(s)"}',
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                  children: [
                    if (changes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Sem diferenças em relação à versão anterior.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: changes.take(25).map((c) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $c',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}

Future<List<Map<String, dynamic>>> _fetchHistory(
  dynamic dio,
  String patientId,
  String sheetType,
) async {
  final response = await dio.get('Prontuario/$patientId/fichas/$sheetType/history');
  if (response.data is List) {
    return (response.data as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  return const [];
}

List<String> _computeChangedFields(
  Map<String, dynamic>? previous,
  Map<String, dynamic> current,
) {
  final changes = <String>[];
  final allKeys = <String>{
    ...current.keys,
    if (previous != null) ...previous.keys,
  }.toList()
    ..sort();

  for (final k in allKeys) {
    final nextVal = (current[k] ?? '').toString().trim();
    if (previous == null) {
      if (nextVal.isNotEmpty && nextVal != '{}' && nextVal != '[]') {
        changes.add('$k: ${_truncate(nextVal)}');
      }
    } else {
      final prevVal = (previous[k] ?? '').toString().trim();
      if (prevVal != nextVal) {
        changes.add('$k: ${_truncate(prevVal.isEmpty ? "(vazio)" : prevVal)} → ${_truncate(nextVal.isEmpty ? "(vazio)" : nextVal)}');
      }
    }
  }
  return changes;
}

String _truncate(String s) => s.length > 70 ? '${s.substring(0, 67)}...' : s;
