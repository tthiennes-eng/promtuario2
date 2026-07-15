import '../../../core/network/api_client.dart';
import '../../../core/database/local_database.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/i_patient_repository.dart';
import 'package:drift/drift.dart';

/// Implementação do Repositório de Pacientes.
/// Gerencia a sincronização entre a API remota e o Banco de Dados local (SQLite).
class PatientRepository implements IPatientRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;

  PatientRepository(this._apiClient, this._localDb);

  @override
  Future<List<Patient>> getPatients({int page = 1, String? query}) async {
    try {
      final response = await _apiClient.instance.get('/patients', queryParameters: {
        'page': page,
        'search': query,
      });

      final List<dynamic> data = response.data['items'];
      final patients = data.map((json) => _mapJsonToEntity(json)).toList();

      // Atualiza o cache local de forma assíncrona
      _updateLocalCache(patients);

      return patients;
    } catch (e) {
      // Em caso de falha na rede, busca no cache local
      return getLocalPatients();
    }
  }

  @override
  Future<Patient> getPatientById(String id) async {
    final response = await _apiClient.instance.get('/patients/$id');
    return _mapJsonToEntity(response.data);
  }

  @override
  Future<Patient> createPatient(Patient patient) async {
    final response = await _apiClient.instance.post('/patients', data: _mapEntityToJson(patient));
    final newPatient = _mapJsonToEntity(response.data);
    
    // Salva no banco local
    await _localDb.into(_localDb.patients).insert(
          PatientsCompanion.insert(
            id: newPatient.id,
            fullName: newPatient.fullName,
            cpf: newPatient.cpf,
            birthDate: newPatient.birthDate,
            phone: Value(newPatient.phone),
          ),
        );
        
    return newPatient;
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    await _apiClient.instance.put('/patients/${patient.id}', data: _mapEntityToJson(patient));
    
    // Atualiza localmente
    await (_localDb.update(_localDb.patients)..where((t) => t.id.equals(patient.id))).write(
      PatientsCompanion(
        fullName: Value(patient.fullName),
        cpf: Value(patient.cpf),
        birthDate: Value(patient.birthDate),
        phone: Value(patient.phone),
      ),
    );
  }

  @override
  Future<List<Patient>> getLocalPatients() async {
    final results = await _localDb.select(_localDb.patients).get();
    return results.map((row) => Patient(
      id: row.id,
      fullName: row.fullName,
      cpf: row.cpf,
      birthDate: row.birthDate,
      phone: row.phone,
      createdAt: DateTime.now(), // Placeholder para dados locais simplificados
    )).toList();
  }

  @override
  Future<void> syncPatients() async {
    // Lógica para enviar dados criados offline para o servidor
  }

  void _updateLocalCache(List<Patient> patients) async {
    for (var patient in patients) {
      await _localDb.into(_localDb.patients).insertOnConflictUpdate(
        PatientsCompanion.insert(
          id: patient.id,
          fullName: patient.fullName,
          cpf: patient.cpf,
          birthDate: patient.birthDate,
          phone: Value(patient.phone),
        ),
      );
    }
  }

  Patient _mapJsonToEntity(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      fullName: json['fullName'],
      cpf: json['cpf'],
      birthDate: DateTime.parse(json['birthDate']),
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      createdAt: DateTime.parse(json['createdAt']),
      lgpdConsent: json['lgpdConsent'] ?? false,
    );
  }

  Map<String, dynamic> _mapEntityToJson(Patient patient) {
    return {
      'fullName': patient.fullName,
      'cpf': patient.cpf,
      'birthDate': patient.birthDate.toIso8601String(),
      'email': patient.email,
      'phone': patient.phone,
      'gender': patient.gender,
      'lgpdConsent': patient.lgpdConsent,
    };
  }
}
