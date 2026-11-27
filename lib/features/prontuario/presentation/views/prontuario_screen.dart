import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/features/procedures/presentation/viewmodels/clinics_viewmodel.dart';
import 'package:promt/features/prontuario/data/services/prontuario_pdf_service.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/endodontia_viewmodel.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/prontuario_summary_provider.dart';
import '../widgets/patient_menu_button.dart';

class ProntuarioScreen extends ConsumerWidget {
  final Patient patient;

  const ProntuarioScreen({super.key, required this.patient});

  void _handleMenuAction(BuildContext context, String actionId, Patient patient) {
    final String base = '/dashboard/patients/prontuario';
    final String encodedName = Uri.encodeQueryComponent(patient.fullName);
    final String query = '?patientId=${patient.id}&patientName=$encodedName';

    switch (actionId) {
      case 'anamnese': context.push('$base/anamnese$query', extra: patient); break;
      case 'extraoral': context.push('$base/extraoral$query', extra: patient); break;
      case 'intraoral': context.push('$base/intraoral$query', extra: patient); break;
      case 'periograma': context.push('$base/periograma$query', extra: patient); break;
      case 'endodontia': context.push('$base/endodontia$query', extra: patient); break;
      case 'ppr': context.push('$base/ppr$query', extra: patient); break;
      case 'dtm': context.push('$base/dtm$query', extra: patient); break;
      case 'odontopediatria': context.push('$base/odontopediatria$query', extra: patient); break;
      case 'plano': context.push('$base/treatment-plan$query', extra: patient); break;
      case 'tcle': context.push('$base/tcle$query', extra: patient); break;
      case 'timeline': context.push('$base/timeline$query', extra: patient); break;
      case 'receita': context.push('$base/prescription$query', extra: patient); break;
      case 'atestado': context.push('$base/certificate$query', extra: patient); break;
    }
  }

