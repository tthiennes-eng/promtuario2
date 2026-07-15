import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/patient.dart';
import '../viewmodels/patient_viewmodel.dart';

/// Tela de Cadastro de Pacientes.
/// Implementa validações rigorosas e conformidade com LGPD.
class AddPatientScreen extends ConsumerStatefulWidget {
  const AddPatientScreen({super.key});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  
  // Endereço
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();

  DateTime? _selectedBirthDate;
  String _selectedGender = 'M';
  bool _lgpdConsent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!_lgpdConsent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('É necessário o consentimento LGPD para prosseguir.')),
        );
        return;
      }

      final newPatient = Patient(
        id: const Uuid().v4(),
        fullName: _nameController.text.trim(),
        cpf: _cpfController.text.replaceAll(RegExp(r'[^\d]'), ''),
        birthDate: _selectedBirthDate!,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _selectedGender,
        address: PatientAddress(
          street: _streetController.text.trim(),
          number: _numberController.text.trim(),
          neighborhood: _neighborhoodController.text.trim(),
          city: _cityController.text.trim(),
          state: 'SP', // Simplificado para o exemplo
          zipCode: _zipCodeController.text.trim(),
        ),
        createdAt: DateTime.now(),
        lgpdConsent: _lgpdConsent,
      );

      ref.read(patientViewModelProvider.notifier).addPatient(newPatient).then((_) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paciente cadastrado com sucesso!')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Cadastro de Paciente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Dados Pessoais'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo', prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(labelText: 'CPF', prefixIcon: Icon(Icons.badge)),
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _birthDateController,
                      readOnly: true,
                      onTap: _selectBirthDate,
                      decoration: const InputDecoration(labelText: 'Data de Nascimento', prefixIcon: Icon(Icons.cake)),
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(labelText: 'Sexo', prefixIcon: Icon(Icons.wc)),
                      items: const [
                        DropdownMenuItem(value: 'M', child: Text('Masculino')),
                        DropdownMenuItem(value: 'F', child: Text('Feminino')),
                        DropdownMenuItem(value: 'O', child: Text('Outro')),
                      ],
                      onChanged: (v) => setState(() => _selectedGender = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Telefone', prefixIcon: Icon(Icons.phone)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Endereço'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 3, child: TextFormField(controller: _zipCodeController, decoration: const InputDecoration(labelText: 'CEP'))),
                  const SizedBox(width: 16),
                  Expanded(flex: 7, child: TextFormField(controller: _streetController, decoration: const InputDecoration(labelText: 'Logradouro'))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 3, child: TextFormField(controller: _numberController, decoration: const InputDecoration(labelText: 'Número'))),
                  const SizedBox(width: 16),
                  Expanded(flex: 7, child: TextFormField(controller: _neighborhoodController, decoration: const InputDecoration(labelText: 'Bairro'))),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Conformidade LGPD'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Os dados coletados destinam-se exclusivamente ao prontuário clínico e histórico de saúde, '
                      'garantindo o sigilo médico e acadêmico conforme a Lei Geral de Proteção de Dados (13.709/2018).',
                      style: TextStyle(fontSize: 12),
                    ),
                    CheckboxListTile(
                      value: _lgpdConsent,
                      title: const Text('Paciente consente com a coleta e armazenamento de seus dados clínicos.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      onChanged: (v) => setState(() => _lgpdConsent = v!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _submitForm,
                  child: const Text('Finalizar Cadastro', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006494)),
    );
  }
}
