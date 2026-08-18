import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../viewmodels/endodontia_viewmodel.dart';

// ==========================================
// 1. MODELS (MODELAGEM DOS DADOS)
// ==========================================

class CanalEntry {
  String canal = "";
  String pontoRef = "";
  String cad = "";
  String cpt = "";
  String x = "";
  String crd = "";
  String crt = "";
  String iai = "";
  String instPatencia = "";
  String iaf = "";

  CanalEntry();

  factory CanalEntry.fromMap(Map<String, dynamic> map) {
    final entry = CanalEntry();
    entry.canal = map['canal'] ?? "";
    entry.pontoRef = map['pontoRef'] ?? "";
    entry.cad = map['cad'] ?? "";
    entry.cpt = map['cpt'] ?? "";
    entry.x = map['x'] ?? "";
    entry.crd = map['crd'] ?? "";
    entry.crt = map['crt'] ?? "";
    entry.iai = map['iai'] ?? "";
    entry.instPatencia = map['instPatencia'] ?? "";
    entry.iaf = map['iaf'] ?? "";
    return entry;
  }

  Map<String, dynamic> toMap() => {
    'canal': canal, 'pontoRef': pontoRef, 'cad': cad, 'cpt': cpt,
    'x': x, 'crd': crd, 'crt': crt, 'iai': iai, 
    'instPatencia': instPatencia, 'iaf': iaf,
  };
}

class TratamentoExecutado {
  DateTime data = DateTime.now();
  String intervencao = "";
  String aluno = "";
  String visto = "";

  TratamentoExecutado();

  factory TratamentoExecutado.fromMap(Map<String, dynamic> map) {
    final entry = TratamentoExecutado();
    entry.data = DateTime.tryParse(map['data'] ?? "") ?? DateTime.now();
    entry.intervencao = map['intervencao'] ?? "";
    entry.aluno = map['aluno'] ?? "";
    entry.visto = map['visto'] ?? "";
    return entry;
  }

  Map<String, dynamic> toMap() => {
    'data': data.toIso8601String(),
    'intervencao': intervencao,
    'aluno': aluno,
    'visto': visto,
  };
}

class FichaEndodontiaModel {
  // Vitalidade
  String denteSuspeitoNum = "";
  String denteControleNum = "";
  String declinio = ""; 
  bool suspeitoPositivo = false;
  int suspeitoIntensidade = 0;
  bool controlePositivo = false;
  int controleIntensidade = 0;
  bool percussaoVPositiva = false;
  int percussaoVIntensidade = 0;
  bool percussaoHPositiva = false;
  int percussaoHIntensidade = 0;
  bool palpacaoPositiva = false;
  int palpacaoIntensidade = 0;
  String respTermico = ""; 
  String respPercussao = ""; 
  String respPalpacao = ""; 
  String outrosTestes = "";

  // Radiográfico
  bool camaraNormal = false;
  bool camaraCalcificada = false;
  bool camaraNodulos = false;
  bool camaraDeformacaoAssoalho = false;
  bool camaraPerfuracaoAssoalho = false;
  bool canalAmplo = false;
  bool canalAtresiado = false;
  bool canalJaManipulado = false;
  bool canalObturado = false;
  bool canalCalcificado = false;
  bool canalReabsorcaoInt = false;
  bool canalReabsorcaoExt = false;
  bool canalInstFraturado = false;
  bool canalFraturaRadicular = false;
  bool canalDegrau = false;
  bool canalDilaceracaoApical = false;
  bool canalRizogeneseIncom = false;
  bool pericementoNormal = false;
  bool pericementoAumentado = false;
  bool pericementoHipercementose = false;
  bool periapiceRarefacaoDifusa = false;
  bool periapiceRarefCircunsc = false;
  bool periapiceOsteiteCondens = false;

  // Diagnóstico
  List<String> patologiaPulpar = [];
  List<String> patologiaPeriapical = [];
  List<String> tratamentoIndicado = [];

