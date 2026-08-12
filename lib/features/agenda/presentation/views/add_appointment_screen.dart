import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:promt/features/agenda/presentation/viewmodels/appointment_viewmodel.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';
import 'package:promt/features/users/presentation/viewmodels/user_management_viewmodel.dart';
import 'package:promt/features/procedures/presentation/viewmodels/clinics_viewmodel.dart';
import 'package:promt/features/procedures/presentation/viewmodels/procedures_viewmodel.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/auth/domain/entities/user.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';

/// Tela para "Novo Agendamento" aprimorada.
class AddAppointmentScreen extends ConsumerStatefulWidget {
  final Clinic? initialClinic;
  final DateTime? initialDateTime;

  const AddAppointmentScreen({
    super.key, 
    this.initialClinic,
    this.initialDateTime,
  });

  @override
  ConsumerState<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends ConsumerState<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedPatientId;
  String? _selectedPatientName;
  String? _selectedStudentId;
  String? _selectedStudentName;
  String? _selectedProfessorId;
  String? _selectedProfessorName;
  String? _selectedClinicId;
  String? _selectedProcedureName;
  
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  final _notesController = TextEditingController();
  final _studentSearchController = TextEditingController();

  // Lista de procedimentos padrão expandida
  final List<String> _defaultProcedures = [
    'Avaliação Geral',
    'Profilaxia (Limpeza)',
    'Exodontia Simples',
    'Exodontia de Terceiro Molar',
    'Restauração de Resina',
    'Tratamento Endodôntico (Canal)',
    'Raspagem Periodontal',
    'Aplicação de Flúor',
    'Radiografia Periapical',
    'Prótese Total',
    'Prótese Parcial Removível',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDateTime ?? DateTime.now();
    _startTime = widget.initialDateTime != null 
        ? TimeOfDay.fromDateTime(widget.initialDateTime!)
        : const TimeOfDay(hour: 8, minute: 0);
        
    if (widget.initialClinic != null) {
      _selectedClinicId = widget.initialClinic!.id;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _studentSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientViewModelProvider);
    final usersAsync = ref.watch(userManagementViewModelProvider);
    final clinicsAsync = ref.watch(clinicsViewModelProvider);
    final proceduresAsync = ref.watch(proceduresViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Local e Paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 16),
              
              // 1. Seleção de Clínica
              clinicsAsync.when(
                data: (clinics) => DropdownButtonFormField<String>(
                  value: _selectedClinicId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Clínica de Atendimento',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  items: clinics.map((c) => DropdownMenuItem(
                    value: c.id, 
                    child: Text(c.name)
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedClinicId = val),
                  validator: (v) => v == null ? 'Selecione uma clínica' : null,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Erro ao carregar clínicas'),
              ),
              const SizedBox(height: 16),

              // 2. Seleção de Paciente
              Row(
                children: [
                  Expanded(
                    child: patientsAsync.when(
                      data: (patients) => DropdownButtonFormField<String>(
                        value: _selectedPatientId,
                        decoration: const InputDecoration(
                          labelText: 'Paciente', 
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedPatientId = val;
                            _selectedPatientName = patients.firstWhere((p) => p.id == val).fullName;
                          });
                        },
                        validator: (v) => v == null ? 'Selecione o paciente' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Erro ao carregar pacientes'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => context.push('/dashboard/patients/add'),
                    icon: const Icon(Icons.person_add),
                    tooltip: 'Novo Paciente',
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              const Text('Responsáveis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 16),

              // 3. Dupla Responsável (Editável com busca)
              usersAsync.when(
                data: (users) {
                  final students = users.where((u) => u.role == UserRole.aluno).toList();
                  return Autocomplete<User>(
                    initialValue: TextEditingValue(text: _selectedStudentName ?? ''),
                    displayStringForOption: (u) => u.name,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') return const Iterable<User>.empty();
                      return students.where((u) => u.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (u) => setState(() {
                      _selectedStudentId = u.id;
                      _selectedStudentName = u.name;
                    }),
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Dupla Responsável', 
                          hintText: 'Digite o nome do aluno ou da dupla',
                          border: OutlineInputBorder(), 
                          prefixIcon: Icon(Icons.group_outlined)
                        ),
                        onChanged: (val) => _selectedStudentName = val,
                        validator: (v) => (v == null || v.isEmpty) ? 'Informe o responsável' : null,
                      );
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Erro ao carregar usuários'),
              ),
              const SizedBox(height: 16),

              // 4. Professor Supervisor
              usersAsync.when(
                data: (users) {
                  final professors = users.where((u) => u.role == UserRole.professor || u.role == UserRole.coordenador).toList();
                  return DropdownButtonFormField<String>(
                    value: _selectedProfessorId,
                    decoration: const InputDecoration(labelText: 'Professor Supervisor', border: OutlineInputBorder(), prefixIcon: Icon(Icons.verified_user_outlined)),
                    items: professors.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedProfessorId = val;
                        _selectedProfessorName = professors.firstWhere((u) => u.id == val).name;
                      });
                    },
                    validator: (v) => v == null ? 'Selecione o professor' : null,
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),
              const Text('Procedimento e Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 16),

              // 5. Procedimento Previsto (Mais opções)
              proceduresAsync.when(
                data: (procedures) {
                  final allOptions = procedures.isEmpty 
                      ? _defaultProcedures 
                      : procedures.map((p) => p.name).toList();
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedProcedureName,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Procedimento Previsto', border: OutlineInputBorder(), prefixIcon: Icon(Icons.medical_information_outlined)),
                    items: allOptions.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                    onChanged: (val) => setState(() => _selectedProcedureName = val),
                    validator: (v) => v == null ? 'Selecione o procedimento' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Erro ao carregar procedimentos'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Data', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                        child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (picked != null) setState(() => _startTime = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Hora', border: OutlineInputBorder(), prefixIcon: Icon(Icons.access_time)),
                        child: Text(_startTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações do Agendamento', 
                  hintText: 'Ex: Trazer exames anteriores',
                  border: OutlineInputBorder()
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _saveAppointment,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar Agendamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAppointment() async {
    if (_formKey.currentState!.validate()) {
      final start = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      final end = start.add(const Duration(hours: 1));

      // Verificação de conflitos básica
      final existing = ref.read(appointmentViewModelProvider).appointments.value ?? [];
      final hasConflict = existing.any((a) => 
        a.clinicId == _selectedClinicId && 
        ((start.isAfter(a.startTime) && start.isBefore(a.endTime)) ||
         (start.isAtSameMomentAs(a.startTime))));

      if (hasConflict) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atenção: Já existe um atendimento neste horário.'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      final appointment = Appointment(
        id: const Uuid().v4(),
        patientId: _selectedPatientId!,
        patientName: _selectedPatientName!,
        doctorId: _selectedStudentId ?? 'custom', 
        doctorName: _selectedStudentName!, // Agora usa o valor livre do Autocomplete
        studentId: _selectedStudentId,
        studentName: _selectedStudentName,
        professorId: _selectedProfessorId,
        professorName: _selectedProfessorName,
        startTime: start,
        endTime: end,
        status: AppointmentStatus.scheduled,
        procedureName: _selectedProcedureName,
        notes: _notesController.text,
        clinicId: _selectedClinicId!,
      );

      await ref.read(appointmentViewModelProvider.notifier).schedule(appointment);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento salvo com sucesso!'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
