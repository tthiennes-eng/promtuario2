import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/dashboard/domain/services/statistical_engine.dart';
import 'package:promt/features/dashboard/presentation/viewmodels/statistical_studies_viewmodel.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/features/procedures/presentation/viewmodels/clinics_viewmodel.dart';

class StatisticalPanelWidget extends ConsumerStatefulWidget {
  const StatisticalPanelWidget({super.key});

  @override
  ConsumerState<StatisticalPanelWidget> createState() => _StatisticalPanelWidgetState();
}

class _StatisticalPanelWidgetState extends ConsumerState<StatisticalPanelWidget> {
  static const Color _primary = Color(0xFF006494);

  int _selectedTab = 0;
  String _exposureKey = 'hasSugaryDiet';
  String _outcomeKey = 'hasCaries';
  bool _isExporting = false;

  static const _tabs = [
    (icon: Icons.public_outlined, label: '1. Epidemiológico'),
    (icon: Icons.science_outlined, label: '2. Associações (2×2)'),
    (icon: Icons.timeline_outlined, label: '3. Longitudinal'),
    (icon: Icons.analytics_outlined, label: '4. Gestão e Fluxo'),
    (icon: Icons.verified_user_outlined, label: '5. Qualidade e LGPD'),
  ];

  Map<String, dynamic> _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : const <String, dynamic>{};

  List<Map<String, dynamic>> _asListOfMaps(dynamic v) {
    if (v is! List) return const [];
    return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  num _asNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse((v ?? '').toString()) ?? 0;
  }