  // Tabelas
  List<CanalEntry> canais = [CanalEntry()];
  List<TratamentoExecutado> historico = [TratamentoExecutado()];

  Map<String, dynamic> toMap() => {
    'vitalidade': {
      'denteSuspeito': denteSuspeitoNum,
      'denteControle': denteControleNum,
      'declinio': declinio,
      'suspeitoPositivo': suspeitoPositivo,
      'suspeitoIntensidade': suspeitoIntensidade,
      'controlePositivo': controlePositivo,
      'controleIntensidade': controleIntensidade,
      'percussaoVPositiva': percussaoVPositiva,
      'percussaoVIntensidade': percussaoVIntensidade,
      'percussaoHPositiva': percussaoHPositiva,
      'percussaoHIntensidade': percussaoHIntensidade,
      'palpacaoPositiva': palpacaoPositiva,
      'palpacaoIntensidade': palpacaoIntensidade,
      'respTermico': respTermico,
      'respPercussao': respPercussao,
      'respPalpacao': respPalpacao,
      'outrosTestes': outrosTestes,
    },
    'radiografico': {
      'camara': {
        'Normal': camaraNormal, 'Calcificada': camaraCalcificada, 'Nódulos': camaraNodulos,
        'Deformação Assoalho': camaraDeformacaoAssoalho, 'Perfuração Assoalho': camaraPerfuracaoAssoalho,
      },
      'canal': {
        'Amplo(s)': canalAmplo, 'Atresiado(s)': canalAtresiado, 'Já manipulado(s)': canalJaManipulado,
        'Obturado(s)': canalObturado, 'Calcificado(s)': canalCalcificado, 'Reabsorção Int.': canalReabsorcaoInt,
        'Reabsorção Ext.': canalReabsorcaoExt, 'Inst. Fraturado': canalInstFraturado, 'Fratura radicular': canalFraturaRadicular,
        'Degrau': canalDegrau, 'Dilaceração Apical': canalDilaceracaoApical, 'Rizogênese Incom.': canalRizogeneseIncom,
      },
      'pericemento': {
        'Normal': pericementoNormal, 'Aumentado': pericementoAumentado, 'Hipercementose': pericementoHipercementose,
      },
      'periapice': {
        'Rarefação Difusa': periapiceRarefacaoDifusa, 'Raref. Circunsc.': periapiceRarefCircunsc, 'Osteíte Condens.': periapiceOsteiteCondens,
      }
    },
    'diagnostico': {
      'pulpar': patologiaPulpar,
      'periapical': patologiaPeriapical,
      'indicado': tratamentoIndicado,
    },
    'canais': canais.map((e) => e.toMap()).toList(),
    'historico': historico.map((e) => e.toMap()).toList(),
  };

