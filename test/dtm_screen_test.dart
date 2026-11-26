import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/endodontia_viewmodel.dart';
import 'package:promt/features/prontuario/presentation/views/dtm_screen.dart';

class _FakeDtmNotifier extends EndodontiaViewModel {
  _FakeDtmNotifier(super.ref, super.patientId, Map<String, dynamic>? initial) {
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
  test('FichaDtmModel serializes and deserializes all fields round-trip', () {
    final model = FichaDtmModel(
      profissional: 'Dra. Andrea Alac',
      data: '26/11/2026',
      riscoCarie: 'baixo',
      riscoOclusal: 'moderado',
      riscoDtm: 'alto',
      corAtual: CorDentesRow(anterior: 'A2', canino: 'A3', posterior: 'A3,5'),
      aposClareamento: CorDentesRow(anterior: 'A1', canino: 'A2', posterior: 'A2'),
      corPorcelanaResina: CorDentesRow(anterior: 'BL4', canino: 'A1', posterior: 'A2'),
      tratamentos: [
        DtmTratamentoRow(
          data: '26/11/2026',
          dente: '16',
          tratamentoRealizado: 'Placa oclusal estabilizadora',
        ),
      ],
    );

    final restored = FichaDtmModel.fromMap(model.toMap());
    expect(restored.profissional, 'Dra. Andrea Alac');
    expect(restored.data, '26/11/2026');
    expect(restored.riscoCarie, 'baixo');
    expect(restored.riscoOclusal, 'moderado');
    expect(restored.riscoDtm, 'alto');
    expect(restored.corAtual.anterior, 'A2');
    expect(restored.aposClareamento.canino, 'A2');
    expect(restored.corPorcelanaResina.anterior, 'BL4');
    expect(restored.tratamentos.first.dente, '16');
    expect(restored.tratamentos.first.tratamentoRealizado, 'Placa oclusal estabilizadora');
    expect(restored.tratamentos.length, greaterThanOrEqualTo(12));
  });

  testWidgets('DtmScreen renders all sections from the clinical sheet template', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          endodontiaViewModelProvider('dtm_pat-1').overrideWith(
            (ref) => _FakeDtmNotifier(ref, 'dtm_pat-1', null),
          ),
        ],
        child: const MaterialApp(
          home: DtmScreen(patientId: 'pat-1', patientName: 'Paciente Teste 01'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('DTM'), findsOneWidget);
    expect(find.text('FICHA CLÍNICA'), findsOneWidget);
    expect(find.text('AVALIAÇÃO DE RISCO (avaliado pela sua dentista)'), findsOneWidget);
    expect(find.text('Risco de Cárie'), findsOneWidget);
    expect(find.text('Risco Oclusal'), findsOneWidget);
    expect(find.text('Risco DTM'), findsOneWidget);
    expect(find.text('COR DOS DENTES'), findsOneWidget);
    expect(find.text('cor atual dos dentes'), findsOneWidget);
    expect(find.text('após o clareamento'), findsOneWidget);
    expect(find.text('cor da porcelana ou resina foto'), findsOneWidget);
    expect(find.text('TRATAMENTO REALIZADO'), findsAtLeastNWidgets(1));
  });
}
