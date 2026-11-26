import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/endodontia_viewmodel.dart';

// ==========================================
// 1. MODELAGEM DOS DADOS DA FICHA PPR
// ==========================================

class RetentorDiretoRow {
  String dente;
  String apoio;
  String grampos;

  RetentorDiretoRow({
    this.dente = '',
    this.apoio = '',
    this.grampos = '',
  });

  factory RetentorDiretoRow.fromMap(Map<String, dynamic> map) =>
      RetentorDiretoRow(
        dente: map['dente']?.toString() ?? '',
        apoio: map['apoio']?.toString() ?? '',
        grampos: map['grampos']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'dente': dente,
        'apoio': apoio,
        'grampos': grampos,
      };
}

class RetentorIndiretoRow {
  String dente;
  String tipo;

  RetentorIndiretoRow({
    this.dente = '',
    this.tipo = '',
  });

  factory RetentorIndiretoRow.fromMap(Map<String, dynamic> map) =>
      RetentorIndiretoRow(
        dente: map['dente']?.toString() ?? '',
        tipo: map['tipo']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'dente': dente,
        'tipo': tipo,
      };
}

class TrajetoriaRow {
  String dente;
  String local;
  String trajetoria1;
  String trajetoria2;
  String trajetoria3;

  TrajetoriaRow({
    this.dente = '',
    this.local = '',
    this.trajetoria1 = '',
    this.trajetoria2 = '',
    this.trajetoria3 = '',
  });

  factory TrajetoriaRow.fromMap(Map<String, dynamic> map) => TrajetoriaRow(
        dente: map['dente']?.toString() ?? '',
        local: map['local']?.toString() ?? '',
        trajetoria1: map['trajetoria1']?.toString() ?? '',
        trajetoria2: map['trajetoria2']?.toString() ?? '',
        trajetoria3: map['trajetoria3']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'dente': dente,
        'local': local,
        'trajetoria1': trajetoria1,
        'trajetoria2': trajetoria2,
        'trajetoria3': trajetoria3,
      };
}

class PprStroke {
  final int colorValue;
  final List<Offset> points;

  PprStroke({required this.colorValue, required this.points});

  factory PprStroke.fromMap(Map<String, dynamic> map) {
    final rawPoints = (map['points'] as List?) ?? const [];
    final pts = <Offset>[];
    for (final item in rawPoints) {
      if (item is Map) {
        final dx = (item['x'] as num?)?.toDouble();
        final dy = (item['y'] as num?)?.toDouble();
        if (dx != null && dy != null) {
          pts.add(Offset(dx, dy));
        }
      }
    }
    return PprStroke(
      colorValue: (map['color'] as num?)?.toInt() ?? 0xFFD32F2F,
      points: pts,
    );
  }

  Map<String, dynamic> toMap() => {
        'color': colorValue,
        'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      };
}

class FichaPprModel {
  static const int retentoresDiretosCount = 6;
  static const int retentoresIndiretosCount = 4;
  static const int planoGuiaCount = 6;
  static const int areaRetentivaCount = 6;

  static const List<String> tiposDePreparo = [
    'Plano Guia (Guia Vermelha)',
    'Área Retentiva (Guia Incolor)',
    'Nicho',
    'Adequação do Equador Protético',
  ];

  List<RetentorDiretoRow> retentoresDiretos;
  List<RetentorIndiretoRow> retentoresIndiretos;
  bool maxila;
  bool mandibula;
  String classificacaoKennedy;
  List<TrajetoriaRow> planoGuia;
  List<TrajetoriaRow> areaRetentiva;
  Map<String, String> preparos;
  List<PprStroke> desenhoArcada;

