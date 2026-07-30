import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:promt/features/agenda/presentation/viewmodels/appointment_viewmodel.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';

class InstitutionalAgendaScreen extends ConsumerStatefulWidget {
  const InstitutionalAgendaScreen({super.key});

  @override
  ConsumerState<InstitutionalAgendaScreen> createState() => _InstitutionalAgendaScreenState();
}

class _InstitutionalAgendaScreenState extends ConsumerState<InstitutionalAgendaScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<int> _workingHours = List.generate(13, (index) => index + 7); // 07:00 às 19:00

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão Institucional'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          Expanded(
            child: state.clinics.isEmpty
                ? const Center(child: Text('Nenhuma clínica cadastrada'))
                : _buildGrid(state.clinics, state.appointments.value ?? []),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
          ),
          Text(
            DateFormat('EEEE, d de MMMM', 'pt_BR').format(_selectedDate),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF006494)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
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
          headingRowColor: MaterialStateProperty.all(const Color(0xFF006494).withOpacity(0.1)),
          columns: [
            const DataColumn(label: Text('Horário', style: TextStyle(fontWeight: FontWeight.bold))),
            ...clinics.map((c) => DataColumn(
              label: Container(
                width: 150,
                child: Text(c.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            )),
          ],
          rows: _workingHours.map((hour) {
            return DataRow(
              cells: [
                DataCell(Text(DateFormat('HH:00').format(DateTime(2024, 1, 1, hour)))),
                ...clinics.map((clinic) {
                  final appt = _findAppointment(appointments, clinic.id, hour);
                  return DataCell(_buildCellContent(appt));
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Appointment? _findAppointment(List<Appointment> allAppointments, String clinicId, int hour) {
    // Para simplificar a visão institucional, buscamos o compromisso que inicia naquela hora na clínica
    try {
      return allAppointments.firstWhere(
        (a) => a.clinicId == clinicId && 
               a.startTime.day == _selectedDate.day &&
               a.startTime.hour == hour
      );
    } catch (_) {
      return null;
    }
  }

  Widget _buildCellContent(Appointment? appt) {
    if (appt == null) {
      return Container(
        width: 150,
        alignment: Alignment.center,
        child: Text('-', style: TextStyle(color: Colors.grey.shade400)),
      );
    }

    Color color = switch (appt.status) {
      AppointmentStatus.scheduled => Colors.blue,
      AppointmentStatus.confirmed => Colors.teal,
      AppointmentStatus.inProgress => Colors.orange,
      AppointmentStatus.completed => Colors.green,
      AppointmentStatus.cancelled => Colors.red,
      AppointmentStatus.missed => Colors.red.shade900,
    };

    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appt.patientName,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            appt.status.displayName,
            style: TextStyle(fontSize: 9, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }
}
