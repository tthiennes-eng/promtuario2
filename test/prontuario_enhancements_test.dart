import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promt/features/prontuario/domain/entities/attachment.dart';
import 'package:promt/features/prontuario/domain/entities/treatment_plan.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/endodontia_viewmodel.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/prontuario_summary_provider.dart';
import 'package:promt/features/prontuario/presentation/views/clinical_timeline_screen.dart';
import 'package:promt/features/prontuario/presentation/views/tcle_screen.dart';

class _FakeEndoNotifier extends EndodontiaViewModel {
  _FakeEndoNotifier(super.ref, super.patientId, Map<String, dynamic>? initial) {
    state = AsyncValue.data(initial);
  }

  @override
  Future<void> load() async {}

  @override
  Future<void> save(Map<String, dynamic> data) async {
    state = AsyncValue.data(data);
  }
}

void main() {
  test('TreatmentPlan and TreatmentItem parse numeric C# enum values', () {
    final plan = TreatmentPlan.fromJson({
      'id': 'plan-1',
      'patientId': 'pat-1',
      'description': 'Plano Teste',
      'status': 2, // Approved
      'createdAt': '2026-11-26T10:00:00Z',
      'items': [
        {
          'id': 'item-1',
          'procedureId': 'proc-1',
          'procedureName': 'Restauração de Resina',
          'toothNumber': 16,
          'status': 3, // Completed
          'observation': 'Face oclusal',
        },
        {
          'id': 'item-2',
          'procedureId': 'proc-2',
          'procedureName': 'Profilaxia',
          'status': 2, // InProgress
        },
      ],
    });

    expect(plan.status, TreatmentPlanStatus.approved);
    expect(plan.items.length, 2);
    expect(plan.items[0].status, TreatmentItemStatus.completed);
    expect(plan.items[0].observation, 'Face oclusal');
    expect(plan.items[1].status, TreatmentItemStatus.inProgress);
  });

  testWidgets('TcleScreen renders consent text, signature pad, and acceptance checkbox', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          endodontiaViewModelProvider('tcle_pat-1').overrideWith(
            (ref) => _FakeEndoNotifier(ref, 'tcle_pat-1', null),
          ),
        ],
        child: const MaterialApp(
          home: TcleScreen(patientId: 'pat-1', patientName: 'Maria Silva'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TCLE / Consentimento (LGPD)'), findsOneWidget);
    expect(find.text('Assinatura / Rubrica do Paciente ou Responsável'), findsOneWidget);
    expect(find.text('Registrar Consentimento (TCLE)'), findsOneWidget);
  });

  testWidgets('ClinicalTimelineScreen renders timeline events and filters by category', (tester) async {
    final mockEvents = [
      {
        'id': 'e1',
        'category': 'evolution',
        'title': 'Evolução Clínica (Clinica I)',
        'description': 'Restauração concluída',
        'date': '2026-11-26T12:00:00Z',
        'badge': 'Assinada',
      },
      {
        'id': 'p1',
        'category': 'prescription',
        'title': 'Receita Emitida',
        'description': 'Dipirona 500mg',
        'date': '2026-11-25T10:00:00Z',
        'badge': '1 item(ns)',
      },
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clinicalTimelineProvider('pat-1').overrideWith((ref) async => mockEvents),
        ],
        child: const MaterialApp(
          home: ClinicalTimelineScreen(patientId: 'pat-1', patientName: 'Maria Silva'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Evolução Clínica (Clinica I)'), findsOneWidget);
    expect(find.text('Receita Emitida'), findsOneWidget);

    await tester.tap(find.text('Receitas'));
    await tester.pumpAndSettle();

    expect(find.text('Evolução Clínica (Clinica I)'), findsNothing);
    expect(find.text('Receita Emitida'), findsOneWidget);
  });

  test('Attachment correctly classifies image, text, and document files', () {
    final img = Attachment(
      id: '1',
      patientId: 'p1',
      localPath: '/tmp/radiografia.png',
      type: AttachmentType.xRay,
      description: 'radiografia.png',
      createdAt: DateTime(2026, 11, 26),
    );
    final txt = Attachment(
      id: '2',
      patientId: 'p1',
      localPath: '/tmp/laudo_canal.txt',
      type: AttachmentType.document,
      description: 'laudo_canal.txt',
      createdAt: DateTime(2026, 11, 26),
    );
    final pdf = Attachment(
      id: '3',
      patientId: 'p1',
      remoteUrl: 'http://localhost:5000/uploads/exame.pdf',
      type: AttachmentType.document,
      description: 'exame.pdf',
      createdAt: DateTime(2026, 11, 26),
    );

    expect(img.isImageFile, isTrue);
    expect(img.isTextFile, isFalse);

    expect(txt.isTextFile, isTrue);
    expect(txt.isImageFile, isFalse);
    expect(txt.fileExtension, 'txt');

    expect(pdf.isDocumentFile, isTrue);
    expect(pdf.isImageFile, isFalse);
    expect(pdf.isTextFile, isFalse);
    expect(pdf.fileExtension, 'pdf');
  });
}
