import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promt/features/dashboard/domain/services/statistical_engine.dart';
import 'package:promt/features/dashboard/presentation/viewmodels/statistical_studies_viewmodel.dart';
import 'package:promt/features/dashboard/presentation/widgets/statistical_panel_widget.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/features/procedures/presentation/viewmodels/clinics_viewmodel.dart';

class _FakeClinicsNotifier extends ClinicsViewModel {
  _FakeClinicsNotifier(super.ref, List<Clinic> clinics) {
    state = AsyncValue.data(clinics);
  }

  @override
  Future<void> refresh() async {}
}

Map<String, dynamic> _samplePayload() {
  final dataset = <Map<String, dynamic>>[
    // 10 expostos com cárie (a=10), 2 expostos sem cárie (b=2)
    for (int i = 0; i < 10; i++)
      {
        'code': 'P00$i',
        'age': 8,
        'hasSugaryDiet': true,
        'hasCaries': true,
        'hasDeleteriousHabit': true,
        'hasMalocclusion': true,
        'hasComorbidity': false,
        'hasExtractionOrEndo': false,
        'highDtmRisk': false,
        'hasMissedAppointment': false,
        'highIpv': true,
        'hasAnamnese': true,
        'hasOdontogram': true,
        'hasLgpdConsent': true,
      },
    for (int i = 0; i < 2; i++)
      {
        'code': 'P01$i',
        'age': 9,
        'hasSugaryDiet': true,
        'hasCaries': false,
        'hasDeleteriousHabit': false,
        'hasMalocclusion': false,
        'hasComorbidity': true,
        'hasExtractionOrEndo': true,
        'highDtmRisk': true,
        'hasMissedAppointment': true,
        'highIpv': false,
        'hasAnamnese': true,
        'hasOdontogram': true,
        'hasLgpdConsent': true,
      },
    // 2 não expostos com cárie (c=2), 10 não expostos sem cárie (d=10)
    for (int i = 0; i < 2; i++)
      {
        'code': 'P02$i',
        'age': 10,
        'hasSugaryDiet': false,
        'hasCaries': true,
        'hasDeleteriousHabit': false,
        'hasMalocclusion': false,
        'hasComorbidity': true,
        'hasExtractionOrEndo': true,
        'highDtmRisk': false,
        'hasMissedAppointment': false,
        'highIpv': false,
        'hasAnamnese': true,
        'hasOdontogram': true,
        'hasLgpdConsent': false,
      },
    for (int i = 0; i < 10; i++)
      {
        'code': 'P03$i',
        'age': 11,
        'hasSugaryDiet': false,
        'hasCaries': false,
        'hasDeleteriousHabit': false,
        'hasMalocclusion': false,
        'hasComorbidity': false,
        'hasExtractionOrEndo': false,
        'highDtmRisk': false,
        'hasMissedAppointment': false,
        'highIpv': false,
        'hasAnamnese': true,
        'hasOdontogram': false,
        'hasLgpdConsent': true,
      },
  ];

  return {
    'source': 'postgresql',
    'epidemiological': {
      'totalPatients': 24,
      'averageAge': 9.5,
      'medianAge': 9.5,
      'stdDevAge': 1.2,
      'ageGroups': {'6-11 anos': 24},
      'genderDistribution': {'Masculino': 12, 'Feminino': 12},
      'cityDistribution': {'São Luís': 20, 'Paço do Lumiar': 4},
      'odontogram': {
        'evaluatedPatients': 14,
        'cpodMean': 3.2,
        'cpodMedian': 3.0,
        'conditions': {'Decayed': 15, 'Restored': 8, 'Missing': 2},
        'topAffectedTeeth': [
          {'tooth': 16, 'count': 6},
          {'tooth': 55, 'count': 5},
        ],
      },
      'comorbidities': {'Alergias': 4, 'Respiração Bucal': 5},
      'dtmRisks': {
        'carie': {'baixo': 4, 'moderado': 3, 'alto': 2},
        'oclusal': {'baixo': 5, 'moderado': 2, 'alto': 2},
        'dtm': {'baixo': 6, 'moderado': 1, 'alto': 2},
      },
      'pediatric': {
        'evaluatedSheets': 12,
        'ipvMean': 34.5,
        'ipvMedian': 30.0,
        'isgMean': 18.0,
        'isgMedian': 15.0,
        'angleOcclusion': {'Classe I': 7, 'Classe II': 3},
        'facialProfile': {'(1) Reto': 6, '(3) Convexo': 4},
        'cariesProfile': {'Com experiência de Cárie — Com atividade': 6},
      },
    },
    'longitudinal': {
      'ipvEvolution': {'pairedPatients': 5, 'meanV1': 42.0, 'meanLatest': 21.0, 'delta': -21.0},
      'isgEvolution': {'pairedPatients': 5, 'meanV1': 24.0, 'meanLatest': 10.0, 'delta': -14.0},
      'treatmentPlans': {
        'totalPlans': 10,
        'approvedPlans': 8,
        'completedPlans': 6,
        'completionRate': 60.0,
        'avgDaysToComplete': 28.5,
        'procedures': [
          {'procedure': 'Restauração de Resina', 'total': 12, 'completed': 9, 'inProgress': 2, 'pending': 1, 'cancelled': 0},
        ],
      },
      'prescriptionsAndCertificates': {
        'totalPrescriptions': 7,
        'topMedications': [{'name': 'Amoxicilina 500mg', 'count': 4}],
        'totalCertificates': 3,
        'avgRestDays': 2.0,
        'topCids': [{'cid': 'K02', 'count': 2}],
      },
      'monthlyTrend': [
        {'month': '11/2026', 'appointments': 20, 'completed': 15, 'missed': 3, 'evolutions': 14, 'proceduresCompleted': 10},
      ],
    },
    'management': {
      'totalAppointments': 20,
      'completedAppointments': 15,
      'missedAppointments': 3,
      'cancelledAppointments': 2,
      'absenteeismRate': 15.0,
      'completionRate': 75.0,
      'absenteeismByClinic': [
        {'clinic': 'Clinica I', 'total': 12, 'completed': 9, 'missed': 2, 'cancelled': 1, 'absenteeismRate': 16.7},
      ],
      'absenteeismByWeekday': [
        {'day': 'Seg', 'total': 5, 'missed': 1, 'rate': 20.0},
      ],
      'absenteeismByPeriod': [
        {'period': 'Manhã (07h–12h)', 'total': 12, 'missed': 2, 'rate': 16.7},
      ],
      'timing': {'avgWaitMinutes': 14.5, 'avgDelayMinutes': 6.0, 'avgDurationMinutes': 48.0, 'samples': 10},
      'productivityByStudent': [{'name': 'Dupla A', 'evolutions': 9, 'signed': 8}],
      'productivityByProfessor': [{'name': 'Prof. Carlos', 'evolutions': 12, 'signed': 11}],
      'waitList': {'total': 4, 'pending': 2, 'resolved': 2, 'avgWaitDays': 5.5},
    },
    'quality': {
      'completeness': {
        'anamnese': {'count': 24, 'percent': 100.0},
        'odontograma': {'count': 14, 'percent': 58.3},
        'planoTratamento': {'count': 10, 'percent': 41.7},
        'evolucao': {'count': 14, 'percent': 58.3},
        'tcleLgpd': {'count': 22, 'percent': 91.7},
        'odontopediatria': {'count': 12, 'percent': 50.0},
      },
      'governance': {
        'totalEvolutions': 14,
        'signedEvolutions': 12,
        'pendingSignatures': 2,
        'signedRate': 85.7,
        'avgHoursToSign': 3.2,
      },
      'lgpd': {'adherentPatients': 22, 'totalPatients': 24, 'adherenceRate': 91.7},
    },
    'patientDataset': dataset,
  };
}

