import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:promt/features/agenda/presentation/viewmodels/appointment_viewmodel.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:go_router/go_router.dart';

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
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => notifier.fetchInstitutionalData())],
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
    final formattedDate = "${dayOfWeek[0].toUpperCase()}${dayOfWeek.substring(1)}, ${selectedDate.day} de ${monthName[0].toUpperCase()}${monthName.substring(1)}";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filledTonal(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () {
            final newDate = selectedDate.subtract(const Duration(days: 1));
            notifier.selectDate(newDate);
            notifier.fetchInstitutionalData();
          }),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: [Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF006494))), const Text('Clique para alterar a data', style: TextStyle(fontSize: 10, color: Colors.grey))])),
          IconButton.filledTonal(icon: const Icon(Icons.arrow_forward_ios, size: 18), onPressed: () {
            final newDate = selectedDate.add(const Duration(days: 1));
            notifier.selectDate(newDate);
            notifier.fetchInstitutionalData();
          }),
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
          columnSpacing: 20, headingRowHeight: 60, dataRowHeight: 80,
          headingRowColor: MaterialStateProperty.all(const Color(0xFF006494).withOpacity(0.05)),
          border: TableBorder.all(color: Colors.grey.shade100),
          columns: [
            const DataColumn(label: Text('Horário', style: TextStyle(fontWeight: FontWeight.bold))),
            ...clinics.map((c) => DataColumn(label: SizedBox(width: 160, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(c.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), if (c.location != null) Text(c.location!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.grey))])))),
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
                          final targetTime = DateTime(ref.read(appointmentViewModelProvider).selectedDate.year, ref.read(appointmentViewModelProvider).selectedDate.month, ref.read(appointmentViewModelProvider).selectedDate.day, hour, 0);
                          context.push('/dashboard/agenda/add', extra: {'clinic': clinic, 'time': targetTime});
                        } else {
                          _showAppointmentDetails(appts.first);
                        }
                      },
                      child: _buildCellContent(appts),
                    )
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
    if (appts.isEmpty) return Container(width: 160, alignment: Alignment.center, child: Icon(Icons.add_circle_outline, color: Colors.grey.shade300, size: 20));
    final appt = appts.first;
    Color color = appt.status == AppointmentStatus.scheduled ? Colors.blue : appt.status == AppointmentStatus.completed ? Colors.green : Colors.orange;
    return Container(width: 160, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(appt.patientName, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis), const SizedBox(height: 2), Text(appt.procedureName ?? 'Avaliação', style: TextStyle(fontSize: 8, color: color.withOpacity(0.8)), overflow: TextOverflow.ellipsis)]));
  }

  void _showAppointmentDetails(Appointment appt) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appt.patientName.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006494))),
            const SizedBox(height: 24),
            _infoRow(Icons.access_time, 'Horário', '${DateFormat('HH:mm').format(appt.startTime)} às ${DateFormat('HH:mm').format(appt.endTime)}'),
            _infoRow(Icons.medical_services_outlined, 'Procedimento', appt.procedureName ?? 'Avaliação Geral'),
            _infoRow(Icons.school_outlined, 'Responsável (Aluno)', appt.studentName ?? 'Não atribuído'),
            _infoRow(Icons.person_outline, 'Supervisor (Professor)', appt.professorName ?? 'Não atribuído'),
            if (appt.notes != null && appt.notes!.isNotEmpty) _infoRow(Icons.notes, 'Observações', appt.notes!),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 20, color: Colors.blueGrey), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))]))]));
  }
}
