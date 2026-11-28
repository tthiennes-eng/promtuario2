import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  final Patient? patient;
  const AddPatientScreen({super.key, this.patient});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _socialNameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _susNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();

  DateTime? _selectedBirthDate;
  String _selectedGender = 'M'; // Padrão Masculino

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      final p = widget.patient!;
      _nameController.text = p.fullName;
      _socialNameController.text = p.socialName ?? '';
      _cpfController.text = p.cpf;
      _susNumberController.text = p.susNumber ?? '';
      _emailController.text = p.email ?? '';
      _phoneController.text = p.phone ?? '';
      _selectedBirthDate = p.birthDate;
      _birthDateController.text = DateFormat('dd/MM/yyyy').format(p.birthDate);
      final normalizedGender = (p.gender ?? '').trim().toLowerCase();
      _selectedGender = (normalizedGender == 'f' ||
              normalizedGender == 'feminino' ||
              normalizedGender == 'fem')
          ? 'F'
          : 'M';

      if (p.address != null) {
        _streetController.text = p.address!.street;
        _numberController.text = p.address!.number;
        _neighborhoodController.text = p.address!.neighborhood;
        _cityController.text = p.address!.city;
        _zipCodeController.text = p.address!.zipCode;
      }
    }
  }

  @override
  void dispose() {
    for (var controller in [
      _nameController,
      _socialNameController,
      _cpfController,
      _susNumberController,
      _emailController,
      _phoneController,
      _birthDateController,
      _streetController,
      _numberController,
      _neighborhoodController,
      _cityController,
      _zipCodeController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final patient = Patient(
          id: widget.patient?.id ?? const Uuid().v4(),
          fullName: _nameController.text.trim(),
          socialName: _socialNameController.text.trim().isEmpty
              ? null
              : _socialNameController.text.trim(),
          cpf: _cpfController.text.replaceAll(RegExp(r'[^\d]'), ''),
          susNumber:
              _susNumberController.text.replaceAll(RegExp(r'[^\d]'), '').isEmpty
              ? null
              : _susNumberController.text.replaceAll(RegExp(r'[^\d]'), ''),
          birthDate: _selectedBirthDate!,
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          gender: _selectedGender,
          address: PatientAddress(
            street: _streetController.text.trim(),
            number: _numberController.text.trim(),
            complement: widget.patient?.address?.complement,
            neighborhood: _neighborhoodController.text.trim(),
            city: _cityController.text.trim(),
            state: (widget.patient?.address?.state.trim().isNotEmpty ?? false)
                ? widget.patient!.address!.state.trim()
                : 'MA',
            zipCode: _zipCodeController.text.trim(),
          ),
          createdAt: widget.patient?.createdAt ?? DateTime.now(),
          lgpdConsent: widget.patient?.lgpdConsent ?? true,
        );

        if (widget.patient == null) {
          await ref.read(patientViewModelProvider.notifier).addPatient(patient);
        } else {
          await ref
              .read(patientViewModelProvider.notifier)
              .editPatient(patient);
        }

        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.patient == null
                    ? 'Paciente cadastrado!'
                    : 'Alterações salvas!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final msg = e.toString().replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $msg'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patient != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Paciente' : 'Admitir Novo Paciente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informações Gerais',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006494),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _socialNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Social',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(
                        labelText: 'CPF',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (v) {
                        final digits =
                            v?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
                        return digits.length == 11
                            ? null
                            : 'CPF inválido (11 dígitos)';
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _susNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número do SUS',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      validator: (v) {
                        final digits =
                            v?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
                        return digits.isEmpty || digits.length == 15
                            ? null
                            : 'O SUS deve conter 15 dígitos';
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Sexo',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'M', child: Text('Masc.')),
                        DropdownMenuItem(value: 'F', child: Text('Fem.')),
                      ],
                      onChanged: (v) => setState(() => _selectedGender = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _birthDateController,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(
                            const Duration(days: 365 * 20),
                          ),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedBirthDate = date;
                            _birthDateController.text = DateFormat(
                              'dd/MM/yyyy',
                            ).format(date);
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nascimento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Celular/WhatsApp',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail para contato',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Endereço integrado agora
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(
                        labelText: 'Logradouro (Rua/Av)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(
                        labelText: 'Nº',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _neighborhoodController,
                      decoration: const InputDecoration(
                        labelText: 'Bairro',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _zipCodeController,
                      decoration: const InputDecoration(
                        labelText: 'CEP',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF006494),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing
                              ? 'SALVAR ALTERAÇÕES'
                              : 'FINALIZAR ADMISSÃO',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
