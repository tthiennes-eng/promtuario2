import 'package:flutter_test/flutter_test.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';

void main() {
  test('Clinic.sortBySequence puts Clinica I, II, III, IV, V in order before other clinics', () {
    final clinics = [
      const Clinic(id: '1', name: 'Clinica de DTM'),
      const Clinic(id: '2', name: 'Clinica IV'),
      const Clinic(id: '3', name: 'Clinica Integrada Adulto II'),
      const Clinic(id: '4', name: 'Clinica II'),
      const Clinic(id: '5', name: 'Clinica V'),
      const Clinic(id: '6', name: 'Clinica de Emergência'),
      const Clinic(id: '7', name: 'Clinica I'),
      const Clinic(id: '8', name: 'Clinica Integrada Infantil'),
      const Clinic(id: '9', name: 'Clinica III'),
      const Clinic(id: '10', name: 'Clinica Integrada Adulto I'),
      const Clinic(id: '11', name: 'Clinica de Odontopediatria'),
    ];

    final sortedNames = Clinic.sortBySequence(clinics).map((c) => c.name).toList();

    expect(
      sortedNames.take(5).toList(),
      ['Clinica I', 'Clinica II', 'Clinica III', 'Clinica IV', 'Clinica V'],
    );
    expect(
      sortedNames.skip(5).toList(),
      [
        'Clinica de DTM',
        'Clinica de Emergência',
        'Clinica de Odontopediatria',
        'Clinica Integrada Adulto I',
        'Clinica Integrada Adulto II',
        'Clinica Integrada Infantil',
      ],
    );
  });

  test('Clinic.sortBySequence deduplicates repeated Clinica I entries regardless of accents or casing', () {
    final clinics = [
      const Clinic(id: '1', name: 'Clinica I'),
      const Clinic(id: '2', name: 'Clínica I'),
      const Clinic(id: '3', name: 'clinica  i '),
      const Clinic(id: '4', name: 'Clinica II'),
    ];

    final result = Clinic.sortBySequence(clinics);

    expect(result.length, 2);
    expect(result.map((c) => Clinic.normalizeName(c.name)).toList(), [
      'clinica i',
      'clinica ii',
    ]);
  });

  test('Clinic.resolveDisplayName resolves clinic name from id, clinicName, or deterministic UUIDv5', () {
    final clinics = [
      const Clinic(id: '11111111-1111-1111-1111-111111111111', name: 'Clinica I'),
      const Clinic(id: '22222222-2222-2222-2222-222222222222', name: 'Clinica II'),
    ];

    expect(
      Clinic.resolveDisplayName(
        clinicId: '11111111-1111-1111-1111-111111111111',
        clinics: clinics,
      ),
      'Clinica I',
    );
    expect(
      Clinic.resolveDisplayName(
        clinicId: Clinic.deterministicId('Clinica II'),
        clinics: clinics,
      ),
      'Clinica II',
    );
    expect(
      Clinic.resolveDisplayName(
        clinicId: '99999999-9999-9999-9999-999999999999',
        clinicName: 'Clinica III',
        clinics: clinics,
      ),
      'Clinica III',
    );
    expect(
      Clinic.resolveDisplayName(
        clinicId: '99999999-9999-9999-9999-999999999999',
        clinics: clinics,
      ),
      'Clínica não informada',
    );
  });
}