void main() {
  test('StatisticalEngine computes exact 2x2 Chi-Square, p-value, Odds Ratio and Prevalence Ratio', () {
    final dataset = (_samplePayload()['patientDataset'] as List).cast<Map<String, dynamic>>();
    final result = StatisticalEngine.compute2x2(dataset, 'hasSugaryDiet', 'hasCaries');

    // a=10, b=2, c=2, d=10 => n=24, chi2 = 24*(100-4)^2/(12*12*12*12) = 10.6667, OR = 25.0, RP = 5.0
    expect(result.a, 10);
    expect(result.b, 2);
    expect(result.c, 2);
    expect(result.d, 10);
    expect(result.chiSquare, closeTo(10.6667, 0.01));
    expect(result.pValue, lessThan(0.01));
    expect(result.isSignificant, isTrue);
    expect(result.oddsRatio, closeTo(25.0, 0.01));
    expect(result.prevalenceRatio, closeTo(5.0, 0.01));

    expect(StatisticalEngine.mean([10, 20, 30]), closeTo(20.0, 0.001));
    expect(StatisticalEngine.median([10, 20, 30, 40]), closeTo(25.0, 0.001));
    expect(StatisticalEngine.stdDev([10, 20, 30]), closeTo(10.0, 0.001));
  });

  testWidgets('StatisticalPanelWidget renders and navigates through all 5 study tabs', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final payload = _samplePayload();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticalStudiesProvider.overrideWith((ref) async => payload),
          clinicsViewModelProvider.overrideWith(
            (ref) => _FakeClinicsNotifier(ref, [Clinic(id: 'c1', name: 'Clinica I')]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: StatisticalPanelWidget(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Aba 1: Epidemiológico
    expect(find.text('Painel Estatístico de Estudos Clínicos'), findsOneWidget);
    expect(find.text('Distribuição por Faixa Etária'), findsOneWidget);
    expect(find.text('Avaliação de Risco Clínico (Ficha DTM)'), findsOneWidget);

    // Aba 2: Associações (2x2)
    await tester.tap(find.text('2. Associações (2×2)'));
    await tester.pumpAndSettle();
    expect(find.text('Tabela 2×2 (N = 24)'), findsOneWidget);
    expect(find.text('Significativo (p < 0,05)'), findsOneWidget);

    // Aba 3: Longitudinal
    await tester.tap(find.text('3. Longitudinal'));
    await tester.pumpAndSettle();
    expect(find.text('Série Temporal Mensal — Últimos 6 Meses'), findsOneWidget);
    expect(find.text('Restauração de Resina'), findsOneWidget);

    // Aba 4: Gestão e Fluxo
    await tester.tap(find.text('4. Gestão e Fluxo'));
    await tester.pumpAndSettle();
    expect(find.text('Absenteísmo e Volume por Clínica'), findsOneWidget);
    expect(find.text('Clinica I'), findsOneWidget);

    // Aba 5: Qualidade e LGPD
    await tester.ensureVisible(find.text('5. Qualidade e LGPD'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5. Qualidade e LGPD'));
    await tester.pumpAndSettle();
    expect(find.text('Completude do Prontuário por Ficha Clínica (% de Pacientes)'), findsOneWidget);
    expect(find.text('91.7%'), findsAtLeastNWidgets(1));
  });
}
