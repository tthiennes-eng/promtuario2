import 'dart:io';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class StatisticalVariableSpec {
  final String key;
  final String label;
  final String group;

  const StatisticalVariableSpec({
    required this.key,
    required this.label,
    required this.group,
  });
}

class Contingency2x2Result {
  final String exposureLabel;
  final String outcomeLabel;
  final int a; // Exposto + Desfecho (+)
  final int b; // Exposto + Sem desfecho (-)
  final int c; // Não exposto + Desfecho (+)
  final int d; // Não exposto + Sem desfecho (-)
  final double chiSquare;
  final double pValue;
  final double? oddsRatio;
  final double? oddsRatioCiLow;
  final double? oddsRatioCiHigh;
  final double? prevalenceRatio;

  const Contingency2x2Result({
    required this.exposureLabel,
    required this.outcomeLabel,
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.chiSquare,
    required this.pValue,
    this.oddsRatio,
    this.oddsRatioCiLow,
    this.oddsRatioCiHigh,
    this.prevalenceRatio,
  });

  int get exposedTotal => a + b;
  int get unexposedTotal => c + d;
  int get outcomeTotal => a + c;
  int get noOutcomeTotal => b + d;
  int get total => a + b + c + d;

  double get exposedRate => exposedTotal > 0 ? (a / exposedTotal) * 100.0 : 0.0;
  double get unexposedRate => unexposedTotal > 0 ? (c / unexposedTotal) * 100.0 : 0.0;

  bool get hasSufficientSample =>
      total >= 4 && exposedTotal > 0 && unexposedTotal > 0 && outcomeTotal > 0 && noOutcomeTotal > 0;

  bool get isSignificant => hasSufficientSample && pValue < 0.05;

  String get interpretation {
    if (!hasSufficientSample) {
      return 'Amostra insuficiente para teste inferencial (necessário registros nos grupos exposto/não exposto e com/sem desfecho).';
    }
    if (isSignificant) {
      final dir = (prevalenceRatio ?? 1.0) >= 1.0 ? 'maior' : 'menor';
      return 'Associação estatisticamente significativa (p < 0,05): grupo exposto apresentou $dir ocorrência do desfecho.';
    }
    return 'Sem associação estatisticamente significativa ao nível de 5% (p ≥ 0,05) na amostra atual.';
  }
}

class StatisticalEngine {
  static const List<StatisticalVariableSpec> binaryVariables = [
    StatisticalVariableSpec(key: 'hasSugaryDiet', label: 'Dieta açucarada / ultraprocessados', group: 'Exposição'),
    StatisticalVariableSpec(key: 'hasDeleteriousHabit', label: 'Hábitos deletérios / respiração bucal', group: 'Exposição'),
    StatisticalVariableSpec(key: 'hasComorbidity', label: 'Comorbidade sistêmica (Anamnese)', group: 'Exposição'),
    StatisticalVariableSpec(key: 'hasAllergy', label: 'Histórico de alergia', group: 'Exposição'),
    StatisticalVariableSpec(key: 'highDtmRisk', label: 'Risco clínico alto (DTM / Oclusal / Cárie)', group: 'Exposição'),
    StatisticalVariableSpec(key: 'hasCaries', label: 'Experiência / atividade de cárie', group: 'Desfecho'),
    StatisticalVariableSpec(key: 'highIpv', label: 'IPV elevado (≥ 20%)', group: 'Desfecho'),
    StatisticalVariableSpec(key: 'hasMalocclusion', label: 'Alteração oclusal / má oclusão', group: 'Desfecho'),
    StatisticalVariableSpec(key: 'hasExtractionOrEndo', label: 'Necessidade de exodontia / endodontia', group: 'Desfecho'),
    StatisticalVariableSpec(key: 'hasMissedAppointment', label: 'Absenteísmo (ao menos 1 falta)', group: 'Gestão'),
    StatisticalVariableSpec(key: 'hasAnamnese', label: 'Anamnese preenchida', group: 'Qualidade'),
    StatisticalVariableSpec(key: 'hasOdontogram', label: 'Odontograma preenchido', group: 'Qualidade'),
    StatisticalVariableSpec(key: 'hasLgpdConsent', label: 'TCLE / Consentimento LGPD assinado', group: 'Qualidade'),
  ];

