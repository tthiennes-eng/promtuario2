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
import 'package:promt/features/patients/domain/entities/patient.dart';
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
  ConsumerState<AddAppointmentScreen> createState() =>
      _AddAppointmentScreenState();
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
      _selectedClinicName = widget.initialClinic!.name;
      if (_isUuid(widget.initialClinic!.id)) {
        _selectedClinicId = widget.initialClinic!.id;
      } else {
        _selectedClinicId = _deterministicUuid(widget.initialClinic!.name);
      }
    }

    Future.microtask(() {
      if (!mounted) return;
      final current = ref.read(patientViewModelProvider);
      if (current.hasError || (current.valueOrNull?.isEmpty ?? true)) {
        ref.read(patientViewModelProvider.notifier).refresh();
      }
    });
  }

  String _deterministicUuid(String value) {
    return const Uuid().v5(Uuid.NAMESPACE_URL, 'promtuario-clinic:$value');
  }

  String _fallbackDoctorId() {
    if (_isUuid(_selectedStudentId)) return _selectedStudentId!;
    if (_isUuid(_selectedProfessorId)) return _selectedProfessorId!;

    final usersAsync = ref.read(userManagementViewModelProvider);
    final fallback = usersAsync.when(
      data: (users) {
        final candidates = users.where(
          (u) =>
              u.role == UserRole.professor ||
              u.role == UserRole.coordenador ||
              u.role == UserRole.aluno,
        );
        final first = candidates.isNotEmpty ? candidates.first : null;
        return _isUuid(first?.id) ? first!.id : null;
      },
      loading: () => null,
      error: (_, __) => null,
    );

    return fallback ?? '00000000-0000-0000-0000-000000000000';
  }

  bool _isUuid(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
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
      appBar: AppBar(title: const Text('Novo Agendamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Local e Paciente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 16),

              Builder(
                builder: (context) {
                  final uniqueByKey = <String, String>{};
                  for (final clinic in clinicsAsync.valueOrNull ?? const <Clinic>[]) {
                    final key = Clinic.normalizeName(clinic.name);
                    if (key.isNotEmpty) uniqueByKey.putIfAbsent(key, () => clinic.name);
                  }
                  for (final option in _clinicOptions) {
                    final key = Clinic.normalizeName(option);
                    if (key.isNotEmpty) uniqueByKey.putIfAbsent(key, () => option);
                  }
                  String? effectiveSelected = _selectedClinicName;
                  if (effectiveSelected != null) {
                    final key = Clinic.normalizeName(effectiveSelected);
                    effectiveSelected = uniqueByKey.putIfAbsent(
                      key,
                      () => effectiveSelected!,
                    );
                  }
                  final sortedNames = uniqueByKey.values.toList()
                    ..sort(Clinic.compareNames);

                  return DropdownButtonFormField<String>(
                    value: effectiveSelected,
                    isExpanded: true,
                    hint: const Text('Selecione a Clínica'),
                    decoration: const InputDecoration(
                      labelText: 'Clínica de Atendimento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    items: sortedNames
                        .map(
                          (name) =>
                              DropdownMenuItem(value: name, child: Text(name)),
                        )
                        .toList(),
                    onChanged: (name) {
                      setState(() {
                        _selectedClinicName = name;
                        _selectedClinicId = name == null
                            ? null
                            : _deterministicUuid(name);
                        clinicsAsync.whenData((list) {
                          if (name == null) return;
                          final targetKey = Clinic.normalizeName(name);
                          try {
                            final clinic = list.firstWhere(
                              (c) => Clinic.normalizeName(c.name) == targetKey,
                            );
                            if (_isUuid(clinic.id)) {
                              _selectedClinicId = clinic.id;
                              return;
                            }
                          } catch (_) {}
                          _selectedClinicId = _deterministicUuid(name);
                        });
                      });
                    },
                    validator: (v) => v == null
                        ? 'Selecione uma clínica'
                        : (!_isUuid(_selectedClinicId)
                              ? 'A clínica selecionada não possui um ID válido no servidor'
                              : null),
                  );
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: patientsAsync.when(
                      data: (patients) => Autocomplete<Patient>(
                        displayStringForOption: (p) => p.fullName,
                        initialValue: TextEditingValue(
                          text: _selectedPatientName ?? '',
                        ),
                        optionsBuilder: (textEditingValue) {
                          if (textEditingValue.text.isEmpty)
                            return const Iterable<Patient>.empty();
                          return patients.where(
                            (p) =>
                                p.fullName.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase(),
                                ) ||
                                p.cpf.contains(textEditingValue.text),
                          );
                        },
                        onSelected: (p) => setState(() {
                          _selectedPatientId = p.id;
                          _selectedPatientName = p.fullName;
                        }),
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Pesquisar Paciente (Nome ou CPF)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person_search),
                                  hintText: 'Digite para buscar...',
                                ),
                                onChanged: (val) {
                                  // Se o usuário apagar o texto, limpa a seleção
                                  if (val.isEmpty) {
                                    setState(() {
                                      _selectedPatientId = null;
                                      _selectedPatientName = null;
                                    });
                                  }
                                },
                                validator: (v) => _selectedPatientId == null
                                    ? 'Selecione um paciente da lista'
                                    : null,
                              );
                            },
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) => Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Erro ao carregar pacientes: $err',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => ref
                                .read(patientViewModelProvider.notifier)
                                .refresh(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () async {
                      await context.push('/dashboard/patients/add');
                      if (mounted) {
                        ref.read(patientViewModelProvider.notifier).refresh();
                      }
                    },
                    icon: const Icon(Icons.person_add),
                    tooltip: 'Novo Paciente',
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Text(
                'Responsáveis (Campos Editáveis)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 16),

              usersAsync.when(
                data: (users) {
                  final students = users
                      .where((u) => u.role == UserRole.aluno)
                      .toList();
                  return Autocomplete<User>(
                    displayStringForOption: (u) => u.name,
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty)
                        return const Iterable<User>.empty();
                      return students.where(
                        (u) => u.name.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },
                    onSelected: (u) => setState(() {
                      _selectedStudentId = u.id;
                      _selectedStudentName = u.name;
                    }),
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          if (controller.text.isEmpty &&
                              _selectedStudentName != null) {
                            controller.text = _selectedStudentName!;
                          }
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Dupla Responsável',
                              hintText: 'Digite o nome da dupla',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.group_outlined),
                            ),
                            onChanged: (val) => setState(() {
                              _selectedStudentName = val;
                              _selectedStudentId = null;
                            }),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Informe a dupla'
                                : null,
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
                  final professors = users
                      .where(
                        (u) =>
                            u.role == UserRole.professor ||
                            u.role == UserRole.coordenador,
                      )
                      .toList();
                  return Autocomplete<User>(
                    displayStringForOption: (u) => u.name,
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty)
                        return const Iterable<User>.empty();
                      return professors.where(
                        (u) => u.name.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },
                    onSelected: (u) => setState(() {
                      _selectedProfessorId = u.id;
                      _selectedProfessorName = u.name;
                    }),
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          if (controller.text.isEmpty &&
                              _selectedProfessorName != null) {
                            controller.text = _selectedProfessorName!;
                          }
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Professor Supervisor',
                              hintText: 'Digite o nome do professor',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.verified_user_outlined),
                            ),
                            onChanged: (val) => setState(() {
                              _selectedProfessorName = val;
                              _selectedProfessorId = null;
                            }),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Informe o professor'
                                : null,
                          );
                        },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),
              const Text(
                'Procedimento e Horário',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 16),

              proceduresAsync.when(
                data: (procedures) {
                  final allOptions = procedures.isEmpty
                      ? _defaultProcedures
                      : procedures.map((p) => p.name).toList();

                  return DropdownButtonFormField<String>(
                    value: _selectedProcedureName,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Procedimento Previsto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                    items: allOptions
                        .map(
                          (name) =>
                              DropdownMenuItem(value: name, child: Text(name)),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedProcedureName = val),
                    validator: (v) =>
                        v == null ? 'Selecione o procedimento' : null,
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
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                        ),
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
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações Adicionais',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _saveAppointment,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Salvar Agendamento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
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

      String finalClinicId = _selectedClinicId!;
      final selectedName = _selectedClinicName;
      if (selectedName != null && selectedName.isNotEmpty) {
        final targetKey = Clinic.normalizeName(selectedName);
        final availableClinics = <Clinic>[
          ...(ref.read(clinicsViewModelProvider).valueOrNull ?? const <Clinic>[]),
          ...ref.read(appointmentViewModelProvider).clinics,
        ];
        for (final clinic in availableClinics) {
          if (Clinic.normalizeName(clinic.name) == targetKey && _isUuid(clinic.id)) {
            finalClinicId = clinic.id;
            break;
          }
        }
      }
      final finalDoctorId = _fallbackDoctorId();

      final appointment = Appointment(
        id: const Uuid().v4(),
        patientId: _selectedPatientId!,
        patientName: _selectedPatientName!,
        doctorId: finalDoctorId,
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
        clinicName: selectedName,
      );

      try {
        await ref
            .read(appointmentViewModelProvider.notifier)
            .schedule(appointment);
        if (!mounted) return;
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento salvo com sucesso!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
