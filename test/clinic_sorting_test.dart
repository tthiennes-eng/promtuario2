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
}