  static const List<(String title, String exposureKey, String outcomeKey)> presetAssociations = [
    ('Dieta açucarada × Experiência de Cárie', 'hasSugaryDiet', 'hasCaries'),
    ('Dieta açucarada × IPV elevado (≥ 20%)', 'hasSugaryDiet', 'highIpv'),
    ('Hábitos deletérios × Má Oclusão', 'hasDeleteriousHabit', 'hasMalocclusion'),
    ('Comorbidade sistêmica × Exodontia / Endodontia', 'hasComorbidity', 'hasExtractionOrEndo'),
    ('Risco clínico alto (DTM) × Absenteísmo (Falta)', 'highDtmRisk', 'hasMissedAppointment'),
  ];

  static String labelForKey(String key) {
    for (final v in binaryVariables) {
      if (v.key == key) return v.label;
    }
    return key;
  }

  /// Calcula tabela de contingência 2×2, Qui-Quadrado de Pearson (df=1), p-valor exato,
  /// Odds Ratio (com IC 95% de Woolf) e Razão de Prevalência (RP).
  static Contingency2x2Result compute2x2(
    List<Map<String, dynamic>> dataset,
    String exposureKey,
    String outcomeKey,
  ) {
    int a = 0, b = 0, c = 0, d = 0;
    for (final row in dataset) {
      final exp = row[exposureKey] == true;
      final out = row[outcomeKey] == true;
      if (exp && out) {
        a++;
      } else if (exp && !out) {
        b++;
      } else if (!exp && out) {
        c++;
      } else {
        d++;
      }
    }

    final n = a + b + c + d;
    final r1 = a + b;
    final r2 = c + d;
    final c1 = a + c;
    final c2 = b + d;

    double chi2 = 0.0;
    double pVal = 1.0;

    if (n > 0 && r1 > 0 && r2 > 0 && c1 > 0 && c2 > 0) {
      final num = (a * d - b * c).toDouble();
      final denom = (r1 * r2 * c1 * c2).toDouble();
      chi2 = (n * num * num) / denom;
      pVal = _chiSquareDf1PValue(chi2);
    }

    // Odds Ratio e IC 95% (correção de Haldane-Anscombe +0,5 se houver zero em alguma célula)
    double? orVal;
    double? orLow;
    double? orHigh;
    if (r1 > 0 && r2 > 0 && c1 > 0 && c2 > 0) {
      final hasZero = a == 0 || b == 0 || c == 0 || d == 0;
      final aa = hasZero ? a + 0.5 : a.toDouble();
      final bb = hasZero ? b + 0.5 : b.toDouble();
      final cc = hasZero ? c + 0.5 : c.toDouble();
      final dd = hasZero ? d + 0.5 : d.toDouble();
      orVal = (aa * dd) / (bb * cc);
      final se = math.sqrt((1 / aa) + (1 / bb) + (1 / cc) + (1 / dd));
      final logOr = math.log(orVal);
      orLow = math.exp(logOr - 1.96 * se);
      orHigh = math.exp(logOr + 1.96 * se);
    }

    // Razão de Prevalência (RP)
    double? pr;
    if (r1 > 0 && r2 > 0 && c > 0) {
      pr = (a / r1) / (c / r2);
    } else if (r1 > 0 && r2 > 0 && a > 0 && c == 0) {
      pr = ((a + 0.5) / (r1 + 1.0)) / (0.5 / (r2 + 1.0));
    }

    return Contingency2x2Result(
      exposureLabel: labelForKey(exposureKey),
      outcomeLabel: labelForKey(outcomeKey),
      a: a,
      b: b,
      c: c,
      d: d,
      chiSquare: chi2,
      pValue: pVal,
      oddsRatio: orVal,
      oddsRatioCiLow: orLow,
      oddsRatioCiHigh: orHigh,
      prevalenceRatio: pr,
    );
  }

