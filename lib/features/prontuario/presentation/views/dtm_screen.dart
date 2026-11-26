import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/services/prontuario_pdf_service.dart';
import '../viewmodels/endodontia_viewmodel.dart';
import '../viewmodels/prontuario_summary_provider.dart';

class DtmTratamentoRow {
  String data;
  String dente;
  String tratamentoRealizado;

  DtmTratamentoRow({
    this.data = '',
    this.dente = '',
    this.tratamentoRealizado = '',
  });

  factory DtmTratamentoRow.fromMap(Map<String, dynamic> map) => DtmTratamentoRow(
        data: map['data']?.toString() ?? '',
        dente: map['dente']?.toString() ?? '',
        tratamentoRealizado: map['tratamentoRealizado']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'data': data,
        'dente': dente,
        'tratamentoRealizado': tratamentoRealizado,
      };
}

class CorDentesRow {
  String anterior;
  String canino;
  String posterior;

  CorDentesRow({
    this.anterior = '',
    this.canino = '',
    this.posterior = '',
  });

  factory CorDentesRow.fromMap(Map<String, dynamic>? map) => CorDentesRow(
        anterior: map?['anterior']?.toString() ?? '',
        canino: map?['canino']?.toString() ?? '',
        posterior: map?['posterior']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'anterior': anterior,
        'canino': canino,
        'posterior': posterior,
      };
}

class FichaDtmModel {
  String profissional;
  String data;

  // AVALIAÇÃO DE RISCO: 'alto' | 'moderado' | 'baixo' | ''
  String riscoCarie;
  String riscoOclusal;
  String riscoDtm;

  // COR DOS DENTES
  CorDentesRow corAtual;
  CorDentesRow aposClareamento;
  CorDentesRow corPorcelanaResina;

  // TRATAMENTO REALIZADO
  List<DtmTratamentoRow> tratamentos;

  FichaDtmModel({
    this.profissional = 'Dra. Andrea Alac',
    this.data = '',
    this.riscoCarie = '',
    this.riscoOclusal = '',
    this.riscoDtm = '',
    CorDentesRow? corAtual,
    CorDentesRow? aposClareamento,
    CorDentesRow? corPorcelanaResina,
    List<DtmTratamentoRow>? tratamentos,
  })  : corAtual = corAtual ?? CorDentesRow(),
        aposClareamento = aposClareamento ?? CorDentesRow(),
        corPorcelanaResina = corPorcelanaResina ?? CorDentesRow(),
        tratamentos = tratamentos ?? List.generate(12, (_) => DtmTratamentoRow());