  Future<void> _exportCsv(Map<String, dynamic> payload) async {
    setState(() => _isExporting = true);
    try {
      final dataset = _asListOfMaps(payload['patientDataset']);
      final file = await StatisticalEngine.exportAnonymizedCsv(dataset);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Base anonimizada (CSV) exportada em: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar CSV: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportPdf(Map<String, dynamic> payload) async {
    setState(() => _isExporting = true);
    try {
      final file = await StatisticalEngine.exportStatisticalSummaryPdf(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Relatório Estatístico (PDF) salvo em: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar PDF: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(statisticalFilterProvider);
    final studiesAsync = ref.watch(statisticalStudiesProvider);
    final clinics = ref.watch(clinicsViewModelProvider).valueOrNull ?? const <Clinic>[];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(filter, clinics, studiesAsync.valueOrNull),
            _buildTabStrip(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: studiesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 36),
                        const SizedBox(height: 8),
                        Text('Não foi possível calcular as estatísticas: $err'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.invalidate(statisticalStudiesProvider),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (payload) => _buildTabBody(payload),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    StatisticalFilter filter,
    List<Clinic> clinics,
    Map<String, dynamic>? payload,
  ) {
    final source = payload?['source']?.toString();
    final isPg = source == 'postgresql';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006494), Color(0xFF004E75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.query_stats, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Painel Estatístico de Estudos Clínicos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Epidemiologia • Associações 2×2 • Longitudinal • Gestão • Qualidade/LGPD',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (source != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPg ? Icons.cloud_done_outlined : Icons.storage_outlined,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isPg ? 'PostgreSQL' : 'Base Local',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: (_isExporting || payload == null) ? null : () => _exportCsv(payload),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.table_view_outlined, size: 16),
                    label: const Text('Exportar CSV', style: TextStyle(fontSize: 12)),
                  ),
                  OutlinedButton.icon(
                    onPressed: (_isExporting || payload == null) ? null : () => _exportPdf(payload),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                    label: const Text('Exportar PDF', style: TextStyle(fontSize: 12)),
                  ),
                  IconButton(
                    tooltip: 'Atualizar estatísticas',
                    onPressed: () => ref.invalidate(statisticalStudiesProvider),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _headerDropdown<StatisticalPeriodFilter>(
                label: 'Período',
                value: filter.period,
                items: StatisticalPeriodFilter.values
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.label, style: const TextStyle(fontSize: 12.5))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(statisticalFilterProvider.notifier).state = filter.copyWith(period: val);
                  }
                },
              ),
              _headerDropdown<String?>(
                label: 'Clínica',
                value: clinics.any((c) => c.id == filter.clinicId) ? filter.clinicId : null,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todas as Clínicas', style: TextStyle(fontSize: 12.5)),
                  ),
                  ...clinics.map(
                    (c) => DropdownMenuItem<String?>(
                      value: c.id,
                      child: Text(c.name, style: const TextStyle(fontSize: 12.5)),
                    ),
                  ),
                ],
                onChanged: (val) {
                  ref.read(statisticalFilterProvider.notifier).state =
                      filter.copyWith(clinicId: val, clearClinic: val == null);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < _tabs.length; i++) ...[
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedTab == i ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _selectedTab == i ? _primary : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _tabs[i].icon,
                        size: 16,
                        color: _selectedTab == i ? Colors.white : const Color(0xFF475569),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _tabs[i].label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == i ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (i < _tabs.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(Map<String, dynamic> payload) {
    switch (_selectedTab) {
      case 0:
        return _buildEpidemiologicalTab(payload);
      case 1:
        return _buildAssociationsTab(payload);
      case 2:
        return _buildLongitudinalTab(payload);
      case 3:
        return _buildManagementTab(payload);
      case 4:
      default:
        return _buildQualityTab(payload);
    }
  }

  // ---------------------------------------------------------------------------
  // ABA 1 — ESTUDO EPIDEMIOLÓGICO DESCRITIVO
  // ---------------------------------------------------------------------------
  Widget _buildEpidemiologicalTab(Map<String, dynamic> payload) {
    final epi = _asMap(payload['epidemiological']);
    final odo = _asMap(epi['odontogram']);
    final ped = _asMap(epi['pediatric']);
    final dtmRisks = _asMap(epi['dtmRisks']);

    final ageGroups = _asMap(epi['ageGroups']);
    final genderDist = _asMap(epi['genderDistribution']);
    final cityDist = _asMap(epi['cityDistribution']);
    final conditions = _asMap(odo['conditions']);
    final topTeeth = _asListOfMaps(odo['topAffectedTeeth']);
    final comorbidities = _asMap(epi['comorbidities']);
    final angleOcclusion = _asMap(ped['angleOcclusion']);
    final facialProfile = _asMap(ped['facialProfile']);
    final cariesProfile = _asMap(ped['cariesProfile']);

    final translatedConditions = <String, dynamic>{};
    const condLabels = {
      'Healthy': 'Hígido',
      'healthy': 'Hígido',
      'Decayed': 'Cariado',
      'decayed': 'Cariado',
      'Restored': 'Restaurado',
      'restored': 'Restaurado',
      'Missing': 'Ausente / Perdido',
      'missing': 'Ausente / Perdido',
      'Endodontic': 'Endodontia',
      'endodontic': 'Endodontia',
      'Implant': 'Implante',
      'implant': 'Implante',
      'Prosthesis': 'Prótese',
      'prosthesis': 'Prótese',
    };
    conditions.forEach((k, v) {
      final label = condLabels[k] ?? k;
      translatedConditions[label] = (_asNum(translatedConditions[label]) + _asNum(v)).toInt();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _kpiWrap([
          _kpiCard('Pacientes (N)', '${epi['totalPatients'] ?? 0}', 'Base analisada', Icons.groups_outlined, Colors.blue),
          _kpiCard('Idade Média', '${epi['averageAge'] ?? 0} anos', 'DP ±${epi['stdDevAge'] ?? 0} • Med ${epi['medianAge'] ?? 0}', Icons.cake_outlined, Colors.indigo),
          _kpiCard('CPO-D Médio', '${odo['cpodMean'] ?? 0}', 'Mediana ${odo['cpodMedian'] ?? 0} (${odo['evaluatedPatients'] ?? 0} aval.)', Icons.medical_services_outlined, Colors.teal),
          _kpiCard('IPV Médio', '${ped['ipvMean'] ?? 0}%', 'Mediana ${ped['ipvMedian'] ?? 0}%', Icons.cleaning_services_outlined, Colors.orange),
          _kpiCard('ISG Médio', '${ped['isgMean'] ?? 0}%', 'Mediana ${ped['isgMedian'] ?? 0}%', Icons.water_drop_outlined, Colors.red),
        ]),
        const SizedBox(height: 16),
        _twoColResponsive(
          _distributionCard('Distribuição por Faixa Etária', Icons.bar_chart, ageGroups, Colors.blue),
          _distributionCard('Distribuição por Sexo / Gênero', Icons.wc_outlined, genderDist, Colors.purple),
        ),
        const SizedBox(height: 14),
        _twoColResponsive(
          _distributionCard('Condições no Odontograma', Icons.grid_view, translatedConditions, Colors.teal),
          _distributionCard(
            'Dentes Mais Acometidos',
            Icons.troubleshoot_outlined,
            {for (final t in topTeeth) 'Dente ${t['tooth']}': t['count']},
            Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 14),
        _twoColResponsive(
          _distributionCard('Prevalência de Comorbidades / Alergias', Icons.monitor_heart_outlined, comorbidities, Colors.red.shade700),
          _distributionCard('Distribuição por Cidade', Icons.location_city_outlined, cityDist, Colors.indigo),
        ),
        const SizedBox(height: 14),
        _twoColResponsive(
          _buildDtmRiskCard(dtmRisks),
          _subCard(
            'Odontopediatria — Oclusão, Perfil Facial e Cárie',
            Icons.child_care_outlined,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _miniGroup('Classificação da Oclusão (Angle)', angleOcclusion, Colors.teal),
                const SizedBox(height: 10),
                _miniGroup('Perfil Facial', facialProfile, Colors.indigo),
                const SizedBox(height: 10),
                _miniGroup('Perfil de Cárie', cariesProfile, Colors.orange.shade800),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDtmRiskCard(Map<String, dynamic> dtmRisks) {
    Widget riskRow(String label, String key) {
      final m = _asMap(dtmRisks[key]);
      final baixo = _asNum(m['baixo']).toInt();
      final mod = _asNum(m['moderado']).toInt();
      final alto = _asNum(m['alto']).toInt();
      final total = baixo + mod + alto;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text('Baixo: $baixo • Mod: $mod • Alto: $alto', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                child: total == 0
                    ? Container(color: Colors.grey.shade200)
                    : Row(
                        children: [
                          if (baixo > 0) Expanded(flex: baixo, child: Container(color: Colors.green.shade500)),
                          if (mod > 0) Expanded(flex: mod, child: Container(color: Colors.amber.shade600)),
                          if (alto > 0) Expanded(flex: alto, child: Container(color: Colors.red.shade600)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      );
    }

    return _subCard(
      'Avaliação de Risco Clínico (Ficha DTM)',
      Icons.warning_amber_outlined,
      Column(
        children: [
          riskRow('Risco de Cárie', 'carie'),
          riskRow('Risco Oclusal', 'oclusal'),
          riskRow('Risco DTM', 'dtm'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ABA 2 — ESTUDOS ANALÍTICOS DE ASSOCIAÇÃO E FATORES DE RISCO (2×2)
  // ---------------------------------------------------------------------------
  Widget _buildAssociationsTab(Map<String, dynamic> payload) {
    final dataset = _asListOfMaps(payload['patientDataset']);
    final currentResult = StatisticalEngine.compute2x2(dataset, _exposureKey, _outcomeKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _subCard(
          'Construtor Interativo de Estudo Analítico 2×2 (Qui-Quadrado, Odds Ratio e Razão de Prevalência)',
          Icons.science_outlined,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final expDrop = DropdownButtonFormField<String>(
                    key: ValueKey('exp_$_exposureKey'),
                    initialValue: _exposureKey,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Variável de Exposição (Fator de Risco)',
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: StatisticalEngine.binaryVariables
                        .map((v) => DropdownMenuItem(value: v.key, child: Text(v.label, style: const TextStyle(fontSize: 12.5))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _exposureKey = v);
                    },
                  );
                  final outDrop = DropdownButtonFormField<String>(
                    key: ValueKey('out_$_outcomeKey'),
                    initialValue: _outcomeKey,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Variável de Desfecho (Evento Clínico)',
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: StatisticalEngine.binaryVariables
                        .map((v) => DropdownMenuItem(value: v.key, child: Text(v.label, style: const TextStyle(fontSize: 12.5))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _outcomeKey = v);
                    },
                  );
                  if (constraints.maxWidth < 640) {
                    return Column(children: [expDrop, const SizedBox(height: 10), outDrop]);
                  }
                  return Row(children: [Expanded(child: expDrop), const SizedBox(width: 12), Expanded(child: outDrop)]);
                },
              ),
              const SizedBox(height: 16),
              _buildContingencyTable(currentResult),
              const SizedBox(height: 12),
              _kpiWrap([
                _kpiCard(
                  'Qui-Quadrado (χ²)',
                  currentResult.hasSufficientSample ? currentResult.chiSquare.toStringAsFixed(2) : '—',
                  '1 grau de liberdade',
                  Icons.functions,
                  Colors.indigo,
                ),
                _kpiCard(
                  'p-valor',
                  currentResult.hasSufficientSample ? currentResult.pValue.toStringAsFixed(4) : '—',
                  currentResult.isSignificant ? 'Significativo (p < 0,05)' : 'Não signif. (α = 5%)',
                  Icons.verified_outlined,
                  currentResult.isSignificant ? Colors.green.shade700 : Colors.blueGrey,
                ),
                _kpiCard(
                  'Odds Ratio (OR)',
                  currentResult.oddsRatio != null ? currentResult.oddsRatio!.toStringAsFixed(2) : '—',
                  currentResult.oddsRatioCiLow != null
                      ? 'IC 95%: ${currentResult.oddsRatioCiLow!.toStringAsFixed(2)}–${currentResult.oddsRatioCiHigh!.toStringAsFixed(2)}'
                      : 'Requer 4 células',
                  Icons.compare_arrows,
                  Colors.teal,
                ),
                _kpiCard(
                  'Razão de Prevalência',
                  currentResult.prevalenceRatio != null ? currentResult.prevalenceRatio!.toStringAsFixed(2) : '—',
                  'Expostos / Não expostos',
                  Icons.percent,
                  Colors.orange.shade800,
                ),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: currentResult.isSignificant ? Colors.green.shade50 : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: currentResult.isSignificant ? Colors.green.shade300 : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      currentResult.isSignificant ? Icons.check_circle_outline : Icons.info_outline,
                      color: currentResult.isSignificant ? Colors.green.shade800 : Colors.blueGrey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        currentResult.interpretation,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: currentResult.isSignificant ? Colors.green.shade900 : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _subCard(
          'Hipóteses Clínicas Pré-Configuradas (toque para carregar no construtor acima)',
          Icons.auto_graph_outlined,
          Column(
            children: StatisticalEngine.presetAssociations.map((preset) {
              final res = StatisticalEngine.compute2x2(dataset, preset.$2, preset.$3);
              final isSelected = _exposureKey == preset.$2 && _outcomeKey == preset.$3;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _primary.withValues(alpha: 0.06) : const Color(0xFFFAFBFD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? _primary : Colors.grey.shade200),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() {
                    _exposureKey = preset.$2;
                    _outcomeKey = preset.$3;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          preset.$1,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            _pill('Expostos: ${res.exposedRate.toStringAsFixed(1)}%', Colors.blue),
                            _pill('Não exp.: ${res.unexposedRate.toStringAsFixed(1)}%', Colors.blueGrey),
                            _pill(
                              res.hasSufficientSample ? 'p = ${res.pValue.toStringAsFixed(3)}' : 'N insuf.',
                              res.isSignificant ? Colors.green.shade700 : Colors.grey.shade700,
                            ),
                            if (res.oddsRatio != null)
                              _pill('OR = ${res.oddsRatio!.toStringAsFixed(2)}', Colors.teal),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContingencyTable(Contingency2x2Result r) {
    Widget cell(String text, {bool header = false, Color? bg}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        color: bg ?? (header ? const Color(0xFFF1F5F9) : Colors.white),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: header ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(135),
        columnWidths: const {0: FixedColumnWidth(160)},
        border: TableBorder.all(color: Colors.grey.shade300),
        children: [
          TableRow(children: [
            cell('Tabela 2×2 (N = ${r.total})', header: true),
            cell('Desfecho (+)', header: true),
            cell('Sem Desfecho (-)', header: true),
            cell('Total', header: true),
            cell('Taxa Desfecho', header: true),
          ]),
          TableRow(children: [
            cell('Exposto (+)', header: true),
            cell('${r.a}', bg: Colors.blue.shade50),
            cell('${r.b}'),
            cell('${r.exposedTotal}', header: true),
            cell('${r.exposedRate.toStringAsFixed(1)}%', header: true),
          ]),
          TableRow(children: [
            cell('Não Exposto (-)', header: true),
            cell('${r.c}', bg: Colors.blue.shade50),
            cell('${r.d}'),
            cell('${r.unexposedTotal}', header: true),
            cell('${r.unexposedRate.toStringAsFixed(1)}%', header: true),
          ]),
          TableRow(children: [
            cell('Total', header: true),
            cell('${r.outcomeTotal}', header: true),
            cell('${r.noOutcomeTotal}', header: true),
            cell('${r.total}', header: true),
            cell(
              r.total > 0 ? '${((r.outcomeTotal / r.total) * 100).toStringAsFixed(1)}%' : '0.0%',
              header: true,
            ),
          ]),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ABA 3 — ESTUDO LONGITUDINAL E EFETIVIDADE CLÍNICA
  // ---------------------------------------------------------------------------
  Widget _buildLongitudinalTab(Map<String, dynamic> payload) {
    final lon = _asMap(payload['longitudinal']);
    final ipvEvo = _asMap(lon['ipvEvolution']);
    final isgEvo = _asMap(lon['isgEvolution']);
    final plans = _asMap(lon['treatmentPlans']);
    final procedures = _asListOfMaps(plans['procedures']);
    final rxCert = _asMap(lon['prescriptionsAndCertificates']);
    final topMeds = _asListOfMaps(rxCert['topMedications']);
    final topCids = _asListOfMaps(rxCert['topCids']);
    final monthly = _asListOfMaps(lon['monthlyTrend']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _kpiWrap([
          _kpiCard(
            'Evolução IPV (v1→vN)',
            '${ipvEvo['meanV1'] ?? 0}% → ${ipvEvo['meanLatest'] ?? 0}%',
            'Δ ${ipvEvo['delta'] ?? 0}% (${ipvEvo['pairedPatients'] ?? 0} pareados)',
            Icons.trending_down,
            Colors.teal,
          ),
          _kpiCard(
            'Evolução ISG (v1→vN)',
            '${isgEvo['meanV1'] ?? 0}% → ${isgEvo['meanLatest'] ?? 0}%',
            'Δ ${isgEvo['delta'] ?? 0}% (${isgEvo['pairedPatients'] ?? 0} pareados)',
            Icons.water_drop_outlined,
            Colors.indigo,
          ),
          _kpiCard(
            'Planos Concluídos',
            '${plans['completionRate'] ?? 0}%',
            '${plans['completedPlans'] ?? 0} de ${plans['totalPlans'] ?? 0} planos',
            Icons.assignment_turned_in_outlined,
            Colors.green.shade700,
          ),
          _kpiCard(
            'Tempo Médio Conclusão',
            '${plans['avgDaysToComplete'] ?? 0} dias',
            'Da criação à conclusão',
            Icons.schedule_outlined,
            Colors.orange.shade800,
          ),
          _kpiCard(
            'Receitas / Atestados',
            '${rxCert['totalPrescriptions'] ?? 0} / ${rxCert['totalCertificates'] ?? 0}',
            'Média afast.: ${rxCert['avgRestDays'] ?? 0} dias',
            Icons.description_outlined,
            Colors.purple,
          ),
        ]),
        const SizedBox(height: 16),
        _subCard(
          'Série Temporal Mensal — Últimos 6 Meses',
          Icons.show_chart,
          monthly.isEmpty
              ? const Text('Sem dados mensais registrados.')
              : _buildMonthlyTrendTable(monthly),
        ),
        const SizedBox(height: 14),
        _subCard(
          'Efetividade por Procedimento do Plano de Tratamento',
          Icons.checklist_outlined,
          procedures.isEmpty
              ? const Text('Nenhum procedimento registrado nos planos de tratamento.', style: TextStyle(color: Colors.grey))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 38,
                    dataRowMinHeight: 36,
                    dataRowMaxHeight: 44,
                    columns: const [
                      DataColumn(label: Text('Procedimento', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(numeric: true, label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(numeric: true, label: Text('Concluídos', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(numeric: true, label: Text('Em Andam.', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(numeric: true, label: Text('Pendentes', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(numeric: true, label: Text('Taxa Concl.', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: procedures.map((p) {
                      final total = _asNum(p['total']).toInt();
                      final done = _asNum(p['completed']).toInt();
                      final pct = total > 0 ? (done / total * 100).toStringAsFixed(1) : '0.0';
                      return DataRow(cells: [
                        DataCell(Text((p['procedure'] ?? '').toString())),
                        DataCell(Text('$total')),
                        DataCell(Text('$done', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold))),
                        DataCell(Text('${p['inProgress'] ?? 0}')),
                        DataCell(Text('${p['pending'] ?? 0}')),
                        DataCell(Text('$pct%')),
                      ]);
                    }).toList(),
                  ),
                ),
        ),
        const SizedBox(height: 14),
        _twoColResponsive(
          _distributionCard(
            'Medicamentos Mais Prescritos',
            Icons.medication_outlined,
            {for (final m in topMeds) (m['name'] ?? '').toString(): m['count']},
            Colors.purple,
          ),
          _distributionCard(
            'Principais CIDs em Atestados',
            Icons.article_outlined,
            {for (final c in topCids) 'CID ${c['cid']}': c['count']},
            Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendTable(List<Map<String, dynamic>> monthly) {
    final maxAppts = monthly
        .map((m) => _asNum(m['appointments']).toInt())
        .fold<int>(1, (a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final m in monthly)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 68,
                  child: Text(
                    (m['month'] ?? '').toString(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (_asNum(m['appointments']) / maxAppts).clamp(0.0, 1.0),
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Ag: ${m['appointments']} • Concl: ${m['completed']} • Faltas: ${m['missed']} • Evol: ${m['evolutions']}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ABA 4 — GESTÃO, PRODUTIVIDADE E FLUXO ASSISTENCIAL
  // ---------------------------------------------------------------------------
  Widget _buildManagementTab(Map<String, dynamic> payload) {
    final mgmt = _asMap(payload['management']);
    final timing = _asMap(mgmt['timing']);
    final waitList = _asMap(mgmt['waitList']);
    final byClinic = _asListOfMaps(mgmt['absenteeismByClinic']);
    final byWeekday = _asListOfMaps(mgmt['absenteeismByWeekday']);
    final byPeriod = _asListOfMaps(mgmt['absenteeismByPeriod']);
    final byStudent = _asListOfMaps(mgmt['productivityByStudent']);
    final byProfessor = _asListOfMaps(mgmt['productivityByProfessor']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _kpiWrap([
          _kpiCard('Agendamentos', '${mgmt['totalAppointments'] ?? 0}', 'No período filtrado', Icons.event_note, Colors.blue),
          _kpiCard('Taxa de Conclusão', '${mgmt['completionRate'] ?? 0}%', '${mgmt['completedAppointments'] ?? 0} concluídos', Icons.task_alt, Colors.green.shade700),
          _kpiCard('Absenteísmo (Faltas)', '${mgmt['absenteeismRate'] ?? 0}%', '${mgmt['missedAppointments'] ?? 0} faltas • ${mgmt['cancelledAppointments'] ?? 0} canc.', Icons.person_off_outlined, Colors.red.shade700),
          _kpiCard('Tempo Médio Espera', '${timing['avgWaitMinutes'] ?? 0} min', 'Atraso: ${timing['avgDelayMinutes'] ?? 0} min • Dur: ${timing['avgDurationMinutes'] ?? 0} min', Icons.timer_outlined, Colors.indigo),
          _kpiCard('Lista de Espera', '${waitList['pending'] ?? 0} pend.', 'Total ${waitList['total'] ?? 0} • Média ${waitList['avgWaitDays'] ?? 0} dias', Icons.hourglass_bottom, Colors.orange.shade800),
        ]),
        const SizedBox(height: 16),
        _subCard(
          'Absenteísmo e Volume por Clínica',
          Icons.local_hospital_outlined,
          byClinic.isEmpty
              ? const Text('Nenhum agendamento encontrado para o filtro selecionado.', style: TextStyle(color: Colors.grey))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 38,
                    dataRowMinHeight: 36,
                    dataRowMaxHeight: 44,
                    columns: const [
                      DataColumn(label: Text('Clínica', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(numeric: true, label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(numeric: true, label: Text('Concluídos', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(numeric: true, label: Text('Faltas', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(numeric: true, label: Text('Cancelados', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(numeric: true, label: Text('Absenteísmo %', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: byClinic.map((c) {
                      final rate = _asNum(c['absenteeismRate']).toDouble();
                      return DataRow(cells: [
                        DataCell(Text((c['clinic'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(Text('${c['total']}')),
                        DataCell(Text('${c['completed']}', style: TextStyle(color: Colors.green.shade800))),
                        DataCell(Text('${c['missed']}', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold))),
                        DataCell(Text('${c['cancelled']}')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: rate >= 20 ? Colors.red.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${rate.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: rate >= 20 ? Colors.red.shade800 : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
        ),
        const SizedBox(height: 14),
        _twoColResponsive(
          _rateListCard(
            'Absenteísmo por Dia da Semana',
            Icons.calendar_view_week_outlined,
            byWeekday
                .map((d) => (
                      label: '${d['day']} (${d['missed']}/${d['total']})',
                      percent: _asNum(d['rate']).toDouble(),
                    ))
                .toList(),
            Colors.red.shade600,
          ),
          _rateListCard(
            'Absenteísmo por Turno',
            Icons.wb_sunny_outlined,
            byPeriod
                .map((p) => (
                      label: '${p['period']} (${p['missed']}/${p['total']})',
                      percent: _asNum(p['rate']).toDouble(),
                    ))
                .toList(),
            Colors.orange.shade700,
          ),
        ),
        const SizedBox(height: 14),
        _twoColResponsive(
          _distributionCard(
            'Produtividade por Aluno / Dupla (Evoluções)',
            Icons.school_outlined,
            {for (final s in byStudent) (s['name'] ?? '').toString(): s['evolutions']},
            Colors.blue,
          ),
          _distributionCard(
            'Supervisão por Professor (Evoluções)',
            Icons.supervisor_account_outlined,
            {for (final p in byProfessor) (p['name'] ?? '').toString(): p['evolutions']},
            Colors.teal,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ABA 5 — QUALIDADE DO PRONTUÁRIO, AUDITORIA E LGPD
  // ---------------------------------------------------------------------------
  Widget _buildQualityTab(Map<String, dynamic> payload) {
    final qual = _asMap(payload['quality']);
    final completeness = _asMap(qual['completeness']);
    final gov = _asMap(qual['governance']);
    final lgpd = _asMap(qual['lgpd']);

    const labels = <String, String>{
      'anamnese': 'Anamnese',
      'odontograma': 'Odontograma',
      'planoTratamento': 'Plano de Tratamento',
      'evolucao': 'Evolução Clínica',
      'tcleLgpd': 'TCLE / Consentimento LGPD',
      'extraoral': 'Exame Extraoral',
      'intraoral': 'Exame Intraoral',
      'periograma': 'Periograma',
      'endodontia': 'Endodontia',
      'ppr': 'PPR',
      'dtm': 'DTM',
      'odontopediatria': 'Odontopediatria',
    };

    final completenessRows = labels.entries.map((entry) {
      final item = _asMap(completeness[entry.key]);
      return (
        label: '${entry.value} (${item['count'] ?? 0})',
        percent: _asNum(item['percent']).toDouble(),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _kpiWrap([
          _kpiCard(
            'Adesão TCLE / LGPD',
            '${lgpd['adherenceRate'] ?? 0}%',
            '${lgpd['adherentPatients'] ?? 0} de ${lgpd['totalPatients'] ?? 0} pacientes',
            Icons.verified_user_outlined,
            Colors.green.shade700,
          ),
          _kpiCard(
            'Evoluções Assinadas',
            '${gov['signedRate'] ?? 0}%',
            '${gov['signedEvolutions'] ?? 0} de ${gov['totalEvolutions'] ?? 0} evoluções',
            Icons.draw_outlined,
            Colors.blue,
          ),
          _kpiCard(
            'Pendentes de Assinatura',
            '${gov['pendingSignatures'] ?? 0}',
            'Aguardando professor',
            Icons.pending_actions_outlined,
            Colors.orange.shade800,
          ),
          _kpiCard(
            'Tempo Médio Assinatura',
            '${gov['avgHoursToSign'] ?? 0} h',
            'Entre registro e assinatura',
            Icons.access_time,
            Colors.indigo,
          ),
        ]),
        const SizedBox(height: 16),
        _rateListCard(
          'Completude do Prontuário por Ficha Clínica (% de Pacientes)',
          Icons.fact_check_outlined,
          completenessRows,
          _primary,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // COMPONENTES VISUAIS REUTILIZÁVEIS
  // ---------------------------------------------------------------------------
  Widget _kpiWrap(List<Widget> cards) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards,
    );
  }

  Widget _kpiCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      width: 205,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _twoColResponsive(Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 14), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 14),
            Expanded(child: right),
          ],
        );
      },
    );
  }

  Widget _subCard(String title, IconData icon, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: _primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _distributionCard(String title, IconData icon, Map<String, dynamic> map, Color color) {
    final entries = map.entries
        .map((e) => (label: e.key, value: _asNum(e.value).toInt()))
        .where((e) => e.value > 0)
        .toList();

    final maxVal = entries.fold<int>(1, (a, b) => a > b.value ? a : b.value);
    final total = entries.fold<int>(0, (a, b) => a + b.value);

    return _subCard(
      title,
      icon,
      entries.isEmpty
          ? const Text('Sem registros suficientes nesta categoria.', style: TextStyle(fontSize: 12.5, color: Colors.grey))
          : Column(
              children: entries.map((e) {
                final pct = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0.0';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              e.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${e.value} ($pct%)',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (e.value / maxVal).clamp(0.0, 1.0),
                          minHeight: 7,
                          backgroundColor: Colors.grey.shade100,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _rateListCard(
    String title,
    IconData icon,
    List<({String label, double percent})> items,
    Color color,
  ) {
    return _subCard(
      title,
      icon,
      items.isEmpty
          ? const Text('Sem dados disponíveis.', style: TextStyle(fontSize: 12.5, color: Colors.grey))
          : Column(
              children: items.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(e.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                          Text(
                            '${e.percent.toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (e.percent / 100.0).clamp(0.0, 1.0),
                          minHeight: 7,
                          backgroundColor: Colors.grey.shade100,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _miniGroup(String subtitle, Map<String, dynamic> map, Color color) {
    final entries = map.entries.where((e) => _asNum(e.value) > 0).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        if (entries.isEmpty)
          const Text('Sem registros.', style: TextStyle(fontSize: 11.5, color: Colors.grey))
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entries
                .map((e) => _pill('${e.key}: ${e.value}', color))
                .toList(),
          ),
      ],
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
