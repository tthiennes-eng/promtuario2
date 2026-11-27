import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promt/features/agenda/presentation/viewmodels/appointment_viewmodel.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:intl/intl.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentViewModelProvider);
    final notifier = ref.read(appointmentViewModelProvider.notifier);
    final stats = notifier.getDayStats();
    
    final List<dynamic> displayItems = state.selectedClinic == null 
        ? (state.appointments.value ?? []) 
        : state.timeSlots;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Agenda por Clínica'),
        actions: [
          IconButton(icon: const Icon(Icons.grid_view), tooltip: 'Quadro Geral', onPressed: () => context.push('/dashboard/agenda/institutional')),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => notifier.refresh()),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
            child: Column(
              children: [
                _buildClinicSelector(state, notifier),
                const SizedBox(height: 16),
                _buildDateNavigator(state.selectedDate, notifier),
              ],
            ),
          ),
          _buildSummaryDashboard(stats),
          const Divider(height: 1),
          Expanded(
            child: state.appointments.when(
              data: (_) => displayItems.isEmpty
                  ? _buildEmptyState()
                  : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: displayItems.length,
                        itemBuilder: (context, index) {
                          final item = displayItems[index];
                          if (item is Appointment) {
                            return _buildAppointmentCard(item, showClinic: state.selectedClinic == null);
                          } else if (item is TimeSlot) {
                            return item.isFree 
                                ? _buildFreeSlotCard(item, state.selectedClinic)
                                : _buildAppointmentCard(item.appointment!, showClinic: false);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorState(err.toString(), notifier),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF006494),
        onPressed: () {
          final freeSlots = state.timeSlots.where((s) => s.isFree);
          final defaultTime = freeSlots.isNotEmpty
              ? freeSlots.first.startTime
              : DateTime(
                  state.selectedDate.year,
                  state.selectedDate.month,
                  state.selectedDate.day,
                  state.selectedClinic?.startHour ?? 8,
                  0,
                );
          context.push(
            '/dashboard/agenda/add',
            extra: {'clinic': state.selectedClinic, 'time': defaultTime},
          );
        },
        label: const Text('NOVO AGENDAMENTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildClinicSelector(AppointmentState state, AppointmentViewModel notifier) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Clinic?>(
          value: state.selectedClinic,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Color(0xFF006494)),
          items: [
            const DropdownMenuItem<Clinic?>(
              value: null,
              child: Row(children: [Icon(Icons.auto_awesome_motion, size: 20, color: Color(0xFF006494)), SizedBox(width: 12), Text('VISÃO GERAL (TODAS AS CLÍNICAS)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006494)))]),
            ),
            ...state.clinics.map((clinic) => DropdownMenuItem<Clinic?>(value: clinic, child: Row(children: [const Icon(Icons.local_hospital_outlined, size: 20, color: Colors.blueGrey), const SizedBox(width: 12), Text(clinic.name)]))),
          ],
          onChanged: (clinic) => notifier.selectClinic(clinic),
        ),
      ),
    );
  }

  Widget _buildDateNavigator(DateTime selectedDate, AppointmentViewModel notifier) {
    final dayOfWeek = DateFormat('EEEE', 'pt_BR').format(selectedDate);
    final monthName = DateFormat('MMMM', 'pt_BR').format(selectedDate);
    final formattedDate = "${dayOfWeek[0].toUpperCase()}${dayOfWeek.substring(1)}, ${selectedDate.day} de ${monthName[0].toUpperCase()}${monthName.substring(1)}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton.filledTonal(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => notifier.selectDate(selectedDate.subtract(const Duration(days: 1)))),
        InkWell(
          onTap: () => _selectDate(context, selectedDate, notifier),
          child: Column(children: [Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E293B))), const Text('Toque para escolher outra data', style: TextStyle(fontSize: 10, color: Colors.blueGrey))]),
        ),
        IconButton.filledTonal(icon: const Icon(Icons.arrow_forward_ios, size: 18), onPressed: () => notifier.selectDate(selectedDate.add(const Duration(days: 1)))),
      ],
    );
  }

  Widget _buildSummaryDashboard(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _StatTile(label: 'Agendados', value: '${stats['total']}', color: Colors.blue, icon: Icons.people_outline),
          const SizedBox(width: 8),
          _StatTile(label: 'Atendidos', value: '${stats['completed']}', color: Colors.green, icon: Icons.task_alt),
          const SizedBox(width: 8),
          _StatTile(label: 'Faltas', value: '${stats['missed']}', color: Colors.red, icon: Icons.person_off_outlined),
        ],
      ),
    );
  }

  Widget _buildFreeSlotCard(TimeSlot slot, Clinic? selectedClinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withValues(alpha: 0.15))),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Container(width: 50, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(DateFormat('HH:mm').format(slot.startTime), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
          title: const Text('Horário Disponível', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
          trailing: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
          onTap: () => context.push(
            '/dashboard/agenda/add',
            extra: {'clinic': selectedClinic, 'time': slot.startTime},
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appt, {required bool showClinic}) {
    final now = DateTime.now();
    final bool isLate = appt.status == AppointmentStatus.scheduled && appt.startTime.isBefore(now);
    final clinics = ref.read(appointmentViewModelProvider).clinics;
    final clinicLabel = Clinic.resolveDisplayName(
      clinicId: appt.clinicId,
      clinicName: appt.clinicName,
      clinics: clinics,
    );
    final displayPatient = appt.patientName.trim().isNotEmpty
        ? appt.patientName.toUpperCase()
        : 'PACIENTE NÃO INFORMADO';
    
    int? delayMinutes;
    if (appt.actualStartTime != null) {
      delayMinutes = appt.actualStartTime!.difference(appt.startTime).inMinutes;
    } else if (appt.arrivalTime != null) {
      delayMinutes = appt.arrivalTime!.difference(appt.startTime).inMinutes;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: isLate ? Colors.red.shade200 : Colors.grey.shade200, width: isLate ? 2 : 1)
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: (isLate ? Colors.red : const Color(0xFF006494)).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(DateFormat('HH:mm').format(appt.startTime), style: TextStyle(fontWeight: FontWeight.bold, color: isLate ? Colors.red : const Color(0xFF006494), fontSize: 14)),
                  Text(DateFormat('HH:mm').format(appt.endTime), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(child: Text(displayPatient, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)))),
              if (delayMinutes != null && delayMinutes > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                  child: Text('+$delayMinutes min', style: TextStyle(color: Colors.red.shade900, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(appt.procedureName ?? 'Avaliação', style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
              Text('Local: $clinicLabel', style: const TextStyle(fontSize: 11, color: Color(0xFF006494), fontWeight: FontWeight.bold)),
              Text('Responsável: ${appt.studentName ?? "Não inf."}', style: const TextStyle(fontSize: 11)),
              if (appt.arrivalTime != null) 
                Text('Chegada: ${DateFormat('HH:mm').format(appt.arrivalTime!)}', style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          trailing: _buildStatusChip(appt.status),
          onTap: () => _showAppointmentDetails(appt),
        ),
      ),
    );
  }

  void _showAppointmentDetails(Appointment appt) {
    final notifier = ref.read(appointmentViewModelProvider.notifier);
    final clinics = ref.read(appointmentViewModelProvider).clinics;
    final clinicLabel = Clinic.resolveDisplayName(
      clinicId: appt.clinicId,
      clinicName: appt.clinicName,
      clinics: clinics,
    );
    final displayPatient = appt.patientName.trim().isNotEmpty
        ? appt.patientName.toUpperCase()
        : 'PACIENTE NÃO INFORMADO';
    
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
                Expanded(child: Text(displayPatient, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006494)))),
                _buildStatusChip(appt.status),
              ],
            ),
            const SizedBox(height: 24),
            _infoRow(Icons.local_hospital_outlined, 'Local (Clínica)', clinicLabel),
            _infoRow(Icons.access_time, 'Horário', '${DateFormat('HH:mm').format(appt.startTime)} às ${DateFormat('HH:mm').format(appt.endTime)}'),
            _infoRow(Icons.medical_services_outlined, 'Procedimento', appt.procedureName ?? 'Avaliação Geral'),
            _infoRow(Icons.school_outlined, 'Responsável (Aluno)', appt.studentName ?? 'Não atribuído'),
            _infoRow(Icons.person_outline, 'Supervisor (Professor)', appt.professorName ?? 'Não atribuído'),
            if (appt.notes != null && appt.notes!.isNotEmpty) _infoRow(Icons.notes, 'Observações', appt.notes!),
            const SizedBox(height: 32),
            const Text('Ações do Agendamento', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionBtn(
                  icon: Icons.folder_shared_outlined,
                  label: 'Abrir Prontuário',
                  color: const Color(0xFF006494),
                  onPressed: () {
                    Navigator.pop(context);
                    _openPatientProntuario(appt);
                  },
                ),

                if (appt.status != AppointmentStatus.completed &&
                    appt.status != AppointmentStatus.cancelled)
                  _ActionBtn(
                    icon: Icons.edit_calendar_outlined,
                    label: 'Reagendar',
                    color: Colors.purple,
                    onPressed: () {
                      Navigator.pop(context);
                      _showRescheduleDialog(appt, notifier);
                    },
                  ),

                if (appt.arrivalTime == null &&
                    appt.status != AppointmentStatus.completed &&
                    appt.status != AppointmentStatus.cancelled &&
                    appt.status != AppointmentStatus.noShow &&
                    appt.status != AppointmentStatus.missed)
                  _ActionBtn(
                    icon: Icons.hail,
                    label: 'Registrar Chegada',
                    color: Colors.indigo,
                    onPressed: () => _runAppointmentAction(
                      sheetContext: context,
                      action: () => notifier.registerArrival(appt.id),
                      successMessage: 'Chegada registrada com sucesso.',
                    ),
                  ),

                if (appt.status == AppointmentStatus.scheduled ||
                    appt.status == AppointmentStatus.confirmed ||
                    appt.status == AppointmentStatus.arrived)
                  _ActionBtn(
                    icon: Icons.play_arrow,
                    label: 'Iniciar Atendimento',
                    color: Colors.orange,
                    onPressed: () => _runAppointmentAction(
                      sheetContext: context,
                      action: () => notifier.registerStart(appt.id),
                      successMessage: 'Atendimento iniciado.',
                    ),
                  ),

                if (appt.status == AppointmentStatus.inProgress)
                  _ActionBtn(
                    icon: Icons.done_all,
                    label: 'Finalizar Atendimento',
                    color: Colors.green,
                    onPressed: () => _runAppointmentAction(
                      sheetContext: context,
                      action: () => notifier.registerFinish(appt.id),
                      successMessage: 'Atendimento finalizado.',
                    ),
                  ),

                if (appt.status == AppointmentStatus.scheduled)
                  _ActionBtn(
                    icon: Icons.check_circle,
                    label: 'Confirmar',
                    color: Colors.teal,
                    onPressed: () => _runAppointmentAction(
                      sheetContext: context,
                      action: () => notifier.updateStatus(appt.id, AppointmentStatus.confirmed),
                      successMessage: 'Agendamento confirmado.',
                    ),
                  ),

                if (appt.status != AppointmentStatus.noShow &&
                    appt.status != AppointmentStatus.missed &&
                    appt.status != AppointmentStatus.completed)
                  _ActionBtn(
                    icon: Icons.person_off,
                    label: 'Falta',
                    color: Colors.red,
                    onPressed: () => _runAppointmentAction(
                      sheetContext: context,
                      action: () => notifier.updateStatus(appt.id, AppointmentStatus.noShow),
                      successMessage: 'Falta registrada com sucesso.',
                    ),
                  ),

                if (appt.status != AppointmentStatus.cancelled &&
                    appt.status != AppointmentStatus.completed)
                  _ActionBtn(
                    icon: Icons.cancel,
                    label: 'Cancelar',
                    color: Colors.grey,
                    onPressed: () => _runAppointmentAction(
                      sheetContext: context,
                      action: () => notifier.updateStatus(appt.id, AppointmentStatus.cancelled),
                      successMessage: 'Agendamento cancelado.',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openPatientProntuario(Appointment appt) {
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

  Future<void> _showRescheduleDialog(Appointment appt, AppointmentViewModel notifier) async {
    final localStart = appt.startTime.isUtc ? appt.startTime.toLocal() : appt.startTime;
    final duration = appt.endTime.difference(appt.startTime);
    final safeDuration = duration.inMinutes > 0 ? duration : const Duration(hours: 1);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: localStart,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(localStart),
    );
    if (pickedTime == null || !mounted) return;

    final newStart = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    final newEnd = newStart.add(safeDuration);

    try {
      await notifier.reschedule(appt.id, newStart, newEnd);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consulta reagendada para ${DateFormat('dd/MM/yyyy HH:mm').format(newStart)}.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _runAppointmentAction({
    required BuildContext sheetContext,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    Navigator.pop(sheetContext);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))])),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AppointmentStatus status) {
    final Color color;
    switch (status) {
      case AppointmentStatus.scheduled:
        color = Colors.blue;
        break;
      case AppointmentStatus.confirmed:
        color = Colors.teal;
        break;
      case AppointmentStatus.arrived:
        color = Colors.indigo;
        break;
      case AppointmentStatus.inProgress:
        color = Colors.orange;
        break;
      case AppointmentStatus.completed:
        color = Colors.green;
        break;
      case AppointmentStatus.cancelled:
        color = Colors.grey;
        break;
      case AppointmentStatus.noShow:
      case AppointmentStatus.missed:
        color = Colors.red;
        break;
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text(status.displayName, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)));
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.event_note, size: 64, color: Colors.grey.shade300), const SizedBox(height: 16), const Text('Nenhum agendamento para este dia.', style: TextStyle(color: Colors.grey, fontSize: 15))]));
  }

  Widget _buildErrorState(String error, AppointmentViewModel notifier) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.cloud_off, color: Colors.red, size: 48), const SizedBox(height: 16), Text('Erro na conexão: $error', style: const TextStyle(color: Colors.red)), TextButton(onPressed: () => notifier.refresh(), child: const Text('Tentar Novamente'))]));
  }

  Future<void> _selectDate(BuildContext context, DateTime selectedDate, AppointmentViewModel notifier) async {
    final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100), locale: const Locale('pt', 'BR'));
    if (picked != null) notifier.selectDate(picked);
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatTile({required this.label, required this.value, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.1))), child: Column(children: [Icon(icon, size: 14, color: color), const SizedBox(height: 4), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)), Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 8, fontWeight: FontWeight.bold))])));
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}