  factory FichaDtmModel.fromMap(Map<String, dynamic> map) {
    final rawRows = map['tratamentos'];
    final rows = <DtmTratamentoRow>[];
    if (rawRows is List) {
      for (final item in rawRows) {
        if (item is Map) {
          rows.add(DtmTratamentoRow.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }
    while (rows.length < 12) {
      rows.add(DtmTratamentoRow());
    }

    Map<String, dynamic>? asMap(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;

    return FichaDtmModel(
      profissional: (map['profissional']?.toString().trim().isNotEmpty ?? false)
          ? map['profissional'].toString()
          : 'Dra. Andrea Alac',
      data: map['data']?.toString() ?? '',
      riscoCarie: map['riscoCarie']?.toString() ?? '',
      riscoOclusal: map['riscoOclusal']?.toString() ?? '',
      riscoDtm: map['riscoDtm']?.toString() ?? '',
      corAtual: CorDentesRow.fromMap(asMap(map['corAtual'])),
      aposClareamento: CorDentesRow.fromMap(asMap(map['aposClareamento'])),
      corPorcelanaResina: CorDentesRow.fromMap(asMap(map['corPorcelanaResina'])),
      tratamentos: rows,
    );
  }

  Map<String, dynamic> toMap() => {
        'profissional': profissional,
        'data': data,
        'riscoCarie': riscoCarie,
        'riscoOclusal': riscoOclusal,
        'riscoDtm': riscoDtm,
        'corAtual': corAtual.toMap(),
        'aposClareamento': aposClareamento.toMap(),
        'corPorcelanaResina': corPorcelanaResina.toMap(),
        'tratamentos': tratamentos.map((r) => r.toMap()).toList(),
      };
}

class DtmScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const DtmScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  ConsumerState<DtmScreen> createState() => _DtmScreenState();
}

class _DtmScreenState extends ConsumerState<DtmScreen> {
  static const Color _primaryColor = Color(0xFF006494);
  static const List<String> _riskOptions = ['alto', 'moderado', 'baixo'];

  FichaDtmModel _model = FichaDtmModel();
  bool _initialized = false;
  bool _saving = false;

  late final TextEditingController _profissionalCtrl;
  late final TextEditingController _dataCtrl;

  late final TextEditingController _corAtualAntCtrl;
  late final TextEditingController _corAtualCanCtrl;
  late final TextEditingController _corAtualPosCtrl;

  late final TextEditingController _aposClarAntCtrl;
  late final TextEditingController _aposClarCanCtrl;
  late final TextEditingController _aposClarPosCtrl;

  late final TextEditingController _porcResAntCtrl;
  late final TextEditingController _porcResCanCtrl;
  late final TextEditingController _porcResPosCtrl;

  final List<({TextEditingController data, TextEditingController dente, TextEditingController tratamento})>
      _rowControllers = [];

  String get _storageKey => 'dtm_${widget.patientId}';

  @override
  void initState() {
    super.initState();
    _profissionalCtrl = TextEditingController(text: _model.profissional);
    _dataCtrl = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );
    _corAtualAntCtrl = TextEditingController();
    _corAtualCanCtrl = TextEditingController();
    _corAtualPosCtrl = TextEditingController();
    _aposClarAntCtrl = TextEditingController();
    _aposClarCanCtrl = TextEditingController();
    _aposClarPosCtrl = TextEditingController();
    _porcResAntCtrl = TextEditingController();
    _porcResCanCtrl = TextEditingController();
    _porcResPosCtrl = TextEditingController();
    _rebuildRowControllers();
  }

  void _rebuildRowControllers() {
    for (final c in _rowControllers) {
      c.data.dispose();
      c.dente.dispose();
      c.tratamento.dispose();
    }
    _rowControllers.clear();
    for (final row in _model.tratamentos) {
      _rowControllers.add((
        data: TextEditingController(text: row.data),
        dente: TextEditingController(text: row.dente),
        tratamento: TextEditingController(text: row.tratamentoRealizado),
      ));
    }
  }

  void _hydrate(Map<String, dynamic>? saved) {
    if (_initialized) return;
    _initialized = true;
    if (saved != null) {
      _model = FichaDtmModel.fromMap(saved);
      _profissionalCtrl.text = _model.profissional;
      _dataCtrl.text = _model.data.isNotEmpty
          ? _model.data
          : DateFormat('dd/MM/yyyy').format(DateTime.now());
      _corAtualAntCtrl.text = _model.corAtual.anterior;
      _corAtualCanCtrl.text = _model.corAtual.canino;
      _corAtualPosCtrl.text = _model.corAtual.posterior;
      _aposClarAntCtrl.text = _model.aposClareamento.anterior;
      _aposClarCanCtrl.text = _model.aposClareamento.canino;
      _aposClarPosCtrl.text = _model.aposClareamento.posterior;
      _porcResAntCtrl.text = _model.corPorcelanaResina.anterior;
      _porcResCanCtrl.text = _model.corPorcelanaResina.canino;
      _porcResPosCtrl.text = _model.corPorcelanaResina.posterior;
      _rebuildRowControllers();
    }
  }

  void _syncModelFromControllers() {
    _model.profissional = _profissionalCtrl.text.trim();
    _model.data = _dataCtrl.text.trim();
    _model.corAtual = CorDentesRow(
      anterior: _corAtualAntCtrl.text.trim(),
      canino: _corAtualCanCtrl.text.trim(),
      posterior: _corAtualPosCtrl.text.trim(),
    );
    _model.aposClareamento = CorDentesRow(
      anterior: _aposClarAntCtrl.text.trim(),
      canino: _aposClarCanCtrl.text.trim(),
      posterior: _aposClarPosCtrl.text.trim(),
    );
    _model.corPorcelanaResina = CorDentesRow(
      anterior: _porcResAntCtrl.text.trim(),
      canino: _porcResCanCtrl.text.trim(),
      posterior: _porcResPosCtrl.text.trim(),
    );
    _model.tratamentos = _rowControllers
        .map((c) => DtmTratamentoRow(
              data: c.data.text.trim(),
              dente: c.dente.text.trim(),
              tratamentoRealizado: c.tratamento.text.trim(),
            ))
        .toList();
  }

  @override
  void dispose() {
    _profissionalCtrl.dispose();
    _dataCtrl.dispose();
    _corAtualAntCtrl.dispose();
    _corAtualCanCtrl.dispose();
    _corAtualPosCtrl.dispose();
    _aposClarAntCtrl.dispose();
    _aposClarCanCtrl.dispose();
    _aposClarPosCtrl.dispose();
    _porcResAntCtrl.dispose();
    _porcResCanCtrl.dispose();
    _porcResPosCtrl.dispose();
    for (final c in _rowControllers) {
      c.data.dispose();
      c.dente.dispose();
      c.tratamento.dispose();
    }
    super.dispose();
  }

  Future<void> _saveForm() async {
    _syncModelFromControllers();
    setState(() => _saving = true);
    try {
      await ref
          .read(endodontiaViewModelProvider(_storageKey).notifier)
          .save(_model.toMap());
      ref.invalidate(prontuarioSummaryProvider(widget.patientId));
      ref.invalidate(clinicalTimelineProvider(widget.patientId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ficha DTM salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar ficha DTM: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _exportPdf() async {
    _syncModelFromControllers();
    try {
      final file = await ProntuarioPdfService.generateDtmPdf(
        patientName: widget.patientName,
        dtmData: _model.toMap(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF da Ficha DTM salvo em: ${file.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _addRow() {
    setState(() {
      _model.tratamentos.add(DtmTratamentoRow());
      _rowControllers.add((
        data: TextEditingController(),
        dente: TextEditingController(),
        tratamento: TextEditingController(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(endodontiaViewModelProvider(_storageKey));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DTM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.patientName, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar Ficha DTM em PDF',
            onPressed: _exportPdf,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _saveForm,
              style: FilledButton.styleFrom(backgroundColor: _primaryColor),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Salvar'),
            ),
          ),
        ],
      ),
      body: asyncData.when(
        data: (saved) {
          _hydrate(saved);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const Divider(height: 28),
                      _buildRiskAssessmentSection(),
                      const SizedBox(height: 24),
                      _buildToothColorSection(),
                      const SizedBox(height: 28),
                      _buildTreatmentTableSection(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro ao carregar ficha DTM: $err')),
      ),
    );
  }

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      spacing: 16,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FICHA CLÍNICA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Avaliação de Risco, Cor dos Dentes e Tratamento Realizado (DTM)',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
        SizedBox(
          width: 300,
          child: Column(
            children: [
              TextField(
                controller: _profissionalCtrl,
                decoration: const InputDecoration(
                  labelText: 'Profissional',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dataCtrl,
                decoration: InputDecoration(
                  labelText: 'Data',
                  hintText: 'dd/mm/aaaa',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _dataCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiskAssessmentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVALIAÇÃO DE RISCO (avaliado pela sua dentista)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006494),
            ),
          ),
          const SizedBox(height: 12),
          _buildRiskRow(
            label: 'Risco de Cárie',
            value: _model.riscoCarie,
            onChanged: (v) => setState(() => _model.riscoCarie = v),
          ),
          const Divider(height: 16),
          _buildRiskRow(
            label: 'Risco Oclusal',
            value: _model.riscoOclusal,
            onChanged: (v) => setState(() => _model.riscoOclusal = v),
          ),
          const Divider(height: 16),
          _buildRiskRow(
            label: 'Risco DTM',
            value: _model.riscoDtm,
            onChanged: (v) => setState(() => _model.riscoDtm = v),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskRow({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    Color chipColor(String option) {
      return switch (option) {
        'alto' => Colors.red.shade700,
        'moderado' => Colors.orange.shade800,
        _ => Colors.green.shade700,
      };
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        ..._riskOptions.map((opt) {
          final selected = value == opt;
          final color = chipColor(opt);
          return ChoiceChip(
            label: Text(
              opt,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            selected: selected,
            selectedColor: color,
            onSelected: (_) => onChanged(selected ? '' : opt),
          );
        }),
      ],
    );
  }

  Widget _buildToothColorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COR DOS DENTES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006494),
            ),
          ),
          const SizedBox(height: 12),
          _buildColorRow(
            label: 'cor atual dos dentes',
            anterior: _corAtualAntCtrl,
            canino: _corAtualCanCtrl,
            posterior: _corAtualPosCtrl,
          ),
          const SizedBox(height: 12),
          _buildColorRow(
            label: 'após o clareamento',
            anterior: _aposClarAntCtrl,
            canino: _aposClarCanCtrl,
            posterior: _aposClarPosCtrl,
          ),
          const SizedBox(height: 12),
          _buildColorRow(
            label: 'cor da porcelana ou resina foto',
            anterior: _porcResAntCtrl,
            canino: _porcResCanCtrl,
            posterior: _porcResPosCtrl,
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow({
    required String label,
    required TextEditingController anterior,
    required TextEditingController canino,
    required TextEditingController posterior,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: anterior,
                decoration: const InputDecoration(
                  labelText: 'anterior',
                  isDense: true,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: canino,
                decoration: const InputDecoration(
                  labelText: 'canino',
                  isDense: true,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: posterior,
                decoration: const InputDecoration(
                  labelText: 'posterior',
                  isDense: true,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTreatmentTableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TRATAMENTO REALIZADO',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006494),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Adicionar Linha'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.grey.shade400, width: 1),
          columnWidths: const {
            0: FixedColumnWidth(115),
            1: FixedColumnWidth(85),
            2: FlexColumnWidth(),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  child: Text(
                    'data',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  child: Text(
                    'dente',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Text(
                    'TRATAMENTO REALIZADO',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            ..._rowControllers.map(
              (ctrls) => TableRow(
                children: [
                  TextField(
                    controller: ctrls.data,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      isDense: true,
                      hintText: 'dd/mm/aa',
                      hintStyle: TextStyle(fontSize: 11, color: Colors.black26),
                    ),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  TextField(
                    controller: ctrls.dente,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  TextField(
                    controller: ctrls.tratamento,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
