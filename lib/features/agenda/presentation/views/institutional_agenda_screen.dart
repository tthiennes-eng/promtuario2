import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:promt/features/agenda/presentation/viewmodels/appointment_viewmodel.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:go_router/go_router.dart';

/// Grade institucional apresentando todas as clínicas simultaneamente.
class InstitutionalAgendaScreen extends ConsumerStatefulWidget {
  const InstitutionalAgendaScreen({super.key});

  @override
  ConsumerState<InstitutionalAgendaScreen> createState() => _InstitutionalAgendaScreenState();
}

class _InstitutionalAgendaScreenState extends ConsumerState<InstitutionalAgendaScreen> {
  final List<int> _workingHours = List.generate(13, (index) => index + 7); // 07:00 às 19:00

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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.fetchInstitutionalData(),
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newDate = selectedDate.subtract(const Duration(days: 1));
              notifier.selectDate(newDate);
              notifier.fetchInstitutionalData();
            },
          ),
          InkWell(
            onTap: () => _selectDate(context, selectedDate, notifier),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                DateFormat('EEEE, d de MMMM', 'pt_BR').format(selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF006494)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
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
          dataRowHeight: 80,
          headingRowColor: MaterialStateProperty.all(const Color(0xFF006494).withOpacity(0.05)),
          border: TableBorder.all(color: Colors.grey.shade100),
          columns: [
            const DataColumn(label: Text('Horário', style: TextStyle(fontWeight: FontWeight.bold))),
            ...clinics.map((c) => DataColumn(
              label: Container(
                width: 160,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(c.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    if (c.location != null)
                      Text(c.location!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.grey)),
                  ],
                ),
              ),
            )),
          ],
          rows: _workingHours.map((hour) {
            return DataRow(
              cells: [
                DataCell(Text(DateFormat('HH:00').format(DateTime(2024, 1, 1, hour)), style: const TextStyle(fontWeight: FontWeight.bold))),
                ...clinics.map((clinic) {
                  final appts = _findAppointments(appointments, clinic.id, hour);
                  return DataCell(
                    InkWell(
                      onTap: () {
                        if (appts.isEmpty) {
                          // Abre agendamento já com clínica e hora selecionados
                          final targetTime = DateTime(
                            ref.read(appointmentViewModelProvider).selectedDate.year,
                            ref.read(appointmentViewModelProvider).selectedDate.month,
                            ref.read(appointmentViewModelProvider).selectedDate.day,
                            hour, 0
                          );
                          context.push('/dashboard/agenda/add', extra: {'clinic': clinic, 'time': targetTime});
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

  List<Appointment> _findAppointments(List<Appointment> allAppointments, String clinicId, int hour) {
    return allAppointments.where(
      (a) => a.clinicId == clinicId && a.startTime.hour == hour
    ).toList();
  }

  Widget _buildCellContent(List<Appointment> appts) {
    if (appts.isEmpty) {
      return Container(
        width: 160,
        alignment: Alignment.center,
        child: Icon(Icons.add_circle_outline, color: Colors.grey.shade300, size: 20),
      );
    }

    final appt = appts.first;
    Color color = switch (appt.status) {
      AppointmentStatus.scheduled => Colors.blue,
      AppointmentStatus.confirmed => Colors.teal,
      AppointmentStatus.inProgress => Colors.orange,
      AppointmentStatus.completed => Colors.green,
      AppointmentStatus.cancelled => Colors.red,
      AppointmentStatus.missed => Colors.red.shade900,
    };

    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appt.patientName,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  appt.procedureName ?? 'Avaliação',
                  style: TextStyle(fontSize: 8, color: color.withOpacity(0.8)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (appts.length > 1)
                Text('+${appts.length - 1}', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime selectedDate, AppointmentViewModel notifier) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      notifier.selectDate(picked);
      notifier.fetchInstitutionalData();
    }
  }
}
