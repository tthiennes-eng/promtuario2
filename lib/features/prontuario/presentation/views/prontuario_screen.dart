import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/endodontia_viewmodel.dart';
import '../widgets/patient_menu_button.dart';

class ProntuarioScreen extends ConsumerWidget {
  final Patient patient;

  const ProntuarioScreen({super.key, required this.patient});

  void _handleMenuAction(BuildContext context, String actionId, Patient patient) {
    final String base = '/dashboard/patients/prontuario';
    final String query = '?patientId=${patient.id}&patientName=${patient.fullName}';
    
    switch (actionId) {
      case 'anamnese': context.push('$base/anamnese$query', extra: patient); break;
      case 'extraoral': context.push('$base/extraoral$query', extra: patient); break;
      case 'intraoral': context.push('$base/intraoral$query', extra: patient); break;
      case 'periograma': context.push('$base/periograma$query', extra: patient); break;
      case 'endodontia': context.push('$base/endodontia$query', extra: patient); break;
      case 'plano': context.push('$base/treatment-plan$query', extra: patient); break;
      case 'receita': context.push('$base/prescription$query', extra: patient); break;
      case 'atestado': context.push('$base/certificate$query', extra: patient); break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anamneseAsync = ref.watch(endodontiaViewModelProvider("anamnese_${patient.id}"));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(patient.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                _buildClassificationBadge(patient.classification),
              ],
            ),
            Text('Paciente ID: ${patient.id.substring(0, 8)}', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Editar Dados Cadastrais',
            onPressed: () => context.push('/dashboard/patients/add', extra: patient),
          ),
          PatientMenuButton(onActionSelected: (id) => _handleMenuAction(context, id, patient)),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            anamneseAsync.maybeWhen(
              data: (data) => _buildAllergyAlert(data),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            _buildClassificationSelector(context, ref),
            const SizedBox(height: 24),
            _buildSectionTitle("PRONTUÁRIO E FICHAS CLÍNICAS"),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuCard(context, "Odontograma", Icons.medical_services_outlined, '/dashboard/patients/prontuario/odontogram'),
                _buildMenuCard(context, "Evolução Clínica", Icons.history_edu_outlined, '/dashboard/patients/prontuario/evolution'),
                _buildMenuCard(context, "Anamnese", Icons.history, '/dashboard/patients/prontuario/anamnese'),
                _buildMenuCard(context, "Exame Extraoral", Icons.face_retouching_natural, '/dashboard/patients/prontuario/extraoral'),
                _buildMenuCard(context, "Exame Intraoral", Icons.medical_information, '/dashboard/patients/prontuario/intraoral'),
                _buildMenuCard(context, "Periograma", Icons.table_chart_outlined, '/dashboard/patients/prontuario/periograma'),
                _buildMenuCard(context, "Endodontia", Icons.healing, '/dashboard/patients/prontuario/endodontia'),
                _buildMenuCard(context, "Plano de Tratamento", Icons.assignment_outlined, '/dashboard/patients/prontuario/treatment-plan'),
                _buildMenuCard(context, "Histórico de Alterações", Icons.history_toggle_off, '/dashboard/patients/prontuario/history'),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("DOCUMENTOS E EXAMES"),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuCard(context, "Exames & Fotos", Icons.photo_library_outlined, '/dashboard/patients/prontuario/exams'),
                _buildMenuCard(context, "Emitir Receita", Icons.description_outlined, '/dashboard/patients/prontuario/prescription'),
                _buildMenuCard(context, "Emitir Atestado", Icons.article_outlined, '/dashboard/patients/prontuario/certificate'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.1)),
    );
  }

  Widget _buildClassificationBadge(ClinicalClassification classification) {
    final color = switch (classification) {
      ClinicalClassification.healthy => Colors.green,
      ClinicalClassification.satisfactory => Colors.blue,
      ClinicalClassification.unsatisfactory => Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(classification.displayName.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildClassificationSelector(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.assignment_ind_outlined, size: 20, color: Colors.blueGrey),
            const SizedBox(width: 12),
            const Expanded(child: Text('Classificação Clínica Geral:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DropdownButton<ClinicalClassification>(
              value: patient.classification,
              underline: const SizedBox(),
              items: ClinicalClassification.values.map((c) => DropdownMenuItem(value: c, child: Text(c.displayName, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(patientViewModelProvider.notifier).editPatient(patient.copyWith(classification: val), duplaResponsavel: 'Alteração de Classificação');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergyAlert(Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();
    
    final sistemico = data['sistemico'];
    if (sistemico == null) return const SizedBox.shrink();

    final alergia = sistemico['alergia'];
    final bool temAlergia = alergia?['sim'] ?? false;
    final String qualAlergia = alergia?['qual'] ?? "";

    if (!temAlergia) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade900, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ALERTA DE SAÚDE / ALERGIA', style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('O paciente informou alergia a: $qualAlergia', style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String label, IconData icon, String route) {
    final String fullRoute = "$route?patientId=${patient.id}&patientName=${patient.fullName}";
    
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => context.push(fullRoute, extra: patient),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF006494).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: const Color(0xFF006494)),
            ),
            const SizedBox(height: 12),
            Text(label, 
              textAlign: TextAlign.center, 
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          ],
        ),
      ),
    );
  }
}
