import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:promt/features/patients/domain/entities/patient_change_log.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';
import 'package:promt/core/providers/providers.dart';

class PatientHistoryScreen extends ConsumerWidget {
  final String patientId;
  final String patientName;

  const PatientHistoryScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(patientHistoryProvider(patientId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Auditoria: $patientName'),
      ),
      body: historyAsync.when(
        data: (logs) => logs.isEmpty
            ? const Center(child: Text('Nenhum histórico de alterações encontrado.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return _buildLogCard(logs[index]);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildLogCard(PatientChangeLog log) {
    final Map<String, dynamic> changes = jsonDecode(log.changesJson);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(log.timestamp),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Por: ${log.userName}',
                    style: TextStyle(fontSize: 11, color: Colors.orange.shade900, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Dupla Responsável: ${log.duplaResponsavel}', 
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            const Divider(height: 24),
            ...changes.entries.map((e) {
              final val = e.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Row(
                      children: [
                        Expanded(child: Text('${val['old']}', style: const TextStyle(color: Colors.red, fontSize: 12))),
                        const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                        Expanded(child: Text('${val['new']}', style: const TextStyle(color: Colors.green, fontSize: 12))),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

final patientHistoryProvider = FutureProvider.family<List<PatientChangeLog>, String>((ref, id) async {
  final repository = ref.watch(patientRepositoryProvider);
  return await repository.getPatientHistory(id);
});