  void fromMap(Map<String, dynamic> map) {
    final vit = map['vitalidade'] ?? {};
    denteSuspeitoNum = vit['denteSuspeito'] ?? "";
    denteControleNum = vit['denteControle'] ?? "";
    declinio = vit['declinio'] ?? "";
    suspeitoPositivo = vit['suspeitoPositivo'] ?? false;
    suspeitoIntensidade = vit['suspeitoIntensidade'] ?? 0;
    controlePositivo = vit['controlePositivo'] ?? false;
    controleIntensidade = vit['controleIntensidade'] ?? 0;
    percussaoVPositiva = vit['percussaoVPositiva'] ?? false;
    percussaoVIntensidade = vit['percussaoVIntensidade'] ?? 0;
    percussaoHPositiva = vit['percussaoHPositiva'] ?? false;
    percussaoHIntensidade = vit['percussaoHIntensidade'] ?? 0;
    palpacaoPositiva = vit['palpacaoPositiva'] ?? false;
    palpacaoIntensidade = vit['palpacaoIntensidade'] ?? 0;
    respTermico = vit['respTermico'] ?? "";
    respPercussao = vit['respPercussao'] ?? "";
    respPalpacao = vit['respPalpacao'] ?? "";
    outrosTestes = vit['outrosTestes'] ?? "";

    final rad = map['radiografico'] ?? {};
    final cam = rad['camara'] ?? {};
    camaraNormal = cam['Normal'] ?? false;
    camaraCalcificada = cam['Calcificada'] ?? false;
    camaraNodulos = cam['Nódulos'] ?? false;
    camaraDeformacaoAssoalho = cam['Deformação Assoalho'] ?? false;
    camaraPerfuracaoAssoalho = cam['Perfuração Assoalho'] ?? false;

    final can = rad['canal'] ?? {};
    canalAmplo = can['Amplo(s)'] ?? false;
    canalAtresiado = can['Atresiado(s)'] ?? false;
    canalJaManipulado = can['Já manipulado(s)'] ?? false;
    canalObturado = can['Obturado(s)'] ?? false;
    canalCalcificado = can['Calcificado(s)'] ?? false;
    canalReabsorcaoInt = can['Reabsorção Int.'] ?? false;
    canalReabsorcaoExt = can['Reabsorção Ext.'] ?? false;
    canalInstFraturado = can['Inst. Fraturado'] ?? false;
    canalFraturaRadicular = can['Fratura radicular'] ?? false;
    canalDegrau = can['Degrau'] ?? false;
    canalDilaceracaoApical = can['Dilaceração Apical'] ?? false;
    canalRizogeneseIncom = can['Rizogênese Incom.'] ?? false;

    final peri = rad['pericemento'] ?? {};
    pericementoNormal = peri['Normal'] ?? false;
    pericementoAumentado = peri['Aumentado'] ?? false;
    pericementoHipercementose = peri['Hipercementose'] ?? false;

    final apice = rad['periapice'] ?? {};
    periapiceRarefacaoDifusa = apice['Rarefação Difusa'] ?? false;
    periapiceRarefCircunsc = apice['Raref. Circunsc.'] ?? false;
    periapiceOsteiteCondens = apice['Osteíte Condens.'] ?? false;

    final diag = map['diagnostico'] ?? {};
    patologiaPulpar = List<String>.from(diag['pulpar'] ?? []);
    patologiaPeriapical = List<String>.from(diag['periapical'] ?? []);
    tratamentoIndicado = List<String>.from(diag['indicado'] ?? []);

    if (map['canais'] != null) {
      canais = (map['canais'] as List).map((e) => CanalEntry.fromMap(e)).toList();
    }
    if (map['historico'] != null) {
      historico = (map['historico'] as List).map((e) => TratamentoExecutado.fromMap(e)).toList();
    }
  }
}

class EndodontiaScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const EndodontiaScreen({super.key, required this.patientId, required this.patientName});

  @override
  ConsumerState<EndodontiaScreen> createState() => _EndodontiaScreenState();
}

