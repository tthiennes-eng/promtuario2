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
  String? _selectedClinicName;
  String? _selectedProcedureName;
  
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  final _notesController = TextEditingController();

  final List<String> _clinicOptions = [
    'Clinica I',
    'Clinica II',
    'Clinica III',
    'Clinica IV',
    'Clinica V',
    'Clinica Integrada Infantil',
    'Clinica de Emergência',
    'Clinica Integrada Adulto I',
    'Clinica Integrada Adulto II',
    'Clinica de DTM',
    'Clinica de Odontopediatria',
  ];

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
    'Cirurgia Periodontal',
    'Urgência / Emergência',
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
      _selectedClinicName = widget.initialClinic!.name;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
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
              
              DropdownButtonFormField<String>(
                value: _selectedClinicName,
                isExpanded: true,
                hint: const Text('Selecione a Clínica'),
                decoration: const InputDecoration(
                  labelText: 'Clínica de Atendimento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                items: _clinicOptions.map((name) => DropdownMenuItem(
                  value: name, 
                  child: Text(name)
                )).toList(),
                onChanged: (name) {
                  setState(() {
                    _selectedClinicName = name;
                    clinicsAsync.whenData((list) {
                      try {
                        _selectedClinicId = list.firstWhere((c) => c.name == name).id;
                      } catch (_) {
                        _selectedClinicId = name;
                      }
                    });
                  });
                },
                validator: (v) => v == null ? 'Selecione uma clínica' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: patientsAsync.when(
                      data: (patients) => DropdownButtonFormField<String>(
                        value: _selectedPatientId,
                        isExpanded: true,
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
              const Text('Responsáveis (Campos Editáveis)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 16),

              usersAsync.when(
                data: (users) {
                  final students = users.where((u) => u.role == UserRole.aluno).toList();
                  return Autocomplete<User>(
                    displayStringForOption: (u) => u.name,
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable<User>.empty();
                      return students.where((u) => u.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (u) => setState(() {
                      _selectedStudentId = u.id;
                      _selectedStudentName = u.name;
                    }),
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      if (controller.text.isEmpty && _selectedStudentName != null) {
                        controller.text = _selectedStudentName!;
                      }
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Dupla Responsável', 
                          hintText: 'Digite o nome da dupla',
                          border: OutlineInputBorder(), 
                          prefixIcon: Icon(Icons.group_outlined)
                        ),
                        onChanged: (val) => _selectedStudentName = val,
                        validator: (v) => (v == null || v.isEmpty) ? 'Informe a dupla' : null,
                      );
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Erro ao carregar alunos'),
              ),
              const SizedBox(height: 16),

              usersAsync.when(
                data: (users) {
                  final professors = users.where((u) => u.role == UserRole.professor || u.role == UserRole.coordenador).toList();
                  return Autocomplete<User>(
                    displayStringForOption: (u) => u.name,
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable<User>.empty();
                      return professors.where((u) => u.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (u) => setState(() {
                      _selectedProfessorId = u.id;
                      _selectedProfessorName = u.name;
                    }),
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      if (controller.text.isEmpty && _selectedProfessorName != null) {
                        controller.text = _selectedProfessorName!;
                      }
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Professor Supervisor', 
                          hintText: 'Digite o nome do professor',
                          border: OutlineInputBorder(), 
                          prefixIcon: Icon(Icons.verified_user_outlined)
                        ),
                        onChanged: (val) => _selectedProfessorName = val,
                        validator: (v) => (v == null || v.isEmpty) ? 'Informe o professor' : null,
                      );
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),
              const Text('Procedimento e Horário', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 16),

              proceduresAsync.when(
                data: (procedures) {
                  final allOptions = procedures.isEmpty 
                      ? _defaultProcedures 
                      : procedures.map((p) => p.name).toList();
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedProcedureName,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Procedimento Previsto', border: OutlineInputBorder(), prefixIcon: Icon(Icons.medical_services_outlined)),
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
                decoration: const InputDecoration(labelText: 'Observações Adicionais', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _saveAppointment,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Salvar Agendamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

      final finalClinicId = _selectedClinicId ?? const Uuid().v4();

      final appointment = Appointment(
        id: const Uuid().v4(),
        patientId: _selectedPatientId!,
        patientName: _selectedPatientName!,
        doctorId: _selectedStudentId ?? 'custom', 
        doctorName: _selectedStudentName ?? 'Não informado',
        studentId: _selectedStudentId,
        studentName: _selectedStudentName,
        professorId: _selectedProfessorId,
        professorName: _selectedProfessorName,
        startTime: start,
        endTime: end,
        status: AppointmentStatus.scheduled,
        procedureName: _selectedProcedureName,
        notes: _notesController.text,
        clinicId: finalClinicId,
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
