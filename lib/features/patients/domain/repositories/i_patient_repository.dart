import '../entities/patient.dart';

abstract class IPatientRepository {
  Future<List<Patient>> getPatients({int page = 1, String? query});
  Future<Patient> getPatientById(String id);
  Future<Patient> createPatient(Patient patient);
  Future<void> updatePatient(Patient patient);
  Future<void> syncPatients();
  Future<List<Patient>> getLocalPatients({String? query});
}