  /// Para 1 grau de liberdade, P(X² >= x) = erfc(sqrt(x / 2)).
  static double _chiSquareDf1PValue(double chi2) {
    if (chi2 <= 0) return 1.0;
    return _erfc(math.sqrt(chi2 / 2.0)).clamp(0.0, 1.0);
  }

  /// Aproximação de Abramowitz & Stegun (7.1.26) para erfc(x), erro < 1.5e-7.
  static double _erfc(double x) {
    final z = x.abs();
    final t = 1.0 / (1.0 + 0.3275911 * z);
    final poly = t *
        (0.254829592 +
            t *
                (-0.284496736 +
                    t * (1.421413741 + t * (-1.453152027 + t * 1.061405429))));
    final res = poly * math.exp(-z * z);
    return x >= 0 ? res : 2.0 - res;
  }

  static double mean(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double median(List<double> values) {
    if (values.isEmpty) return 0.0;
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isEven
        ? (sorted[mid - 1] + sorted[mid]) / 2.0
        : sorted[mid];
  }

  static double stdDev(List<double> values) {
    if (values.length <= 1) return 0.0;
    final avg = mean(values);
    final sumSq = values.fold<double>(0.0, (acc, v) => acc + math.pow(v - avg, 2));
    return math.sqrt(sumSq / (values.length - 1));
  }

  /// Exporta base de pacientes anonimizada (sem nome, CPF ou telefone) em CSV UTF-8 com BOM
  /// pronto para Excel, R, Python, SPSS e Jamovi.
  static Future<File> exportAnonymizedCsv(List<Map<String, dynamic>> dataset) async {
    const columns = [
      'code',
      'age',
      'ageGroup',
      'gender',
      'city',
      'cpod',
      'hasCaries',
      'hasExtractionOrEndo',
      'hasComorbidity',
      'hasAllergy',
      'hasSugaryDiet',
      'hasDeleteriousHabit',
      'hasMalocclusion',
      'ipvPercent',
      'isgPercent',
      'highIpv',
      'highDtmRisk',
      'hasMissedAppointment',
      'totalAppointments',
      'completedProcedures',
      'hasAnamnese',
      'hasOdontogram',
      'hasTreatmentPlan',
      'hasEvolution',
      'hasLgpdConsent',
      'hasOdontopediatria',
      'hasDtm',
      'hasPpr',
      'hasEndodontia',
      'hasPeriograma',
    ];

    String escapeCsv(dynamic val) {
      if (val == null) return '';
      if (val is bool) return val ? '1' : '0';
      final s = val.toString().replaceAll('"', '""');
      if (s.contains(';') || s.contains(',') || s.contains('"') || s.contains('\n')) {
        return '"$s"';
      }
      return s;
    }

    final buffer = StringBuffer('\uFEFF'); // UTF-8 BOM para Excel pt-BR
    buffer.writeln(columns.join(';'));
    for (final row in dataset) {
      buffer.writeln(columns.map((c) => escapeCsv(row[c])).join(';'));
    }

    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/estudo_estatistico_anonimizado_$stamp.csv');
    await file.writeAsString(buffer.toString());
    return file;
  }

  /// Gera relatório executivo em PDF consolidando os 5 grupos de estudos estatísticos.
  static Future<File> exportStatisticalSummaryPdf(Map<String, dynamic> payload) async {
    final doc = pw.Document();
    final epi = _asMap(payload['epidemiological']);
    final odo = _asMap(epi['odontogram']);
    final ped = _asMap(epi['pediatric']);
    final lon = _asMap(payload['longitudinal']);
    final plans = _asMap(lon['treatmentPlans']);
    final mgmt = _asMap(payload['management']);
    final timing = _asMap(mgmt['timing']);
    final qual = _asMap(payload['quality']);
    final gov = _asMap(qual['governance']);
    final lgpd = _asMap(qual['lgpd']);
    final dataset = _asListOfMaps(payload['patientDataset']);

    final primary = PdfColor.fromHex('#006494');
    final nowStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final assocRows = presetAssociations.map((preset) {
      final res = compute2x2(dataset, preset.$2, preset.$3);
      return [
        preset.$1,
        '${res.a}/${res.exposedTotal} (${res.exposedRate.toStringAsFixed(1)}%)',
        '${res.c}/${res.unexposedTotal} (${res.unexposedRate.toStringAsFixed(1)}%)',
        res.hasSufficientSample ? res.chiSquare.toStringAsFixed(2) : '-',
        res.hasSufficientSample ? res.pValue.toStringAsFixed(4) : '-',
        res.oddsRatio != null ? res.oddsRatio!.toStringAsFixed(2) : '-',
      ];
    }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: primary,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PAINEL ESTATÍSTICO — ESTUDOS CLÍNICOS E EPIDEMIOLÓGICOS',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Gerado em $nowStr • Fonte: ${payload['source'] ?? 'local'} • N = ${epi['totalPatients'] ?? 0} paciente(s)',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 9),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Text('1. Estudo Epidemiológico Descritivo', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primary)),
          pw.SizedBox(height: 4),
          pw.Text(
            'Pacientes: ${epi['totalPatients'] ?? 0} | Idade média: ${epi['averageAge'] ?? 0} ± ${epi['stdDevAge'] ?? 0} anos (mediana ${epi['medianAge'] ?? 0}) | CPO-D médio: ${odo['cpodMean'] ?? 0} | IPV médio: ${ped['ipvMean'] ?? 0}% | ISG médio: ${ped['isgMean'] ?? 0}%',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          pw.Text('2. Estudos Analíticos de Associação (2×2)', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primary)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold),
            headerDecoration: pw.BoxDecoration(color: primary),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headers: const ['Hipótese', 'Expostos', 'Não Expostos', 'Chi²', 'p-valor', 'OR'],
            data: assocRows,
          ),
          pw.SizedBox(height: 12),
          pw.Text('3. Estudo Longitudinal e Efetividade Clínica', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primary)),
          pw.SizedBox(height: 4),
          pw.Text(
            'Planos de Tratamento: ${plans['totalPlans'] ?? 0} (Concluídos: ${plans['completedPlans'] ?? 0} • ${plans['completionRate'] ?? 0}%) | Tempo médio conclusão: ${plans['avgDaysToComplete'] ?? 0} dias',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          pw.Text('4. Gestão, Produtividade e Fluxo Assistencial', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primary)),
          pw.SizedBox(height: 4),
          pw.Text(
            'Agendamentos: ${mgmt['totalAppointments'] ?? 0} | Concluídos: ${mgmt['completionRate'] ?? 0}% | Absenteísmo (Faltas): ${mgmt['absenteeismRate'] ?? 0}% | Espera média: ${timing['avgWaitMinutes'] ?? 0} min | Duração média: ${timing['avgDurationMinutes'] ?? 0} min',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          pw.Text('5. Qualidade do Prontuário e Conformidade LGPD', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primary)),
          pw.SizedBox(height: 4),
          pw.Text(
            'Evoluções assinadas: ${gov['signedEvolutions'] ?? 0}/${gov['totalEvolutions'] ?? 0} (${gov['signedRate'] ?? 0}%) | Pendentes: ${gov['pendingSignatures'] ?? 0} | Adesão TCLE/LGPD: ${lgpd['adherenceRate'] ?? 0}%',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/relatorio_estatistico_$stamp.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static Map<String, dynamic> _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : const <String, dynamic>{};

  static List<Map<String, dynamic>> _asListOfMaps(dynamic v) {
    if (v is! List) return const [];
    return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
