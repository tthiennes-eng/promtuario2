import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/appointment_viewmodel.dart';
import '../domain/entities/appointment.dart';
import 'package:intl/intl.dart';

/// Tela de Agenda Odontológica.
/// Permite visualizar compromissos diários e gerenciar status das consultas.
class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(appointmentViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Clínica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          const Divider(height: 1),
          Expanded(
            child: appointmentsAsync.when(
              data: (appointments) => appointments.isEmpty
                  ? _buildEmptyState()
                  : _buildAppointmentList(appointments),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/dashboard/agenda/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDate(-1),
          ),
          Text(
            DateFormat('EEEE, d de MMMM', 'pt_BR').format(_selectedDate),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('HH:mm').format(appt.startTime),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            title: Text(appt.patientName),
            subtitle: Text('${appt.procedureName ?? "Consulta"} • ${appt.doctorName}'),
            trailing: _buildStatusChip(appt.status),
            onTap: () => _showAppointmentDetails(appt),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(AppointmentStatus status) {
    Color color = switch (status) {
      AppointmentStatus.scheduled => Colors.blue,
      AppointmentStatus.confirmed => Colors.green,
      AppointmentStatus.inProgress => Colors.orange,
      AppointmentStatus.completed => Colors.grey,
      AppointmentStatus.cancelled => Colors.red,
      AppointmentStatus.missed => Colors.red.shade900,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Nenhuma consulta para este dia', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.patientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Horário'),
              subtitle: Text('${DateFormat('HH:mm').format(appointment.startTime)} - ${DateFormat('HH:mm').format(appointment.endTime)}'),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services_outlined),
              title: const Text('Procedimento'),
              subtitle: Text(appointment.procedureName ?? 'Não informado'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (appointment.status == AppointmentStatus.scheduled)
                  ElevatedButton(
                    onPressed: () {
                      ref.read(appointmentViewModelProvider.notifier).updateStatus(appointment.id, AppointmentStatus.confirmed, _selectedDate);
                      Navigator.pop(context);
                    },
                    child: const Text('Confirmar'),
                  ),
                OutlinedButton(
                  onPressed: () {
                    ref.read(appointmentViewModelProvider.notifier).updateStatus(appointment.id, AppointmentStatus.cancelled, _selectedDate);
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      ref.read(appointmentViewModelProvider.notifier).fetchByDate(picked);
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    ref.read(appointmentViewModelProvider.notifier).fetchByDate(_selectedDate);
  }
}
