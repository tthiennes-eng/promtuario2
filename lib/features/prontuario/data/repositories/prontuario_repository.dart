import '../../../core/network/api_client.dart';
import '../../domain/entities/odontogram.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/entities/anamnese.dart';
import '../../domain/repositories/i_prontuario_repository.dart';

/// Implementação do Repositório de Prontuário.
/// Gerencia Odontogramas, Evoluções, Receitas, Atestados e Anamnese via API.
class ProntuarioRepository implements IProntuarioRepository {
  final ApiClient _apiClient;

  ProntuarioRepository(this._apiClient);

  @override
  Future<Odontogram> getOdontogram(String patientId) async {
    final response = await _apiClient.instance.get('/patients/$patientId/odontogram');
    return _mapJsonToOdontogram(response.data);
  }

  @override
  Future<void> saveOdontogram(Odontogram odontogram) async {
    await _apiClient.instance.post(
      '/patients/${odontogram.patientId}/odontogram',
      data: _mapOdontogramToJson(odontogram),
    );
  }

  @override
  Future<void> addEvolution(String patientId, String description, String professorId) async {
    await _apiClient.instance.post(
      '/evolutions',
      data: {
        'patientId': patientId,
        'description': description,
        'professorId': professorId,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getEvolutionHistory(String patientId) async {
    final response = await _apiClient.instance.get('/patients/$patientId/evolutions');
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<Prescription> createPrescription(Prescription prescription) async {
    final response = await _apiClient.instance.post(
      '/patients/${prescription.patientId}/prescriptions',
      data: {
        'doctorId': prescription.doctorId,
        'doctorName': prescription.doctorName,
        'observations': prescription.observations,
        'items': prescription.items.map((i) => {
          'medicineName': i.medicineName,
          'dosage': i.dosage,
          'instructions': i.instructions,
        }).toList(),
        'clinicId': prescription.clinicId,
      },
    );
    return _mapJsonToPrescription(response.data);
  }

  @override
  Future<List<Prescription>> getPrescriptionHistory(String patientId) async {
    final response = await _apiClient.instance.get('/patients/$patientId/prescriptions');
    final List<dynamic> data = response.data;
    return data.map((json) => _mapJsonToPrescription(json)).toList();
  }

  @override
  Future<MedicalCertificate> createCertificate(MedicalCertificate certificate) async {
    final response = await _apiClient.instance.post(
      '/patients/${certificate.patientId}/certificates',
      data: {
        'doctorId': certificate.doctorId,
        'doctorName': certificate.doctorName,
        'content': certificate.content,
        'daysOfRest': certificate.daysOfRest,
        'cid': certificate.cid,
        'clinicId': certificate.clinicId,
      },
    );
    return _mapJsonToCertificate(response.data);
  }

  @override
  Future<Anamnese?> getAnamneseByPatientId(String patientId) async {
    try {
      final response = await _apiClient.instance.get('/patients/$patientId/anamnese');
      if (response.data == null) return null;
      return Anamnese.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAnamnese(Anamnese anamnese) async {
    await _apiClient.instance.post(
      '/patients/${anamnese.patientId}/anamnese',
      data: anamnese.toJson(),
    );
  }

  // Mapper methods
  Odontogram _mapJsonToOdontogram(Map<String, dynamic> json) {
    return Odontogram(
      id: json['id'],
      patientId: json['patientId'],
      updatedAt: DateTime.parse(json['updatedAt']),
      updatedBy: json['updatedBy'],
      teeth: (json['teeth'] as List).map((t) => ToothCondition(
        toothNumber: t['toothNumber'],
        condition: ConditionType.values.firstWhere((e) => e.name == t['condition']),
        surfaces: (t['surfaces'] as List).map((s) => ToothSurface.values.firstWhere((e) => e.name == s)).toList(),
        observation: t['observation'],
      )).toList(),
    );
  }

  Map<String, dynamic> _mapOdontogramToJson(Odontogram odontogram) {
    return {
      'patientId': odontogram.patientId,
      'teeth': odontogram.teeth.map((t) => {
        'toothNumber': t.toothNumber,
        'condition': t.condition.name,
        'surfaces': t.surfaces.map((s) => s.name).toList(),
        'observation': t.observation,
      }).toList(),
    };
  }

  Prescription _mapJsonToPrescription(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      date: DateTime.parse(json['date']),
      items: (json['items'] as List).map((i) => PrescriptionItem(
        medicineName: i['medicineName'],
        dosage: i['dosage'],
        instructions: i['instructions'],
      )).toList(),
      observations: json['observations'],
      clinicId: json['clinicId'],
    );
  }

  MedicalCertificate _mapJsonToCertificate(Map<String, dynamic> json) {
    return MedicalCertificate(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      date: DateTime.parse(json['date']),
      content: json['content'],
      daysOfRest: json['daysOfRest'],
      cid: json['cid'],
      clinicId: json['clinicId'],
    );
  }
}
