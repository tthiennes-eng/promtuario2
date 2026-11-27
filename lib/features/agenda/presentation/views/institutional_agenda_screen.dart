import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/agenda/presentation/viewmodels/appointment_viewmodel.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';

class InstitutionalAgendaScreen extends ConsumerStatefulWidget {
  const InstitutionalAgendaScreen({super.key});
  @override
  ConsumerState<InstitutionalAgendaScreen> createState() => _InstitutionalAgendaScreenState();
}

class _InstitutionalAgendaScreenState extends ConsumerState<InstitutionalAgendaScreen> {
  final List<int> _workingHours = List.generate(13, (index) => index + 7);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(appointmentViewModelProvider.notifier).fetchInstitutionalData());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentViewModelProvider);
    final notifier = ref.read(appointmentViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quadro Geral de Clínicas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => notifier.fetchInstitutionalData()),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(state.selectedDate, notifier),
          Expanded(
            child: state.clinics.isEmpty
                ? const Center(child: Text('Nenhuma clínica cadastrada'))
                : state.institutionalAppointments.when(
                    data: (appointments) => _buildGrid(state.clinics, appointments),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Erro: $err')),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime selectedDate, AppointmentViewModel notifier) {
    final dayOfWeek = DateFormat('EEEE', 'pt_BR').format(selectedDate);
    final monthName = DateFormat('MMMM', 'pt_BR').format(selectedDate);
    final formattedDate =
        "${dayOfWeek[0].toUpperCase()}${dayOfWeek.substring(1)}, ${selectedDate.day} de ${monthName[0].toUpperCase()}${monthName.substring(1)}";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filledTonal(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () {
              final newDate = selectedDate.subtract(const Duration(days: 1));
              notifier.selectDate(newDate);
              notifier.fetchInstitutionalData();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF006494))),
                const Text('Clique para alterar a data', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: () {
              final newDate = selectedDate.add(const Duration(days: 1));
              notifier.selectDate(newDate);
              notifier.fetchInstitutionalData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Clinic> clinics, List<Appointment> appointments) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 20,
          headingRowHeight: 60,
          dataRowMinHeight: 76,
          dataRowMaxHeight: 84,
          headingRowColor: WidgetStateProperty.all(const Color(0xFF006494).withValues(alpha: 0.05)),
          border: TableBorder.all(color: Colors.grey.shade100),
          columns: [
            const DataColumn(label: Text('Horário', style: TextStyle(fontWeight: FontWeight.bold))),
            ...clinics.map(
              (c) => DataColumn(
                label: SizedBox(
                  width: 160,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(c.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      if (c.location.isNotEmpty)
                        Text(c.location, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          rows: _workingHours.map((hour) {
            return DataRow(
              cells: [
                DataCell(Text(DateFormat('HH:00').format(DateTime(2024, 1, 1, hour)), style: const TextStyle(fontWeight: FontWeight.bold))),
                ...clinics.map((clinic) {
                  final appts = appointments.where((a) => a.clinicId == clinic.id && a.startTime.hour == hour).toList();
                  return DataCell(
                    InkWell(
                      onTap: () {
                        if (appts.isEmpty) {
                          final sel = ref.read(appointmentViewModelProvider).selectedDate;
                          final targetTime = DateTime(sel.year, sel.month, sel.day, hour, 0);
                          context.push('/dashboard/agenda/add', extra: {'clinic': clinic, 'time': targetTime});
                        } else {
                          _showAppointmentDetails(appts.first);
                        }
                      },
                      child: _buildCellContent(appts),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCellContent(List<Appointment> appts) {
    if (appts.isEmpty) {
      return Container(width: 160, alignment: Alignment.center, child: Icon(Icons.add_circle_outline, color: Colors.grey.shade300, size: 20));
    }
    final appt = appts.first;
    final Color color = switch (appt.status) {
      AppointmentStatus.scheduled => Colors.blue,
      AppointmentStatus.confirmed => Colors.teal,
      AppointmentStatus.arrived => Colors.indigo,
      AppointmentStatus.inProgress => Colors.orange,
      AppointmentStatus.completed => Colors.green,
      AppointmentStatus.cancelled => Colors.grey,
      AppointmentStatus.noShow || AppointmentStatus.missed => Colors.red,
    };
    return Container(
      width: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(appt.patientName, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text('${appt.procedureName ?? 'Avaliação'} • ${appt.status.displayName}',
              style: TextStyle(fontSize: 8.5, color: color.withValues(alpha: 0.85)), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _openProntuarioFor(Appointment appt) {
    final patients = ref.read(patientViewModelProvider).valueOrNull ?? const <Patient>[];
    final matched = patients.where((p) => p.id == appt.patientId).firstOrNull;
    final patient = matched ??
        Patient(
          id: appt.patientId,
          fullName: appt.patientName,
          cpf: '',
          birthDate: DateTime(2000, 1, 1),
          createdAt: DateTime.now(),
        );
    context.push('/dashboard/patients/prontuario', extra: patient);
  }

  Future<void> _runAction(BuildContext sheetCtx, Future<void> Function() action, String msg) async {
    Navigator.pop(sheetCtx);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAppointmentDetails(Appointment appt) {
    final notifier = ref.read(appointmentViewModelProvider.notifier);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(appt.patientName.toUpperCase(), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF006494))),
                ),
                Chip(label: Text(appt.status.displayName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 18),
            _infoRow(Icons.access_time, 'Horário', '${DateFormat('dd/MM/yyyy HH:mm').format(appt.startTime)} às ${DateFormat('HH:mm').format(appt.endTime)}'),
            _infoRow(Icons.medical_services_outlined, 'Procedimento', appt.procedureName ?? 'Avaliação Geral'),
            _infoRow(Icons.school_outlined, 'Responsável (Aluno)', appt.studentName ?? 'Não atribuído'),
            _infoRow(Icons.person_outline, 'Supervisor (Professor)', appt.professorName ?? 'Não atribuído'),
            if (appt.notes != null && appt.notes!.isNotEmpty) _infoRow(Icons.notes, 'Observações', appt.notes!),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    _openProntuarioFor(appt);
                  },
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF006494)),
                  icon: const Icon(Icons.folder_shared_outlined, size: 18),
                  label: const Text('Abrir Prontuário'),
                ),
                if (appt.arrivalTime == null &&
                    appt.status != AppointmentStatus.completed &&
                    appt.status != AppointmentStatus.cancelled &&
                    appt.status != AppointmentStatus.noShow)
                  OutlinedButton.icon(
                    onPressed: () => _runAction(sheetCtx, () => notifier.registerArrival(appt.id), 'Chegada registrada.'),
                    icon: const Icon(Icons.hail, size: 18),
                    label: const Text('Chegada'),
                  ),
                if (appt.status == AppointmentStatus.scheduled ||
                    appt.status == AppointmentStatus.confirmed ||
                    appt.status == AppointmentStatus.arrived)
                  OutlinedButton.icon(
                    onPressed: () => _runAction(sheetCtx, () => notifier.registerStart(appt.id), 'Atendimento iniciado.'),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Iniciar'),
                  ),
                if (appt.status == AppointmentStatus.inProgress)
                  OutlinedButton.icon(
                    onPressed: () => _runAction(sheetCtx, () => notifier.registerFinish(appt.id), 'Atendimento finalizado.'),
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Finalizar'),
                  ),
                if (appt.status != AppointmentStatus.noShow && appt.status != AppointmentStatus.completed)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => _runAction(sheetCtx, () => notifier.updateStatus(appt.id, AppointmentStatus.noShow), 'Falta registrada.'),
                    icon: const Icon(Icons.person_off, size: 18),
                    label: const Text('Falta'),
                  ),
                if (appt.status != AppointmentStatus.cancelled && appt.status != AppointmentStatus.completed)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade700),
                    onPressed: () => _runAction(sheetCtx, () => notifier.updateStatus(appt.id, AppointmentStatus.cancelled), 'Agendamento cancelado.'),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Cancelar'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
