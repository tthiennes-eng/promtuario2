import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promt/features/agenda/presentation/viewmodels/appointment_viewmodel.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:intl/intl.dart';

/// Tela de Agenda Odontológica organizada por Clínica.
class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentViewModelProvider);
    final notifier = ref.read(appointmentViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda por Clínica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            tooltip: 'Visão Institucional',
            onPressed: () => context.push('/dashboard/agenda/institutional'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildClinicSelector(state, notifier),
          _buildDateSelector(state.selectedDate, notifier),
          const Divider(height: 1),
          Expanded(
            child: state.appointments.when(
              data: (appointments) => appointments.isEmpty
                  ? _buildEmptyState()
                  : _buildAppointmentList(appointments),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar agenda: $err'),
                    TextButton(
                      onPressed: () => notifier.refresh(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/dashboard/agenda/add', extra: state.selectedClinic),
        label: const Text('Novo Agendamento'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildClinicSelector(AppointmentState state, AppointmentViewModel notifier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Clinic>(
          value: state.selectedClinic,
          isExpanded: true,
          hint: const Text('Selecione uma Clínica'),
          items: state.clinics.map((clinic) {
            return DropdownMenuItem(
              value: clinic,
              child: Row(
                children: [
                  const Icon(Icons.local_hospital_outlined, size: 20, color: Color(0xFF006494)),
                  const SizedBox(width: 12),
                  Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (clinic.location != null) ...[
                    const SizedBox(width: 8),
                    Text('(${clinic.location})', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: (clinic) {
            if (clinic != null) notifier.selectClinic(clinic);
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector(DateTime selectedDate, AppointmentViewModel notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => notifier.selectDate(selectedDate.subtract(const Duration(days: 1))),
          ),
          InkWell(
            onTap: () => _selectDate(context, selectedDate, notifier),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                DateFormat('EEEE, d de MMMM', 'pt_BR').format(selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF006494)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => notifier.selectDate(selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    // Ordenar por horário
    final sortedAppointments = [...appointments]..sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedAppointments.length,
      itemBuilder: (context, index) {
        final appt = sortedAppointments[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('HH:mm').format(appt.startTime),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  DateFormat('HH:mm').format(appt.endTime),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            title: Text(appt.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(appt.procedureName ?? 'Procedimento não informado', style: const TextStyle(color: Color(0xFF006494))),
                Text('Responsável: ${appt.doctorName}', style: const TextStyle(fontSize: 12)),
              ],
            ),
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
      AppointmentStatus.confirmed => Colors.teal,
      AppointmentStatus.inProgress => Colors.orange,
      AppointmentStatus.completed => Colors.green,
      AppointmentStatus.cancelled => Colors.red,
      AppointmentStatus.missed => Colors.red.shade900,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Nenhum agendamento para esta data e clínica.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(appointment.patientName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                _buildStatusChip(appointment.status),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.access_time, 'Horário', '${DateFormat('HH:mm').format(appointment.startTime)} às ${DateFormat('HH:mm').format(appointment.endTime)}'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.medical_services_outlined, 'Procedimento', appointment.procedureName ?? 'Consulta de Avaliação'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person_outline, 'Responsável', appointment.doctorName),
            const SizedBox(height: 12),
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              _buildInfoRow(Icons.notes, 'Observações', appointment.notes!),
            const SizedBox(height: 32),
            const Text('Ações Disponíveis', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (appointment.status == AppointmentStatus.scheduled)
                  _ActionButton(
                    icon: Icons.check_circle_outline,
                    label: 'Confirmar',
                    onPressed: () {
                      ref.read(appointmentViewModelProvider.notifier).updateStatus(appointment.id, AppointmentStatus.confirmed);
                      Navigator.pop(context);
                    },
                  ),
                if (appointment.status == AppointmentStatus.confirmed)
                  _ActionButton(
                    icon: Icons.play_circle_outline,
                    label: 'Iniciar Atendimento',
                    onPressed: () {
                      ref.read(appointmentViewModelProvider.notifier).updateStatus(appointment.id, AppointmentStatus.inProgress);
                      Navigator.pop(context);
                    },
                  ),
                if (appointment.status == AppointmentStatus.inProgress)
                  _ActionButton(
                    icon: Icons.done_all,
                    label: 'Concluir',
                    onPressed: () {
                      ref.read(appointmentViewModelProvider.notifier).updateStatus(appointment.id, AppointmentStatus.completed);
                      Navigator.pop(context);
                    },
                  ),
                _ActionButton(
                  icon: Icons.cancel_outlined,
                  label: 'Cancelar',
                  isDanger: true,
                  onPressed: () {
                    ref.read(appointmentViewModelProvider.notifier).updateStatus(appointment.id, AppointmentStatus.cancelled);
                    Navigator.pop(context);
                  },
                ),
                _ActionButton(
                  icon: Icons.person_off_outlined,
                  label: 'Ausência',
                  isDanger: true,
                  onPressed: () {
                    ref.read(appointmentViewModelProvider.notifier).updateStatus(appointment.id, AppointmentStatus.missed);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
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
    if (picked != null && picked != selectedDate) {
      notifier.selectDate(picked);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDanger;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDanger ? Colors.red : null,
          side: isDanger ? const BorderSide(color: Colors.red) : null,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
