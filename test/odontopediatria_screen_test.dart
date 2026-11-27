import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promt/features/prontuario/domain/entities/odontopediatria_data.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/endodontia_viewmodel.dart';
import 'package:promt/features/prontuario/presentation/views/odontopediatria_screen.dart';

class _FakeOdontopediatriaNotifier extends EndodontiaViewModel {
  Map<String, dynamic>? lastSaved;

  _FakeOdontopediatriaNotifier(
    super.ref,
    super.patientId,
    Map<String, dynamic>? initial,
  ) {
    state = AsyncValue.data(initial);
  }

  @override
  Future<void> load() async {}

  @override
  Future<void> save(Map<String, dynamic> data) async {
    lastSaved = data;
    state = AsyncValue.data(data);
  }
}

void main() {
  test('OdontopediatriaModel serializes, deserializes and calculates IPV/ISG percent', () {
    final model = OdontopediatriaModel();
    model.setString('t1_aluno', 'João Silva');
    model.setBool('t1_termo_aceito', true);
    model.toggleInList('t2_q13_horarios', '(1) Ao acordar');
    model.toggleInList('t2_q13_horarios', '(7) Antes de dormir à noite');

    // 4 faces avaliadas no IPV: 1 positiva => 25.0%
    model.setGridCell('t7_ipv_grid', '16', 'V', '1');
    model.setGridCell('t7_ipv_grid', '16', 'P', '0');
    model.setGridCell('t7_ipv_grid', '16', 'M', '0');
    model.setGridCell('t7_ipv_grid', '16', 'D', '0');
    expect(model.computeBinaryIndexPercent('t7_ipv_grid'), closeTo(25.0, 0.001));
    expect(model.computeBinaryIndexPercent('t7_isg_grid'), isNull);

    model.setGridCell('t8_clinico_grid', '55', 'O', '3');

    final restored = OdontopediatriaModel.fromMap(model.toMap());
    expect(restored.getString('t1_aluno'), 'João Silva');
    expect(restored.getBool('t1_termo_aceito'), isTrue);
    expect(restored.getStringList('t2_q13_horarios'), [
      '(1) Ao acordar',
      '(7) Antes de dormir à noite',
    ]);
    expect(restored.getGridCell('t7_ipv_grid', '16', 'V'), '1');
    expect(restored.getGridCell('t8_clinico_grid', '55', 'O'), '3');
    expect(restored.countFilledByPrefix('t1_'), 2);
  });

  testWidgets('OdontopediatriaScreen renders and navigates through all 10 topics', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    late _FakeOdontopediatriaNotifier fakeNotifier;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          endodontiaViewModelProvider('odontopediatria_pat-1').overrideWith(
            (ref) {
              fakeNotifier = _FakeOdontopediatriaNotifier(ref, 'odontopediatria_pat-1', null);
              return fakeNotifier;
            },
          ),
        ],
        child: const MaterialApp(
          home: OdontopediatriaScreen(patientId: 'pat-1', patientName: 'Criança Teste'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tópico 1
    expect(find.text('Odontopediatria'), findsOneWidget);
    expect(find.text('IDENTIFICAÇÃO DO PACIENTE'), findsOneWidget);
    expect(find.text('AUTORIZAÇÃO E TERMO DE COMPROMISSO'), findsOneWidget);

    Future<void> openTopic(String pillLabel) async {
      final finder = find.text(pillLabel);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    // Tópico 2
    await openTopic('2. Mãe / Resp.');
    expect(find.text('DADOS SOCIOECONÔMICOS DA MÃE OU RESPONSÁVEL'), findsOneWidget);
    expect(find.text('SAÚDE GERAL E HIGIENE BUCAL DO RESPONSÁVEL'), findsOneWidget);

    // Tópico 3
    await openTopic('3. Dieta Resp.');
    expect(find.text('PARTE 2 — DADOS DA DIETA DA MÃE / RESPONSÁVEL'), findsOneWidget);

    // Tópico 4
    await openTopic('4. Pré/Pós-Natal e Higiene');
    expect(find.text('PARTE 3 — PERÍODO PRÉ E PÓS-NATAL (PRIMEIROS ANOS DE VIDA DA CRIANÇA)'), findsOneWidget);
    expect(find.text('A. HÁBITOS DE HIGIENE BUCAL E HISTÓRICO ODONTOLÓGICO DA CRIANÇA'), findsOneWidget);

    // Tópico 5
    await openTopic('5. Saúde e Hábitos');
    expect(find.text('HISTÓRIA MÉDICA ANTERIOR'), findsOneWidget);
    expect(find.text('COMPORTAMENTO PSICOLÓGICO'), findsOneWidget);
    expect(find.text('B. HÁBITOS DELETÉRIOS'), findsOneWidget);

    // Tópico 6
    await openTopic('6. Consumo Alimentar');
    expect(find.text('CRIANÇAS MENORES DE 6 MESES'), findsOneWidget);
    expect(find.text('CRIANÇAS DE 6 A 23 MESES'), findsOneWidget);

    // Tópico 7
    await openTopic('7. IPV e ISG');
    expect(find.text('IPV — ÍNDICE DE PLACA VISÍVEL'), findsOneWidget);
    expect(find.text('ISG — ÍNDICE DE SANGRAMENTO GENGIVAL'), findsOneWidget);

    // Tópico 8
    await openTopic('8. Clínico e Rx');
    expect(find.text('EXAME CLÍNICO E OBSERVAÇÕES CLÍNICAS'), findsOneWidget);
    expect(find.text('PERFIL DO PACIENTE COM RELAÇÃO À DOENÇA CÁRIE'), findsOneWidget);
    expect(find.text('EXAME RADIOGRÁFICO (CÓDIGOS DE RADIOLUCIDEZ)'), findsOneWidget);

    // Tópico 9
    await openTopic('9. Anomalias / Orto');
    expect(find.text('PARTE 4 — EXAME DOS DENTES E PERIODONTO (ANOMALIAS DENTÁRIAS)'), findsOneWidget);
    expect(find.text('PARTE 5 — AVALIAÇÃO ORTODÔNTICA — DENTIÇÃO DECÍDUA'), findsOneWidget);
    expect(find.text('DENTIÇÃO MISTA E PERMANENTE'), findsOneWidget);

    // Tópico 10
    await openTopic('10. Planejamento');
    expect(find.text('RELAÇÃO DOS PROCEDIMENTOS CLÍNICOS INVASIVOS (EXO, ENDO, DENTÍSTICA)'), findsOneWidget);
    expect(find.text('OPERACIONALIZAÇÃO (PLANEJAMENTO POR CONSULTA)'), findsOneWidget);

    // Salvar ficha
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(fakeNotifier.lastSaved, isNotNull);
    expect(fakeNotifier.lastSaved!['t1_nome'], 'Criança Teste');
  });
}
