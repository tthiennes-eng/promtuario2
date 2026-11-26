import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/endodontia_viewmodel.dart';
import 'package:promt/features/prontuario/presentation/views/ppr_screen.dart';

class _FakePprViewModel extends EndodontiaViewModel {
  _FakePprViewModel(Ref ref, String key, Map<String, dynamic>? initial)
      : super(ref, key) {
    state = AsyncValue.data(initial);
  }

  Map<String, dynamic>? savedPayload;

  @override
  Future<void> load() async {}

  @override
  Future<void> save(Map<String, dynamic> data) async {
    savedPayload = data;
    state = AsyncValue.data(data);
  }
}

void main() {
  test('FichaPprModel has exact table row counts and serializes round-trip', () {
    final model = FichaPprModel();
    expect(model.retentoresDiretos.length, 6);
    expect(model.retentoresIndiretos.length, 4);
    expect(model.planoGuia.length, 6);
    expect(model.areaRetentiva.length, 6);
    expect(model.preparos.keys.toList(), [
      'Plano Guia (Guia Vermelha)',
      'Área Retentiva (Guia Incolor)',
      'Nicho',
      'Adequação do Equador Protético',
    ]);

    model.retentoresDiretos[0] = RetentorDiretoRow(
      dente: '16',
      apoio: 'M',
      grampos: 'Circunferencial simples',
    );
    model.retentoresIndiretos[0] = RetentorIndiretoRow(
      dente: '13',
      tipo: 'Apoio de cíngulo',
    );
    model.maxila = true;
    model.mandibula = false;
    model.classificacaoKennedy = 'Classe II Modificação 1';
    model.planoGuia[0] = TrajetoriaRow(
      dente: '16',
      local: 'M',
      trajetoria1: 'A',
      trajetoria2: 'B',
      trajetoria3: 'A',
    );
    model.areaRetentiva[0] = TrajetoriaRow(
      dente: '26',
      local: 'MV',
      trajetoria1: 'A',
      trajetoria2: 'A',
      trajetoria3: 'C',
    );
    model.preparos['Nicho'] = '16 (M), 26 (M), 13 (C)';
    model.desenhoArcada.add(
      PprStroke(
        colorValue: 0xFFD32F2F,
        points: const [Offset(0.1, 0.2), Offset(0.3, 0.4)],
      ),
    );

    final restored = FichaPprModel.fromMap(model.toMap());
    expect(restored.retentoresDiretos[0].dente, '16');
    expect(restored.retentoresDiretos[0].apoio, 'M');
    expect(restored.retentoresDiretos[0].grampos, 'Circunferencial simples');
    expect(restored.retentoresIndiretos[0].dente, '13');
    expect(restored.retentoresIndiretos[0].tipo, 'Apoio de cíngulo');
    expect(restored.maxila, isTrue);
    expect(restored.mandibula, isFalse);
    expect(restored.classificacaoKennedy, 'Classe II Modificação 1');
    expect(restored.planoGuia[0].trajetoria1, 'A');
    expect(restored.areaRetentiva[0].trajetoria3, 'C');
    expect(restored.preparos['Nicho'], '16 (M), 26 (M), 13 (C)');
    expect(restored.desenhoArcada.length, 1);
    expect(restored.desenhoArcada.first.points.length, 2);
  });

  testWidgets('PprScreen renders all headings, tables and legends from the template', (tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late _FakePprViewModel fakeVm;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          endodontiaViewModelProvider('ppr_p-1').overrideWith((ref) {
            fakeVm = _FakePprViewModel(ref, 'ppr_p-1', null);
            return fakeVm;
          }),
        ],
        child: const MaterialApp(
          home: PprScreen(patientId: 'p-1', patientName: 'Maria Silva'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FICHA DE PLANEJAMENTO e DELINEAMENTO – PPR'), findsOneWidget);
    expect(find.text('RETENTORES DIRETOS'), findsOneWidget);
    expect(find.text('Grampos Retenção e Oposição'), findsOneWidget);
    expect(find.text('RETENTORES INDIRETOS'), findsOneWidget);
    expect(find.text('MAXILA'), findsOneWidget);
    expect(find.text('MANDÍBULA'), findsOneWidget);
    expect(find.text('Classificação de Kennedy'), findsOneWidget);
    expect(find.text('1. Determinação da trajetória de Inserção'), findsOneWidget);
    expect(find.text('1.a Avaliar Rebordo Residual / Áreas Estéticas'), findsOneWidget);
    expect(find.text('1.b Plano-Guia (Ponta Analisadora)'), findsOneWidget);
    expect(find.text('(A) Plano-guia (PG)'), findsOneWidget);
    expect(find.text('(B) Há uma interferência (I) ao assentamento'), findsOneWidget);
    expect(find.text('(C) Face expulsiva (E) em relação ao eixo vertical'), findsOneWidget);
    expect(find.text('1.c Área Retentiva (Ponta Calibradora)'), findsOneWidget);
    expect(find.text('(A) Haste e disco tocam (OK)'), findsOneWidget);
    expect(find.text('(B) Só disco toca (falta retenção)'), findsOneWidget);
    expect(find.text('(C) Só haste toca (excesso de retenção)'), findsOneWidget);
    expect(find.text('2. Fixar trajetória de inserção e traçar equador protético'), findsOneWidget);
    expect(find.text('3. Mapear adequações e preparos de nicho'), findsOneWidget);
    expect(find.text('TIPO DE PREPARO'), findsOneWidget);
    expect(find.text('DENTES (FACE)'), findsOneWidget);
    expect(find.text('Plano Guia (Guia Vermelha)'), findsOneWidget);
    expect(find.text('Área Retentiva (Guia Incolor)'), findsOneWidget);
    expect(find.text('Nicho'), findsOneWidget);
    expect(find.text('Adequação do Equador Protético'), findsOneWidget);

    // Testa marcar MAXILA e salvar
    await tester.tap(find.text('MAXILA'));
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(fakeVm.savedPayload, isNotNull);
    expect(fakeVm.savedPayload!['maxila'], isTrue);
  });
}