  Future<void> _exportFullRecord(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gerando PDF completo do prontuário...')),
    );
    try {
      final repo = ref.read(prontuarioRepositoryProvider);
      final odontogram = await repo.getOdontogram(patient.id);
      final evolutions = await repo.getEvolutions(patient.id);
      final plans = await repo.getTreatmentPlans(patient.id);
      final prescriptions = await repo.getPrescriptionHistory(patient.id);
      final certificates = await repo.getCertificateHistory(patient.id);
      final anamnese = await repo.getEndodontia('anamnese_${patient.id}');
      final tcle = await repo.getEndodontia('tcle_${patient.id}');
      final dtm = await repo.getEndodontia('dtm_${patient.id}');
      final ppr = await repo.getEndodontia('ppr_${patient.id}');
      final endodontia = await repo.getEndodontia(patient.id);
      final periograma = await repo.getPeriograma(patient.id);
      final odontopediatria = await repo.getEndodontia('odontopediatria_${patient.id}');

      final file = await ProntuarioPdfService.generateFullProntuarioPdf(
        patient: patient,
        anamnese: anamnese,
        odontogram: odontogram,
        evolutions: evolutions,
        plans: plans,
        prescriptions: prescriptions,
        certificates: certificates,
        tcle: tcle,
        dtm: dtm,
        ppr: ppr,
        endodontia: endodontia,
        periograma: periograma,
        odontopediatria: odontopediatria,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prontuário completo exportado em: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar prontuário: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anamneseAsync = ref.watch(endodontiaViewModelProvider('anamnese_${patient.id}'));
    final pedAsync = ref.watch(endodontiaViewModelProvider('odontopediatria_${patient.id}'));
    final summary = ref.watch(prontuarioSummaryProvider(patient.id)).valueOrNull ?? const <String, dynamic>{};
    final allAppointments = ref.watch(allAppointmentsProvider).valueOrNull ?? const <Appointment>[];
    final clinics = ref.watch(clinicsViewModelProvider).valueOrNull ?? const <Clinic>[];

    final sheets = summary['sheets'] is Map
        ? Map<String, dynamic>.from(summary['sheets'] as Map)
        : const <String, dynamic>{};

    String? sheetBadge(String key) {
      final entry = sheets[key];
      if (entry is Map) {
        final ver = entry['version'];
        final dt = DateTime.tryParse((entry['updatedAt'] ?? '').toString())?.toLocal();
        if (dt != null) {
          return 'v${ver ?? 1} • ${DateFormat('dd/MM').format(dt)}';
        }
        return 'Preenchido';
      }
      return 'Pendente';
    }

    bool sheetFilled(String key) => sheets.containsKey(key);

    final evoCount = (summary['evolutionsCount'] as num?)?.toInt() ?? 0;
    final pendingSigs = (summary['pendingSignaturesCount'] as num?)?.toInt() ?? 0;
    final teethCount = (summary['odontogramTeethCount'] as num?)?.toInt() ?? 0;
    final examsCount = (summary['attachmentsCount'] as num?)?.toInt() ?? 0;
    final rxCount = (summary['prescriptionsCount'] as num?)?.toInt() ?? 0;
    final certCount = (summary['certificatesCount'] as num?)?.toInt() ?? 0;
    final planTotal = (summary['treatmentPlanTotalItems'] as num?)?.toInt() ?? 0;
    final planDone = (summary['treatmentPlanCompletedItems'] as num?)?.toInt() ?? 0;

    final anamneseData = anamneseAsync.valueOrNull;
    final pedData = pedAsync.valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patient.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Paciente ID: ${patient.id.length >= 8 ? patient.id.substring(0, 8) : patient.id}', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar Prontuário Completo (PDF)',
            onPressed: () => _exportFullRecord(context, ref),
          ),
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
            _buildPatientHeaderCard(allAppointments, clinics),
            const SizedBox(height: 16),
            _buildComorbidityAlert(anamneseData, pedData),
            _buildAllergyAlert(anamneseData, pedData),
            const SizedBox(height: 8),
            _buildSectionTitle('PRONTUÁRIO E FICHAS CLÍNICAS'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 900
                  ? 5
                  : (MediaQuery.of(context).size.width > 600 ? 4 : 2),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
              children: [
                _buildMenuCard(
                  context,
                  'Odontograma',
                  Icons.medical_services_outlined,
                  '/dashboard/patients/prontuario/odontogram',
                  badge: teethCount > 0 ? '$teethCount dente(s)' : 'Pendente',
                  isFilled: teethCount > 0,
                ),
                _buildMenuCard(
                  context,
                  'Evolução Clínica',
                  Icons.history_edu_outlined,
                  '/dashboard/patients/prontuario/evolution',
                  badge: pendingSigs > 0
                      ? '$evoCount ($pendingSigs pend.)'
                      : '$evoCount reg.',
                  isFilled: evoCount > 0,
                ),
                _buildMenuCard(
                  context,
                  'Anamnese',
                  Icons.history,
                  '/dashboard/patients/prontuario/anamnese',
                  badge: sheetBadge('anamnese'),
                  isFilled: sheetFilled('anamnese'),
                ),
                _buildMenuCard(
                  context,
                  'Exame Extraoral',
                  Icons.face_retouching_natural,
                  '/dashboard/patients/prontuario/extraoral',
                  badge: sheetBadge('extraoral'),
                  isFilled: sheetFilled('extraoral'),
                ),
                _buildMenuCard(
                  context,
                  'Exame Intraoral',
                  Icons.medical_information,
                  '/dashboard/patients/prontuario/intraoral',
                  badge: sheetBadge('intraoral'),
                  isFilled: sheetFilled('intraoral'),
                ),
                _buildMenuCard(
                  context,
                  'Periograma',
                  Icons.table_chart_outlined,
                  '/dashboard/patients/prontuario/periograma',
                  badge: sheetBadge('periograma'),
                  isFilled: sheetFilled('periograma'),
                ),
                _buildMenuCard(
                  context,
                  'Endodontia',
                  Icons.healing,
                  '/dashboard/patients/prontuario/endodontia',
                  badge: sheetBadge('endodontia'),
                  isFilled: sheetFilled('endodontia'),
                ),
                _buildMenuCard(
                  context,
                  'PPR',
                  Icons.architecture_outlined,
                  '/dashboard/patients/prontuario/ppr',
                  badge: sheetBadge('ppr'),
                  isFilled: sheetFilled('ppr'),
                ),
                _buildMenuCard(
                  context,
                  'DTM',
                  Icons.monitor_heart_outlined,
                  '/dashboard/patients/prontuario/dtm',
                  badge: sheetBadge('dtm'),
                  isFilled: sheetFilled('dtm'),
                ),
                _buildMenuCard(
                  context,
                  'Odontopediatria',
                  Icons.child_care_outlined,
                  '/dashboard/patients/prontuario/odontopediatria',
                  badge: sheetBadge('odontopediatria'),
                  isFilled: sheetFilled('odontopediatria'),
                ),
                _buildMenuCard(
                  context,
                  'Plano de Tratamento',
                  Icons.assignment_outlined,
                  '/dashboard/patients/prontuario/treatment-plan',
                  badge: planTotal > 0 ? '$planDone/$planTotal concl.' : 'Pendente',
                  isFilled: planTotal > 0,
                ),
                _buildMenuCard(
                  context,
                  'Linha do Tempo',
                  Icons.timeline_outlined,
                  '/dashboard/patients/prontuario/timeline',
                  badge: 'Histórico',
                  isFilled: true,
                ),
                _buildMenuCard(
                  context,
                  'Histórico Cadastral',
                  Icons.history_toggle_off,
                  '/dashboard/patients/prontuario/history',
                  badge: 'Auditoria',
                  isFilled: true,
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('DOCUMENTOS, EXAMES E CONSENTIMENTO'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 900
                  ? 5
                  : (MediaQuery.of(context).size.width > 600 ? 4 : 2),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
              children: [
                _buildMenuCard(
                  context,
                  'Exames & Fotos',
                  Icons.photo_library_outlined,
                  '/dashboard/patients/prontuario/exams',
                  badge: '$examsCount anexo(s)',
                  isFilled: examsCount > 0,
                ),
                _buildMenuCard(
                  context,
                  'Emitir Receita',
                  Icons.description_outlined,
                  '/dashboard/patients/prontuario/prescription',
                  badge: '$rxCount emitida(s)',
                  isFilled: rxCount > 0,
                ),
                _buildMenuCard(
                  context,
                  'Emitir Atestado',
                  Icons.article_outlined,
                  '/dashboard/patients/prontuario/certificate',
                  badge: '$certCount emitido(s)',
                  isFilled: certCount > 0,
                ),
                _buildMenuCard(
                  context,
                  'TCLE / LGPD',
                  Icons.verified_user_outlined,
                  '/dashboard/patients/prontuario/tcle',
                  badge: sheetFilled('tcle') ? 'Assinado' : 'Pendente',
                  isFilled: sheetFilled('tcle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeaderCard(List<Appointment> allAppointments, List<Clinic> clinics) {
    final age = DateTime.now().year - patient.birthDate.year;
    final patientApps = allAppointments.where((a) => a.patientId == patient.id).toList();
    final now = DateTime.now();

    final past = patientApps.where((a) => a.startTime.isBefore(now)).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final future = patientApps
        .where((a) => a.startTime.isAfter(now) && a.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final lastApp = past.isNotEmpty ? past.first : null;
    final nextApp = future.isNotEmpty ? future.first : null;

    String formatApp(Appointment? a) {
      if (a == null) return 'Nenhum registro';
      final clinic = Clinic.resolveDisplayName(
        clinicId: a.clinicId,
        clinicName: a.clinicName,
        clinics: clinics,
      );
      return '${DateFormat('dd/MM/yyyy HH:mm').format(a.startTime)} • $clinic';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF006494).withValues(alpha: 0.12),
                child: Text(
                  patient.fullName.isNotEmpty ? patient.fullName[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    color: Color(0xFF006494),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text('CPF: ${patient.cpf}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                        Text('$age anos (${DateFormat('dd/MM/yyyy').format(patient.birthDate)})', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                        if (patient.susNumber != null && patient.susNumber!.isNotEmpty)
                          Text('SUS: ${patient.susNumber}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                        if (patient.phone != null && patient.phone!.isNotEmpty)
                          Text('Tel: ${patient.phone}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 15, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text('Último atendimento: ${formatApp(lastApp)}', style: const TextStyle(fontSize: 12)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_available, size: 15, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'Próximo agendamento: ${formatApp(nextApp)}',
                    style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.1)),
    );
  }

  Widget _buildComorbidityAlert(
    Map<String, dynamic>? data, [
    Map<String, dynamic>? pedData,
  ]) {
    final comorbidades = <String>[];

    if (data != null) {
      final sistemico = data['sistemico'];
      if (sistemico is Map) {
        void addMapCondition(String key, String label) {
          final condition = sistemico[key];
          if (condition is Map && condition['sim'] == true) {
            final detalhe = condition['qual']?.toString().trim() ?? '';
            comorbidades.add(detalhe.isEmpty ? label : '$label: $detalhe');
          } else if (condition is Map && condition['sim'] == 'true') {
            comorbidades.add(label);
          }
        }

        addMapCondition('cardiacos', 'Problemas cardíacos');
        addMapCondition('digestivos', 'Problemas digestivos');
        addMapCondition('figado', 'Problemas de fígado');
        addMapCondition('neurologicos', 'Problemas neurológicos');
        addMapCondition('coagulacao', 'Problemas de coagulação');

        final sinusite = sistemico['sinusite'];
        if (sinusite is Map && sinusite['sim'] == true) {
          comorbidades.add('Sinusite');
        }

        final pressao = sistemico['pressao'];
        if (pressao is Map &&
            ((pressao['qual']?.toString().trim().isNotEmpty ?? false) ||
                pressao['usaMeds'] == true)) {
          final detalhe = pressao['qual']?.toString().trim() ?? '';
          comorbidades.add(detalhe.isEmpty
              ? 'Problema de pressão arterial'
              : 'Pressão arterial: $detalhe');
        }

        final diabetes = sistemico['diabetes'];
        if (diabetes is Map && diabetes['sim'] == true) {
          final controlada = diabetes['controlada']?.toString().trim() ?? '';
          comorbidades.add(controlada.isEmpty
              ? 'Diabetes'
              : 'Diabetes ($controlada)');
        }
      }
    }

    if (pedData != null) {
      final pedFields = pedData['fields'] is Map
          ? Map<String, dynamic>.from(pedData['fields'] as Map)
          : pedData;
      String pedStr(String key) => pedFields[key]?.toString().trim() ?? '';

      if (pedStr('t5_hma_tratamento_medico') == '(1) Sim') {
        final qual = pedStr('t5_hma_tratamento_qual');
        comorbidades.add(qual.isEmpty
            ? 'Em tratamento médico (Odontopediatria)'
            : 'Tratamento médico (Pediatria): $qual');
      }

      final doencasInfancia = pedStr('t5_hma_doencas_infancia');
      if (doencasInfancia.isNotEmpty) {
        comorbidades.add('Doenças da infância: $doencasInfancia');
      }

      final respiracao = pedStr('t5_hmat_respiracao');
      if (respiracao.toLowerCase().contains('bucal')) {
        comorbidades.add('Respiração: $respiracao (Pediatria)');
      }
    }

    if (comorbidades.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.medical_information_outlined, color: Colors.orange.shade900, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALERTA DE COMORBIDADE',
                  style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  comorbidades.join(' • '),
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyAlert(
    Map<String, dynamic>? data, [
    Map<String, dynamic>? pedData,
  ]) {
    final alergias = <String>[];

    if (data != null) {
      final sistemico = data['sistemico'];
      if (sistemico is Map) {
        final alergia = sistemico['alergia'];
        final bool temAlergia =
            alergia is Map && (alergia['sim'] == true || alergia['sim'] == 'true');
        if (temAlergia) {
          final qualAlergia = alergia['qual']?.toString().trim() ?? '';
          alergias.add(
            qualAlergia.isEmpty ? 'Alergia informada na Anamnese' : qualAlergia,
          );
        }
      }
    }

    if (pedData != null) {
      final pedFields = pedData['fields'] is Map
          ? Map<String, dynamic>.from(pedData['fields'] as Map)
          : pedData;
      String pedStr(String key) => pedFields[key]?.toString().trim() ?? '';

      if (pedStr('t4_hb_q17_alergia_anestesico') == '(1) Sim') {
        alergias.add('Alergia a anestésico (Odontopediatria)');
      }
      if (pedStr('t5_hma_alergia') == '(1) Sim') {
        final qual = pedStr('t5_hma_alergia_qual');
        final tipo = pedStr('t5_hmat_tipo_alergia');
        final detalhes = [qual, tipo].where((s) => s.isNotEmpty).join(' / ');
        alergias.add(
          detalhes.isEmpty
              ? 'Alergia informada na Odontopediatria'
              : '$detalhes (Odontopediatria)',
        );
      } else if (pedStr('t5_hmat_tipo_alergia').isNotEmpty) {
        alergias.add('${pedStr('t5_hmat_tipo_alergia')} (Odontopediatria)');
      }
    }

    if (alergias.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade900, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ALERTA DE SAÚDE / ALERGIA', style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text('O paciente informou alergia a: ${alergias.join(' • ')}', style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String label,
    IconData icon,
    String route, {
    String? badge,
    bool isFilled = false,
  }) {
    final encodedName = Uri.encodeQueryComponent(patient.fullName);
    final String fullRoute = '$route?patientId=${patient.id}&patientName=$encodedName';

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
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFF006494).withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: const Color(0xFF006494)),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              if (badge != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isFilled ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isFilled ? Colors.green.shade800 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