class _EndodontiaScreenState extends ConsumerState<EndodontiaScreen> {
  final _formKey = GlobalKey<FormState>();
  final FichaEndodontiaModel _model = FichaEndodontiaModel();
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final endoAsync = ref.watch(endodontiaViewModelProvider(widget.patientId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ficha de Endodontia"),
            Text(widget.patientName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          if (endoAsync.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))),
        ],
      ),
      body: endoAsync.when(
        data: (data) {
          if (!_initialized && data != null) {
            _model.fromMap(data);
            _initialized = true;
          }
          return _buildForm();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text("Erro: $err"),
            ElevatedButton(onPressed: () => ref.refresh(endodontiaViewModelProvider(widget.patientId)), child: const Text("Tentar Novamente")),
          ],
        )),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("TESTES DE VITALIDADE PULPAR E CONDIÇÃO APICAL"),
            _buildVitalidadeCard(),
            _buildSectionHeader("EXAME RADIOGRÁFICO"),
            _buildRadiograficoCard(),
            _buildSectionHeader("DIAGNÓSTICO PROVÁVEL"),
            _buildDiagnosticoCard(),
            _buildSectionHeader("TRATAMENTO INDICADO / PROGNÓSTICO"),
            _buildIndicadoCard(),
            _buildSectionHeader("TRATAMENTO ENDODÔNTICO (CANAIS)"),
            _buildCanalTable(),
            _buildSectionHeader("TRATAMENTOS EXECUTADOS"),
            _buildHistoryTable(),
            const SizedBox(height: 48),
            _buildSaveButton(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalidadeCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Teste Térmico ao Frio", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006494))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextFormField(key: ValueKey('suspeito_${_model.denteSuspeitoNum}'), initialValue: _model.denteSuspeitoNum, decoration: const InputDecoration(labelText: "Dente Suspeito", border: OutlineInputBorder()), onChanged: (v) => _model.denteSuspeitoNum = v)),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(key: ValueKey('controle_${_model.denteControleNum}'), initialValue: _model.denteControleNum, decoration: const InputDecoration(labelText: "Dente Controle", border: OutlineInputBorder()), onChanged: (v) => _model.denteControleNum = v)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Declínio: ", style: TextStyle(fontWeight: FontWeight.w500)),
                Radio(value: "Rápido", groupValue: _model.declinio, onChanged: (v) => setState(() => _model.declinio = v!)),
                const Text("Rápido"),
                const SizedBox(width: 16),
                Radio(value: "Lento", groupValue: _model.declinio, onChanged: (v) => setState(() => _model.declinio = v!)),
                const Text("Lento"),
              ],
            ),
            _buildVitalityRow(label: "Dente Suspeito:", isPositive: _model.suspeitoPositivo, intensity: _model.suspeitoIntensidade, onChangedBool: (v) => setState(() => _model.suspeitoPositivo = v!), onChangedValue: (v) => _model.suspeitoIntensidade = int.tryParse(v) ?? 0),
            _buildVitalityRow(label: "Dente Controle:", isPositive: _model.controlePositivo, intensity: _model.controleIntensidade, onChangedBool: (v) => setState(() => _model.controlePositivo = v!), onChangedValue: (v) => _model.controleIntensidade = int.tryParse(v) ?? 0),
            const Divider(height: 32),
            const Text("Percussão", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006494))),
            _buildVitalityRow(label: "Vertical:", isPositive: _model.percussaoVPositiva, intensity: _model.percussaoVIntensidade, onChangedBool: (v) => setState(() => _model.percussaoVPositiva = v!), onChangedValue: (v) => _model.percussaoVIntensidade = int.tryParse(v) ?? 0),
            _buildVitalityRow(label: "Horizontal:", isPositive: _model.percussaoHPositiva, intensity: _model.percussaoHIntensidade, onChangedBool: (v) => setState(() => _model.percussaoHPositiva = v!), onChangedValue: (v) => _model.percussaoHIntensidade = int.tryParse(v) ?? 0),
            const Divider(height: 32),
            _buildVitalityRow(label: "Palpação Ápico-Cervical:", isPositive: _model.palpacaoPositiva, intensity: _model.palpacaoIntensidade, onChangedBool: (v) => setState(() => _model.palpacaoPositiva = v!), onChangedValue: (v) => _model.palpacaoIntensidade = int.tryParse(v) ?? 0),
            const Divider(height: 32),
            const Text("Respostas em relação ao Dente Controle:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF006494))),
            _buildComparisonRow("Teste Térmico:", ["Normal", "Exacerbado", "Aliviado"], _model.respTermico, (v) => setState(() => _model.respTermico = v)),
            _buildComparisonRow("Percussão:", ["Normal", "Exacerbado"], _model.respPercussao, (v) => setState(() => _model.respPercussao = v)),
            _buildComparisonRow("Palpação:", ["Norm.", "Exacerb."], _model.respPalpacao, (v) => setState(() => _model.respPalpacao = v)),
            const SizedBox(height: 12),
            TextFormField(key: ValueKey('outros_${_model.outrosTestes}'), initialValue: _model.outrosTestes, decoration: const InputDecoration(labelText: "Outros Testes (cavidade, anestesia, térmico quente)", border: OutlineInputBorder()), onChanged: (v) => _model.outrosTestes = v),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiograficoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("CÂMARA PULPAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF006494))),
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Column(children: [
                        _buildCheckbox("Normal", _model.camaraNormal, (v) => setState(() => _model.camaraNormal = v!)),
                        _buildCheckbox("Calcificada", _model.camaraCalcificada, (v) => setState(() => _model.camaraCalcificada = v!)),
                        _buildCheckbox("Nódulos", _model.camaraNodulos, (v) => setState(() => _model.camaraNodulos = v!)),
                      ])),
                      Expanded(child: Column(children: [
                        _buildCheckbox("Deformação Assoalho", _model.camaraDeformacaoAssoalho, (v) => setState(() => _model.camaraDeformacaoAssoalho = v!)),
                        _buildCheckbox("Perfuração Assoalho", _model.camaraPerfuracaoAssoalho, (v) => setState(() => _model.camaraPerfuracaoAssoalho = v!)),
                      ])),
                    ])
                  ])),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("CANAL RADICULAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF006494))),
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Column(children: [_buildCheckbox("Amplo(s)", _model.canalAmplo, (v) => setState(() => _model.canalAmplo = v!)), _buildCheckbox("Atresiado(s)", _model.canalAtresiado, (v) => setState(() => _model.canalAtresiado = v!)), _buildCheckbox("Já manipulado(s)", _model.canalJaManipulado, (v) => setState(() => _model.canalJaManipulado = v!))])),
                      Expanded(child: Column(children: [_buildCheckbox("Obturado(s)", _model.canalObturado, (v) => setState(() => _model.canalObturado = v!)), _buildCheckbox("Calcificado(s)", _model.canalCalcificado, (v) => setState(() => _model.canalCalcificado = v!)), _buildCheckbox("Reabsorção Int.", _model.canalReabsorcaoInt, (v) => setState(() => _model.canalReabsorcaoInt = v!))])),
                      Expanded(child: Column(children: [_buildCheckbox("Reabsorção Ext.", _model.canalReabsorcaoExt, (v) => setState(() => _model.canalReabsorcaoExt = v!)), _buildCheckbox("Inst. Fraturado", _model.canalInstFraturado, (v) => setState(() => _model.canalInstFraturado = v!)), _buildCheckbox("Fratura radicular", _model.canalFraturaRadicular, (v) => setState(() => _model.canalFraturaRadicular = v!))])),
                      Expanded(child: Column(children: [_buildCheckbox("Degrau", _model.canalDegrau, (v) => setState(() => _model.canalDegrau = v!)), _buildCheckbox("Dilaceração Apical", _model.canalDilaceracaoApical, (v) => setState(() => _model.canalDilaceracaoApical = v!)), _buildCheckbox("Rizogênese Incom.", _model.canalRizogeneseIncom, (v) => setState(() => _model.canalRizogeneseIncom = v!))])),
                    ])
                  ])),
                ],
              ),
            ),
            const Divider(height: 32),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("PERICEMENTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF006494))), Wrap(children: [_buildCheckboxInline("Normal", _model.pericementoNormal, (v) => setState(() => _model.pericementoNormal = v!)), _buildCheckboxInline("Aumentado", _model.pericementoAumentado, (v) => setState(() => _model.pericementoAumentado = v!)), _buildCheckboxInline("Hipercementose", _model.pericementoHipercementose, (v) => setState(() => _model.pericementoHipercementose = v!))])])),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("PERIÁPICE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF006494))), Wrap(children: [_buildCheckboxInline("Rarefação Difusa", _model.periapiceRarefacaoDifusa, (v) => setState(() => _model.periapiceRarefacaoDifusa = v!)), _buildCheckboxInline("Raref. Circunsc.", _model.periapiceRarefCircunsc, (v) => setState(() => _model.periapiceRarefCircunsc = v!)), _buildCheckboxInline("Osteíte Condens.", _model.periapiceOsteiteCondens, (v) => setState(() => _model.periapiceOsteiteCondens = v!))])])),
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [_buildCheckboxGroup("Patologia Pulpar", ["Polpa Normal", "Pulpite Reversível", "Pulpite Irreversível", "Pulpite em Transição", "Necrose"], _model.patologiaPulpar), const Divider(height: 32), _buildCheckboxGroup("Patologia Periapical", ["Periodontite Apical Aguda", "PAA de Origem Traumática", "Periodontite Apical Crônica", "Abscesso Fênix", "Abscesso Dento-Alveolar Agudo inicial", "Abscesso Dento-Alveolar Agudo em evolução", "Abscesso Dento-Alveolar Agudo evoluído", "Abscesso Dento-Alveolar Crônico (fístula)"], _model.patologiaPeriapical)])),
    );
  }

  Widget _buildIndicadoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16), child: _buildCheckboxGroup("", ["Tratamento Conservador da Polpa", "Biopulpectomia", "Necropulpectomia", "Retratamento", "Tratamento por indicação protética"], _model.tratamentoIndicado)),
    );
  }

  Widget _buildCanalTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
        child: DataTable(
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text("Canal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("Ponto Ref.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("CAD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("CPT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("X", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("CRD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("CRT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("IAI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("Inst. Patência", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("IAF", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("")),
          ],
          rows: _model.canais.asMap().entries.map((entry) {
            int idx = entry.key;
            CanalEntry canal = entry.value;
            return DataRow(cells: [
              DataCell(_smallTextField(canal.canal, (v) => canal.canal = v, key: 'canal_$idx')),
              DataCell(_smallTextField(canal.pontoRef, (v) => canal.pontoRef = v, key: 'pref_$idx')),
              DataCell(_smallTextField(canal.cad, (v) => canal.cad = v, key: 'cad_$idx')),
              DataCell(_smallTextField(canal.cpt, (v) => canal.cpt = v, key: 'cpt_$idx')),
              DataCell(_smallTextField(canal.x, (v) => canal.x = v, key: 'x_$idx')),
              DataCell(_smallTextField(canal.crd, (v) => canal.crd = v, key: 'crd_$idx')),
              DataCell(_smallTextField(canal.crt, (v) => canal.crt = v, key: 'crt_$idx')),
              DataCell(_smallTextField(canal.iai, (v) => canal.iai = v, key: 'iai_$idx')),
              DataCell(_smallTextField(canal.instPatencia, (v) => canal.instPatencia = v, key: 'inst_$idx')),
              DataCell(_smallTextField(canal.iaf, (v) => canal.iaf = v, key: 'iaf_$idx')),
              DataCell(IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20), onPressed: () => setState(() => _model.canais.removeAt(idx)))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHistoryTable() {
    return Column(
      children: [
        ..._model.historico.asMap().entries.map((entry) {
          int idx = entry.key;
          return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Text(DateFormat('dd/MM/yy').format(entry.value.data), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            const SizedBox(width: 8),
            Expanded(flex: 4, child: _smallTextField(entry.value.intervencao, (v) => entry.value.intervencao = v, hint: "Intervenção", width: double.infinity, key: 'hist_int_$idx')),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _smallTextField(entry.value.aluno, (v) => entry.value.aluno = v, hint: "Aluno", width: double.infinity, key: 'hist_al_$idx')),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _smallTextField(entry.value.visto, (v) => entry.value.visto = v, hint: "Visto", width: double.infinity, key: 'hist_vs_$idx')),
            IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), onPressed: () => setState(() => _model.historico.removeAt(idx))),
          ]));
        }),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton.icon(onPressed: () => setState(() => _model.canais.add(CanalEntry())), icon: const Icon(Icons.add), label: const Text("Adicionar Canal")),
          const SizedBox(width: 24),
          TextButton.icon(onPressed: () => setState(() => _model.historico.add(TratamentoExecutado())), icon: const Icon(Icons.add_task), label: const Text("Novo Atendimento")),
        ]),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF006494), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            try {
              await ref.read(endodontiaViewModelProvider(widget.patientId).notifier).save(_model.toMap());
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ficha de Endodontia salva com sucesso!"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.red));
            }
          }
        },
        icon: const Icon(Icons.save),
        label: const Text("SALVAR FICHA ENDODÔNTICA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(width: double.infinity, margin: const EdgeInsets.only(top: 24, bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF2D3748), borderRadius: BorderRadius.circular(8)), child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)));
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return SizedBox(height: 35, child: CheckboxListTile(title: Text(label, style: const TextStyle(fontSize: 11)), value: value, onChanged: onChanged, controlAffinity: ListTileControlAffinity.leading, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero));
  }

  Widget _buildCheckboxInline(String label, bool value, Function(bool?) onChanged) {
    return SizedBox(width: 140, child: CheckboxListTile(title: Text(label, style: const TextStyle(fontSize: 11)), value: value, onChanged: onChanged, controlAffinity: ListTileControlAffinity.leading, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero));
  }

  Widget _buildVitalityRow({required String label, required bool isPositive, required Function(bool?) onChangedBool, required Function(String) onChangedValue, required int intensity}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Expanded(flex: 3, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
      Checkbox(value: !isPositive, onChanged: (v) => onChangedBool(false)),
      const Text("Negativo", style: TextStyle(fontSize: 12)),
      Checkbox(value: isPositive, onChanged: (v) => onChangedBool(true)),
      const Text("Positivo", style: TextStyle(fontSize: 12)),
      const SizedBox(width: 20),
      const Text("Intensid. (0-10): ", style: TextStyle(fontSize: 12)),
      SizedBox(width: 45, child: TextFormField(key: ValueKey('intensity_${label}_${intensity}_${DateTime.now().millisecondsSinceEpoch}'), initialValue: intensity.toString(), enabled: isPositive, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: const InputDecoration(isDense: true), onChanged: onChangedValue, validator: (v) => (isPositive && (int.tryParse(v ?? '') ?? -1) > 10) ? "!" : null)),
    ]));
  }

  Widget _buildComparisonRow(String label, List<String> options, String currentGroup, Function(String) onSelect) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))), ...options.map((opt) => Row(mainAxisSize: MainAxisSize.min, children: [Radio(value: opt, groupValue: currentGroup, onChanged: (v) => onSelect(v!), visualDensity: VisualDensity.compact), Text(opt, style: const TextStyle(fontSize: 12)), const SizedBox(width: 8)])).toList()]));
  }

  Widget _buildCheckboxGroup(String title, List<String> options, List<String> targetList) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (title.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF006494)))), Wrap(spacing: 8, runSpacing: 0, children: options.map((opt) => SizedBox(width: 220, child: Row(mainAxisSize: MainAxisSize.min, children: [Checkbox(value: targetList.contains(opt), onChanged: (v) { setState(() { v! ? targetList.add(opt) : targetList.remove(opt); }); }), Flexible(child: Text(opt, style: const TextStyle(fontSize: 12)))]))).toList())]);
  }

  Widget _smallTextField(String initial, Function(String) onChanged, {String? hint, double width = 80, String? key}) {
    return Container(width: width, child: TextFormField(key: ValueKey('fld_${key ?? initial}_${DateTime.now().millisecondsSinceEpoch}'), initialValue: initial, style: const TextStyle(fontSize: 12), decoration: InputDecoration(hintText: hint, isDense: true, border: const UnderlineInputBorder()), onChanged: onChanged));
  }
}