  FichaPprModel({
    List<RetentorDiretoRow>? retentoresDiretos,
    List<RetentorIndiretoRow>? retentoresIndiretos,
    this.maxila = false,
    this.mandibula = false,
    this.classificacaoKennedy = '',
    List<TrajetoriaRow>? planoGuia,
    List<TrajetoriaRow>? areaRetentiva,
    Map<String, String>? preparos,
    List<PprStroke>? desenhoArcada,
  })  : retentoresDiretos = retentoresDiretos ??
            List.generate(retentoresDiretosCount, (_) => RetentorDiretoRow()),
        retentoresIndiretos = retentoresIndiretos ??
            List.generate(
                retentoresIndiretosCount, (_) => RetentorIndiretoRow()),
        planoGuia = planoGuia ??
            List.generate(planoGuiaCount, (_) => TrajetoriaRow()),
        areaRetentiva = areaRetentiva ??
            List.generate(areaRetentivaCount, (_) => TrajetoriaRow()),
        preparos = preparos ??
            {for (final tipo in tiposDePreparo) tipo: ''},
        desenhoArcada = desenhoArcada ?? [];

  factory FichaPprModel.fromMap(Map<String, dynamic> map) {
    List<T> parseRows<T>(
      dynamic raw,
      int count,
      T Function(Map<String, dynamic>) fromMap,
      T Function() empty,
    ) {
      final list = <T>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is Map) {
            list.add(fromMap(Map<String, dynamic>.from(item)));
          }
        }
      }
      while (list.length < count) {
        list.add(empty());
      }
      return list;
    }

    final parsedPreparos = <String, String>{
      for (final tipo in tiposDePreparo) tipo: '',
    };
    if (map['preparos'] is Map) {
      final rawPreparos = Map<String, dynamic>.from(map['preparos'] as Map);
      for (final tipo in tiposDePreparo) {
        parsedPreparos[tipo] = rawPreparos[tipo]?.toString() ?? '';
      }
    }

    final parsedStrokes = <PprStroke>[];
    if (map['desenhoArcada'] is List) {
      for (final item in map['desenhoArcada'] as List) {
        if (item is Map) {
          parsedStrokes.add(PprStroke.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    return FichaPprModel(
      retentoresDiretos: parseRows(
        map['retentoresDiretos'],
        retentoresDiretosCount,
        RetentorDiretoRow.fromMap,
        RetentorDiretoRow.new,
      ),
      retentoresIndiretos: parseRows(
        map['retentoresIndiretos'],
        retentoresIndiretosCount,
        RetentorIndiretoRow.fromMap,
        RetentorIndiretoRow.new,
      ),
      maxila: map['maxila'] == true,
      mandibula: map['mandibula'] == true,
      classificacaoKennedy: map['classificacaoKennedy']?.toString() ?? '',
      planoGuia: parseRows(
        map['planoGuia'],
        planoGuiaCount,
        TrajetoriaRow.fromMap,
        TrajetoriaRow.new,
      ),
      areaRetentiva: parseRows(
        map['areaRetentiva'],
        areaRetentivaCount,
        TrajetoriaRow.fromMap,
        TrajetoriaRow.new,
      ),
      preparos: parsedPreparos,
      desenhoArcada: parsedStrokes,
    );
  }

  Map<String, dynamic> toMap() => {
        'retentoresDiretos': retentoresDiretos.map((r) => r.toMap()).toList(),
        'retentoresIndiretos':
            retentoresIndiretos.map((r) => r.toMap()).toList(),
        'maxila': maxila,
        'mandibula': mandibula,
        'classificacaoKennedy': classificacaoKennedy,
        'planoGuia': planoGuia.map((r) => r.toMap()).toList(),
        'areaRetentiva': areaRetentiva.map((r) => r.toMap()).toList(),
        'preparos': preparos,
        'desenhoArcada': desenhoArcada.map((s) => s.toMap()).toList(),
      };
}

// ==========================================
// 2. TELA PRINCIPAL — PPR
// ==========================================

class PprScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const PprScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  ConsumerState<PprScreen> createState() => _PprScreenState();
}

class _PprScreenState extends ConsumerState<PprScreen> {
  static const Color _headerGreen = Color(0xFF1E9E76);
  static const Color _borderGreen = Color(0xFF2AA77F);

  FichaPprModel _model = FichaPprModel();
  bool _initialized = false;
  bool _saving = false;
  Color _activePenColor = const Color(0xFFD32F2F);
  final Map<String, TextEditingController> _controllers = {};

  String get _storageKey => 'ppr_${widget.patientId}';

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String key, String initialValue) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initialValue),
    );
  }

  void _syncControllersFromModel() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
  }

  Future<void> _saveForm() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(endodontiaViewModelProvider(_storageKey).notifier)
          .save(_model.toMap());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ficha de Planejamento e Delineamento – PPR salva!'),
          backgroundColor: _headerGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar ficha PPR: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pprAsync = ref.watch(endodontiaViewModelProvider(_storageKey));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PPR',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.patientName,
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _saveForm,
              style: FilledButton.styleFrom(backgroundColor: _headerGreen),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Salvar'),
            ),
          ),
        ],
      ),
      body: pprAsync.when(
        data: (saved) {
          if (!_initialized) {
            if (saved != null) {
              _model = FichaPprModel.fromMap(saved);
              _syncControllersFromModel();
            }
            _initialized = true;
          }
          return _buildSheet();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro ao carregar ficha PPR: $err')),
      ),
    );
  }

  Widget _buildSheet() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TÍTULO PRINCIPAL
                    const Text(
                      'FICHA DE PLANEJAMENTO e DELINEAMENTO – PPR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // SEÇÃO SUPERIOR: Retentores (esq.) + Arcada / Maxila-Mandíbula / Kennedy (dir.)
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 63,
                            child: Column(
                              children: [
                                _buildRetentoresDiretosTable(),
                                const SizedBox(height: 14),
                                _buildRetentoresIndiretosTable(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 37,
                            child: _buildArchAndClassificationColumn(),
                          ),
                        ],
                      )
                    else ...[
                      _buildRetentoresDiretosTable(),
                      const SizedBox(height: 14),
                      _buildRetentoresIndiretosTable(),
                      const SizedBox(height: 18),
                      _buildArchAndClassificationColumn(),
                    ],

                    const SizedBox(height: 24),

                    // SEÇÃO 1
                    const Text(
                      '1. Determinação da trajetória de Inserção',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '1.a Avaliar Rebordo Residual / Áreas Estéticas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // TABELAS 1.b e 1.c LADO A LADO
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildPlanoGuiaTable()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildAreaRetentivaTable()),
                        ],
                      )
                    else ...[
                      _buildPlanoGuiaTable(),
                      const SizedBox(height: 16),
                      _buildAreaRetentivaTable(),
                    ],

                    const SizedBox(height: 24),

                    // SEÇÕES 2 e 3
                    const Text(
                      '2. Fixar trajetória de inserção e traçar equador protético',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '3. Mapear adequações e preparos de nicho',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // TABELA TIPO DE PREPARO / DENTES (FACE)
                    _buildPreparosTable(),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _saveForm,
                        style: FilledButton.styleFrom(
                          backgroundColor: _headerGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'SALVAR FICHA DE PPR',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // TABELA: RETENTORES DIRETOS
  // ==========================================

  Widget _buildRetentoresDiretosTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderGreen, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGreenHeaderBar('RETENTORES DIRETOS'),
          Table(
            border: const TableBorder(
              horizontalInside: BorderSide(color: _borderGreen, width: 1),
              verticalInside: BorderSide(color: _borderGreen, width: 1),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1.1),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(6.2),
            },
            children: [
              const TableRow(
                children: [
                  _TableHeaderCell('Dente'),
                  _TableHeaderCell('Apoio'),
                  _TableHeaderCell('Grampos Retenção e Oposição'),
                ],
              ),
              for (int i = 0; i < _model.retentoresDiretos.length; i++)
                TableRow(
                  children: [
                    _buildEditableCell(
                      controllerKey: 'rd_dente_$i',
                      initialValue: _model.retentoresDiretos[i].dente,
                      textAlign: TextAlign.center,
                      onChanged: (v) => _model.retentoresDiretos[i].dente = v,
                    ),
                    _buildEditableCell(
                      controllerKey: 'rd_apoio_$i',
                      initialValue: _model.retentoresDiretos[i].apoio,
                      textAlign: TextAlign.center,
                      onChanged: (v) => _model.retentoresDiretos[i].apoio = v,
                    ),
                    _buildEditableCell(
                      controllerKey: 'rd_grampos_$i',
                      initialValue: _model.retentoresDiretos[i].grampos,
                      onChanged: (v) => _model.retentoresDiretos[i].grampos = v,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TABELA: RETENTORES INDIRETOS
  // ==========================================

  Widget _buildRetentoresIndiretosTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderGreen, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGreenHeaderBar('RETENTORES INDIRETOS'),
          Table(
            border: const TableBorder(
              horizontalInside: BorderSide(color: _borderGreen, width: 1),
              verticalInside: BorderSide(color: _borderGreen, width: 1),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1.1),
              1: FlexColumnWidth(7.4),
            },
            children: [
              const TableRow(
                children: [
                  _TableHeaderCell('Dente'),
                  _TableHeaderCell('Tipo'),
                ],
              ),
              for (int i = 0; i < _model.retentoresIndiretos.length; i++)
                TableRow(
                  children: [
                    _buildEditableCell(
                      controllerKey: 'ri_dente_$i',
                      initialValue: _model.retentoresIndiretos[i].dente,
                      textAlign: TextAlign.center,
                      onChanged: (v) => _model.retentoresIndiretos[i].dente = v,
                    ),
                    _buildEditableCell(
                      controllerKey: 'ri_tipo_$i',
                      initialValue: _model.retentoresIndiretos[i].tipo,
                      onChanged: (v) => _model.retentoresIndiretos[i].tipo = v,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // COLUNA DIREITA: ARCADA + MAXILA/MANDÍBULA + KENNEDY
  // ==========================================

  Widget _buildArchAndClassificationColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Diagrama interativo da arcada dentária para delineamento/planejamento
        _PprArchDrawingWidget(
          strokes: _model.desenhoArcada,
          activeColor: _activePenColor,
          onColorChanged: (color) => setState(() => _activePenColor = color),
          onStrokeAdded: (stroke) =>
              setState(() => _model.desenhoArcada.add(stroke)),
          onUndo: () {
            if (_model.desenhoArcada.isNotEmpty) {
              setState(() => _model.desenhoArcada.removeLast());
            }
          },
          onClear: () => setState(() => _model.desenhoArcada.clear()),
        ),
        const SizedBox(height: 6),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Fonte: ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              TextSpan(
                text: 'Elaborado pelos autores (2025)',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),

        // ( ) MAXILA   ( ) MANDÍBULA
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: _borderGreen, width: 1.5),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              _buildArchOption(
                label: 'MAXILA',
                checked: _model.maxila,
                onTap: () => setState(() => _model.maxila = !_model.maxila),
              ),
              _buildArchOption(
                label: 'MANDÍBULA',
                checked: _model.mandibula,
                onTap: () =>
                    setState(() => _model.mandibula = !_model.mandibula),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Classificação de Kennedy
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            border: Border.all(color: _borderGreen, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Classificação de Kennedy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _controllerFor(
                  'classificacao_kennedy',
                  _model.classificacaoKennedy,
                ),
                minLines: 2,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                ),
                onChanged: (v) => _model.classificacaoKennedy = v,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArchOption({
    required String label,
    required bool checked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              checked ? '( X )' : '(   )',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: checked ? _headerGreen : Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TABELA 1.b: PLANO-GUIA (PONTA ANALISADORA)
  // ==========================================

  Widget _buildPlanoGuiaTable() {
    return _buildTrajetoriaSectionTable(
      title: '1.b Plano-Guia (Ponta Analisadora)',
      legendLines: const [
        '(A) Plano-guia (PG)',
        '(B) Há uma interferência (I) ao assentamento',
        '(C) Face expulsiva (E) em relação ao eixo vertical',
      ],
      prefix: 'pg',
      rows: _model.planoGuia,
    );
  }

  // ==========================================
  // TABELA 1.c: ÁREA RETENTIVA (PONTA CALIBRADORA)
  // ==========================================

  Widget _buildAreaRetentivaTable() {
    return _buildTrajetoriaSectionTable(
      title: '1.c Área Retentiva (Ponta Calibradora)',
      legendLines: const [
        '(A) Haste e disco tocam (OK)',
        '(B) Só disco toca (falta retenção)',
        '(C) Só haste toca (excesso de retenção)',
      ],
      prefix: 'ar',
      rows: _model.areaRetentiva,
    );
  }

  Widget _buildTrajetoriaSectionTable({
    required String title,
    required List<String> legendLines,
    required String prefix,
    required List<TrajetoriaRow> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderGreen, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGreenHeaderBar(title),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _borderGreen, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: legendLines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.5),
                      child: Text(
                        line,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.25,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Table(
            border: const TableBorder(
              horizontalInside: BorderSide(color: _borderGreen, width: 1),
              verticalInside: BorderSide(color: _borderGreen, width: 1),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1.1),
              1: FlexColumnWidth(1.1),
              2: FlexColumnWidth(1.6),
              3: FlexColumnWidth(1.6),
              4: FlexColumnWidth(1.6),
            },
            children: [
              const TableRow(
                children: [
                  _TableHeaderCell('Dente'),
                  _TableHeaderCell('Local'),
                  _TableHeaderCell('Trajetória 1'),
                  _TableHeaderCell('Trajetória 2'),
                  _TableHeaderCell('Trajetória 3'),
                ],
              ),
              for (int i = 0; i < rows.length; i++)
                TableRow(
                  children: [
                    _buildEditableCell(
                      controllerKey: '${prefix}_dente_$i',
                      initialValue: rows[i].dente,
                      textAlign: TextAlign.center,
                      onChanged: (v) => rows[i].dente = v,
                    ),
                    _buildEditableCell(
                      controllerKey: '${prefix}_local_$i',
                      initialValue: rows[i].local,
                      textAlign: TextAlign.center,
                      onChanged: (v) => rows[i].local = v,
                    ),
                    _buildEditableCell(
                      controllerKey: '${prefix}_t1_$i',
                      initialValue: rows[i].trajetoria1,
                      textAlign: TextAlign.center,
                      onChanged: (v) => rows[i].trajetoria1 = v,
                    ),
                    _buildEditableCell(
                      controllerKey: '${prefix}_t2_$i',
                      initialValue: rows[i].trajetoria2,
                      textAlign: TextAlign.center,
                      onChanged: (v) => rows[i].trajetoria2 = v,
                    ),
                    _buildEditableCell(
                      controllerKey: '${prefix}_t3_$i',
                      initialValue: rows[i].trajetoria3,
                      textAlign: TextAlign.center,
                      onChanged: (v) => rows[i].trajetoria3 = v,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TABELA FINAL: TIPO DE PREPARO / DENTES (FACE)
  // ==========================================

  Widget _buildPreparosTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderGreen, width: 1.5),
      ),
      child: Table(
        border: const TableBorder(
          horizontalInside: BorderSide(color: _borderGreen, width: 1),
          verticalInside: BorderSide(color: _borderGreen, width: 1),
        ),
        columnWidths: const {
          0: FlexColumnWidth(2.8),
          1: FlexColumnWidth(7.2),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          const TableRow(
            decoration: BoxDecoration(color: _headerGreen),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  'TIPO DE PREPARO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  'DENTES (FACE)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          for (int i = 0; i < FichaPprModel.tiposDePreparo.length; i++)
            TableRow(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Text(
                    FichaPprModel.tiposDePreparo[i],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _buildEditableCell(
                  controllerKey: 'preparo_$i',
                  initialValue:
                      _model.preparos[FichaPprModel.tiposDePreparo[i]] ?? '',
                  minLines: 1,
                  maxLines: 2,
                  verticalPadding: 10,
                  onChanged: (v) =>
                      _model.preparos[FichaPprModel.tiposDePreparo[i]] = v,
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ==========================================
  // COMPONENTES AUXILIARES DE TABELA
  // ==========================================

  Widget _buildGreenHeaderBar(String title) {
    return Container(
      color: _headerGreen,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildEditableCell({
    required String controllerKey,
    required String initialValue,
    required ValueChanged<String> onChanged,
    TextAlign textAlign = TextAlign.left,
    int minLines = 1,
    int maxLines = 1,
    double verticalPadding = 7,
  }) {
    return TextField(
      controller: _controllerFor(controllerKey, initialValue),
      textAlign: textAlign,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 12.5, color: Colors.black87),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 6,
          vertical: verticalPadding,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// ==========================================
// 3. DIAGRAMA INTERATIVO DA ARCADA DENTÁRIA (16 DENTES)
// ==========================================

class _PprArchDrawingWidget extends StatefulWidget {
  final List<PprStroke> strokes;
  final Color activeColor;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<PprStroke> onStrokeAdded;
  final VoidCallback onUndo;
  final VoidCallback onClear;

  const _PprArchDrawingWidget({
    required this.strokes,
    required this.activeColor,
    required this.onColorChanged,
    required this.onStrokeAdded,
    required this.onUndo,
    required this.onClear,
  });

  @override
  State<_PprArchDrawingWidget> createState() => _PprArchDrawingWidgetState();
}

class _PprArchDrawingWidgetState extends State<_PprArchDrawingWidget> {
  List<Offset> _currentPoints = [];

  static const _penColors = [
    Color(0xFFD32F2F), // Vermelho
    Color(0xFF1565C0), // Azul
    Color(0xFF111827), // Preto
    Color(0xFF1E9E76), // Verde
  ];

  Offset _normalize(Offset local, Size size) {
    return Offset(
      (local.dx / size.width).clamp(0.0, 1.0),
      (local.dy / size.height).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 225,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _currentPoints = [_normalize(details.localPosition, size)];
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _currentPoints.add(_normalize(details.localPosition, size));
                  });
                },
                onPanEnd: (_) {
                  if (_currentPoints.isNotEmpty) {
                    widget.onStrokeAdded(
                      PprStroke(
                        colorValue: widget.activeColor.value,
                        points: List<Offset>.from(_currentPoints),
                      ),
                    );
                    setState(() => _currentPoints = []);
                  }
                },
                child: CustomPaint(
                  size: size,
                  painter: _DentalArchPainter(
                    strokes: widget.strokes,
                    currentPoints: _currentPoints,
                    currentColor: widget.activeColor,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        // Barra compacta para desenhar o delineamento diretamente sobre a arcada
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            for (final color in _penColors)
              InkWell(
                onTap: () => widget.onColorChanged(color),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.activeColor == color
                          ? Colors.black
                          : Colors.grey.shade300,
                      width: widget.activeColor == color ? 2.2 : 1,
                    ),
                  ),
                ),
              ),
            IconButton(
              onPressed: widget.strokes.isEmpty ? null : widget.onUndo,
              icon: const Icon(Icons.undo, size: 16),
              tooltip: 'Desfazer traço',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            IconButton(
              onPressed: widget.strokes.isEmpty ? null : widget.onClear,
              icon: const Icon(Icons.delete_outline, size: 16),
              tooltip: 'Limpar desenho',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ],
    );
  }
}

class _DentalArchPainter extends CustomPainter {
  final List<PprStroke> strokes;
  final List<Offset> currentPoints;
  final Color currentColor;

  _DentalArchPainter({
    required this.strokes,
    required this.currentPoints,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final scale = math.min(size.width / 240, size.height / 230);

    // 8 dentes por hemiarco (do incisivo central até o 3º molar), espelhados em ferradura
    // Coordenadas em espaço normalizado relativo ao centro da arcada (cx, cy, rx, ry, ang, tipo)
    const rightHalfTeeth = <List<double>>[
      // [xOffset, yPos, width, height, angleRad, kind(0=incisor,1=canine,2=premolar,3=molar)]
      [13, 20, 22, 24, 0.14, 0], // Incisivo central
      [35, 28, 19, 22, 0.36, 0], // Incisivo lateral
      [53, 44, 22, 23, 0.65, 1], // Canino
      [66, 65, 25, 21, 1.05, 2], // 1º Pré-molar
      [75, 88, 26, 21, 1.25, 2], // 2º Pré-molar
      [80, 114, 29, 25, 1.42, 3], // 1º Molar
      [82, 143, 28, 25, 1.50, 3], // 2º Molar
      [81, 171, 26, 23, 1.54, 3], // 3º Molar
    ];

    final toothFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final toothOutline = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * scale;
    final groovePaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale
      ..strokeCap = StrokeCap.round;

    for (final side in const [-1.0, 1.0]) {
      for (final spec in rightHalfTeeth) {
        final cx = centerX + side * spec[0] * scale;
        final cy = (spec[1] + 10) * scale;
        final w = spec[2] * scale;
        final h = spec[3] * scale;
        final angle = side * spec[4];
        final kind = spec[5].toInt();

        canvas.save();
        canvas.translate(cx, cy);
        canvas.rotate(angle);

        final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
        final rrect = RRect.fromRectAndRadius(
          rect,
          Radius.circular(kind == 3 ? w * 0.34 : w * 0.42),
        );
        canvas.drawRRect(rrect, toothFill);
        canvas.drawRRect(rrect, toothOutline);

        // Sulcos oclusais / bordas incisais características de cada grupo dental
        if (kind == 0) {
          canvas.drawLine(
            Offset(-w * 0.28, -h * 0.14),
            Offset(w * 0.28, -h * 0.14),
            groovePaint,
          );
        } else if (kind == 1) {
          final path = Path()
            ..moveTo(-w * 0.24, 0)
            ..lineTo(0, -h * 0.22)
            ..lineTo(w * 0.24, 0);
          canvas.drawPath(path, groovePaint);
        } else if (kind == 2) {
          canvas.drawLine(
            Offset(-w * 0.22, 0),
            Offset(w * 0.22, 0),
            groovePaint,
          );
          canvas.drawLine(
            Offset(-w * 0.14, -h * 0.14),
            Offset(-w * 0.22, 0),
            groovePaint,
          );
          canvas.drawLine(
            Offset(w * 0.14, -h * 0.14),
            Offset(w * 0.22, 0),
            groovePaint,
          );
        } else {
          canvas.drawLine(
            Offset(-w * 0.26, 0),
            Offset(w * 0.26, 0),
            groovePaint,
          );
          canvas.drawLine(
            Offset(0, -h * 0.24),
            Offset(0, h * 0.24),
            groovePaint,
          );
        }

        canvas.restore();
      }
    }

    // Desenho livre do planejamento (traços salvos + traço atual)
    void drawStroke(List<Offset> pts, Color color) {
      if (pts.isEmpty) return;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (pts.length == 1) {
        final p = Offset(pts[0].dx * size.width, pts[0].dy * size.height);
        canvas.drawCircle(p, 1.5, paint..style = PaintingStyle.fill);
        return;
      }

      final path = Path()
        ..moveTo(pts[0].dx * size.width, pts[0].dy * size.height);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx * size.width, pts[i].dy * size.height);
      }
      canvas.drawPath(path, paint);
    }

    for (final stroke in strokes) {
      drawStroke(stroke.points, Color(stroke.colorValue));
    }
    drawStroke(currentPoints, currentColor);
  }

  @override
  bool shouldRepaint(covariant _DentalArchPainter oldDelegate) => true;
}
