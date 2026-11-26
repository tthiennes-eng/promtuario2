import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/security/storage_service.dart';
import 'package:promt/features/patients/data/repositories/patient_repository.dart';

class _OfflineApiClient extends ApiClient {
  _OfflineApiClient() : super(StorageService(), '127.0.0.1');

  @override
  Dio get instance => Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:1/api/',
          connectTimeout: const Duration(milliseconds: 50),
          receiveTimeout: const Duration(milliseconds: 50),
        ),
      );
}

void main() {
  test('PatientRepository loads and filters patients from local Drift DB without TypeError', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.patientsLocal).insert(
          PatientsLocalCompanion.insert(
            id: '11111111-1111-1111-1111-111111111111',
            fullName: 'Maria Silva',
            cpf: '12345678901',
            birthDate: DateTime(1990, 5, 10),
            createdAt: DateTime(2026, 1, 1),
          ),
        );

    final repo = PatientRepository(_OfflineApiClient(), db);

    final all = await repo.getLocalPatients();
    expect(all.length, 1);
    expect(all.first.fullName, 'Maria Silva');

    final filtered = await repo.getLocalPatients(query: 'Maria');
    expect(filtered.length, 1);

    final viaGetPatients = await repo.getPatients();
    expect(viaGetPatients.length, 1);
    expect(viaGetPatients.first.cpf, '12345678901');
  });

  test('AppDatabase reconciles legacy patients_local table missing newer columns', () async {
    final executor = NativeDatabase.memory(
      setup: (rawDb) {
        // Simula banco antigo (versão 4) sem colunas street/number/social_name/sus_number
        rawDb.execute('PRAGMA user_version = 4;');
        rawDb.execute('''
          CREATE TABLE patients_local (
            id TEXT NOT NULL PRIMARY KEY,
            full_name TEXT NOT NULL,
            cpf TEXT NOT NULL,
            birth_date INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          );
        ''');
        rawDb.execute('''
          INSERT INTO patients_local (id, full_name, cpf, birth_date, created_at)
          VALUES ('old-1', 'Paciente Legado', '00000000000', 0, 0);
        ''');
      },
    );

    final db = AppDatabase(executor);
    addTearDown(db.close);

    final repo = PatientRepository(_OfflineApiClient(), db);
    final patients = await repo.getPatients();
    expect(patients, isEmpty);

    await db.into(db.patientsLocal).insert(
          PatientsLocalCompanion.insert(
            id: '22222222-2222-2222-2222-222222222222',
            fullName: 'João Pereira',
            cpf: '98765432100',
            birthDate: DateTime(1985, 8, 20),
            createdAt: DateTime(2026, 2, 1),
          ),
        );

    final reloaded = await repo.getLocalPatients();
    expect(reloaded.length, 1);
    expect(reloaded.first.fullName, 'João Pereira');
  });
}
