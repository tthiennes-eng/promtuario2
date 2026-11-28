import 'package:flutter_test/flutter_test.dart';
import 'package:promt/core/utils/date_utils.dart';
import 'package:promt/features/notifications/domain/entities/notification_item.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/features/procedures/domain/entities/procedure.dart';
import 'package:promt/features/prontuario/domain/entities/anamnese.dart';
import 'package:promt/features/prontuario/domain/entities/odontogram.dart';

void main() {
  test('ToothCondition.fromJson parses both backend integer enums and string names', () {
    final fromInts = ToothCondition.fromJson({
      'toothNumber': 16,
      'surfaces': [0, 2],
      'condition': 1,
      'observation': 'Cárie',
    });
    expect(fromInts.toothNumber, 16);
    expect(fromInts.condition, ConditionType.decayed);
    expect(fromInts.surfaces, [ToothSurface.mesial, ToothSurface.occlusal]);

    final fromStrings = ToothCondition.fromJson({
      'toothNumber': 26,
      'surfaces': ['distal', 'buccal'],
      'condition': 'restored',
    });
    expect(fromStrings.condition, ConditionType.restored);
    expect(fromStrings.surfaces, [ToothSurface.distal, ToothSurface.buccal]);
  });

  test('Anamnese.fromJson parses both responses Map and backend respostasJson String', () {
    final fromString = Anamnese.fromJson({
      'id': 'a-1',
      'patientId': 'p-1',
      'respostasJson': '{"queixaPrincipal":"Dor","sistemico":{"diabetes":{"sim":true}}}',
      'criadoPorId': 'u-1',
    });
    expect(fromString.responses['queixaPrincipal'], 'Dor');
    expect((fromString.responses['sistemico'] as Map)['diabetes']['sim'], true);
    expect(fromString.updatedBy, 'u-1');

    final fromMap = Anamnese.fromJson({
      'id': 'a-2',
      'patientId': 'p-1',
      'responses': {'queixaPrincipal': 'Revisão'},
      'updatedBy': 'u-2',
    });
    expect(fromMap.responses['queixaPrincipal'], 'Revisão');
    expect(fromMap.updatedBy, 'u-2');
  });

  test('SafeDateParser handles pre-1970 negative millisecond timestamps and accurate age', () {
    final dob1960 = DateTime.utc(1960, 6, 15).millisecondsSinceEpoch;
    expect(dob1960, isNegative);
    final parsed = SafeDateParser.parseNullable(dob1960);
    expect(parsed, isNotNull);
    expect(parsed!.year, 1960);

    final ref = DateTime(2026, 5, 10);
    expect(SafeDateParser.calculateAge(DateTime(2000, 6, 15), ref), 25);
    expect(SafeDateParser.calculateAge(DateTime(2000, 5, 10), ref), 26);
  });

  test('Clinic implements value equality by id for DropdownButton safety', () {
    const c1 = Clinic(id: 'c-1', name: 'Clinica I');
    const c2 = Clinic(id: 'c-1', name: 'Clinica I');
    const c3 = Clinic(id: 'c-2', name: 'Clinica II');
    expect(c1 == c2, isTrue);
    expect(c1.hashCode, c2.hashCode);
    expect(c1 == c3, isFalse);
  });

  test('NotificationItem.fromJson parses backend integer Type, createdAt, and relatedEntityId', () {
    final item = NotificationItem.fromJson({
      'id': 'n-1',
      'title': 'Assinatura Pendente',
      'message': 'Há evolução pendente',
      'type': 2,
      'createdAt': '2026-11-20T12:00:00Z',
      'isRead': false,
      'relatedEntityId': 'evo-99',
    });
    expect(item.type, NotificationType.pendingSignature);
    expect(item.timestamp.year, 2026);
    expect(item.timestamp.month, 11);
    expect(item.data?['relatedEntityId'], 'evo-99');
  });

  test('Procedure.fromJson parses backend baseValue, code, and specialty aliases', () {
    final proc = Procedure.fromJson({
      'id': 'proc-1',
      'name': 'Restauração Resina',
      'code': 'TUSS-81000',
      'baseValue': 120.5,
      'specialty': 'RestorativeDentistry',
    });
    expect(proc.basePrice, 120.5);
    expect(proc.description, 'TUSS-81000');
    expect(proc.category, 'RestorativeDentistry');
  });
}
