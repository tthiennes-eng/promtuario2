import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promt/features/agenda/presentation/viewmodels/appointment_viewmodel.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:intl/intl.dart';

/// Tela de Agenda Odontológica organizada por Clínica com Filtros, Estatísticas e Horários Livres.
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
    
    // Slots gerados dinamicamente (Ocupados + Livres)
    final slots = state.timeSlots;
    final stats = notifier.getDayStats();

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
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
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
          _buildStatsBar(stats),
          const Divider(height: 1),
          Expanded(
            child: state.appointments.when(
              data: (_) => slots.isEmpty
                  ? _buildEmptyState()
                  : _buildTimeSlotList(slots, state.selectedClinic),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorState(err.toString(), notifier),
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
                  if (clinic.location != null && clinic.location!.isNotEmpty) ...[
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

  Widget _buildStatsBar(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _StatCard(label: 'Total', value: '${stats['total']}', color: Colors.blue, icon: Icons.people),
            const SizedBox(width: 8),
            _StatCard(label: 'Concluídos', value: '${stats['completed']}', color: Colors.green, icon: Icons.check_circle),
            const SizedBox(width: 8),
            _StatCard(label: 'Faltas', value: '${stats['missed']}', color: Colors.red, icon: Icons.person_off),
            const SizedBox(width: 8),
            _StatCard(label: 'Ocupação', value: '${(stats['occupancy'] * 100).toStringAsFixed(1)}%', color: Colors.orange, icon: Icons.pie_chart),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotList(List<TimeSlot> slots, Clinic? selectedClinic) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        if (slot.isFree) {
          return _buildFreeSlot(slot, selectedClinic);
        } else {
          return _buildAppointmentSlot(slot.appointment!);
        }
      },
    );
  }

  Widget _buildFreeSlot(TimeSlot slot, Clinic? selectedClinic) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(
          DateFormat('HH:mm').format(slot.startTime),
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade600),
        ),
        title: Text('Horário Livre', style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF006494)),
          onPressed: () => context.push('/dashboard/agenda/add', extra: {
            'clinic': selectedClinic,
            'time': slot.startTime,
          }),
        ),
      ),
    );
  }

  Widget _buildAppointmentSlot(Appointment appt) {
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
            Text('Aluno: ${appt.studentName ?? "Não atribuído"}', style: const TextStyle(fontSize: 12)),
            Text('Prof: ${appt.professorName ?? "Não atribuído"}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: _buildStatusChip(appt.status),
        onTap: () => _showAppointmentDetails(appt),
      ),
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
          const Text('Nenhum agendamento ou horário configurado.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, AppointmentViewModel notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erro ao carregar agenda: $error'),
          TextButton(
            onPressed: () => notifier.refresh(),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final state = ref.read(appointmentViewModelProvider);
    final notifier = ref.read(appointmentViewModelProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtros Avançados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('Período do Dia', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: DayPeriod.values.map((p) {
                return ChoiceChip(
                  label: Text(p.name == 'all' ? 'Todos' : p.name == 'morning' ? 'Manhã' : p.name == 'afternoon' ? 'Tarde' : 'Noite'),
                  selected: state.period == p,
                  onSelected: (val) {
                    if (val) notifier.setFilters(period: p);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Situação', style: TextStyle(fontWeight: FontWeight.bold)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...AppointmentStatus.values.map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status.displayName),
                        selected: state.filterStatus == status,
                        onSelected: (val) {
                          notifier.setFilters(status: val ? status : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Aluno Responsável', prefixIcon: Icon(Icons.school)),
              onChanged: (val) => notifier.setFilters(student: val.isEmpty ? null : val),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Professor Supervisor', prefixIcon: Icon(Icons.person)),
              onChanged: (val) => notifier.setFilters(professor: val.isEmpty ? null : val),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Procedimento', prefixIcon: Icon(Icons.medical_services)),
              onChanged: (val) => notifier.setFilters(procedure: val.isEmpty ? null : val),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      notifier.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpar Tudo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
            _buildInfoRow(Icons.school_outlined, 'Aluno', appointment.studentName ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person_outline, 'Professor', appointment.professorName ?? 'N/A'),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
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
