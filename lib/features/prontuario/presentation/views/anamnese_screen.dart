import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/endodontia_viewmodel.dart'; // Reutilizando container genérico de salvamento

class AnamneseScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const AnamneseScreen({super.key, required this.patientId, required this.patientName});

  @override
  ConsumerState<AnamneseScreen> createState() => _AnamneseScreenState();
}

class _AnamneseScreenState extends ConsumerState<AnamneseScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _data = {};
  bool _initialized = false;

  void _initFields() {
    _data['paciente'] = widget.patientName;
    _data['aluno'] = "";
    _data['ultimoExameMedico'] = "";
    _data['motivoExame'] = "";
    _data['medicamentosAtuais'] = "";
    _data['posologia'] = "";
    _data['outrasInfo'] = "";
    _data['queixaPrincipal'] = "";
    
    // Condições Sistêmicas
    _data['sistemico'] = {
      'cardiacos': {'sim': false, 'qual': ""},
      'digestivos': {'sim': false, 'qual': ""},
      'figado': {'sim': false, 'qual': ""},
      'sinusite': {'sim': false},
      'pressao': {'qual': "", 'usaMeds': false},
      'neurologicos': {'sim': false, 'qual': ""},
      'coagulacao': {'sim': false, 'qual': ""},
      'diabetes': {'sim': false, 'controlada': ""},
      'gravidez': {'sim': false, 'mes': ""},
      'alergia': {'sim': false, 'qual': ""},
    };

    // História Dental
    _data['dentalPassada'] = {
      'tratamentoAnterior': {'sim': false, 'qual': "", 'tempo': ""},
      'dorPreTratamento': {'sim': false, 'comoEra': "", 'controlada': ""},
    };
    _data['dentalAtual'] = {
      'tratamentoRecente': {'sim': false, 'qual': ""},
      'dorAposTratamento': {'sim': false, 'controladaMeds': ""},
    };

    // Semiologia Subjetiva
    _data['dor'] = ""; // Presente / Ausente
    _data['estimulo'] = ""; // Provocada / Espontânea
    _data['localizacao'] = ""; // Localizada / Irradiada
    _data['frequencia'] = ""; // Contínua / Intermitente
    _data['intensidade'] = ""; // Aguda / Latente
    _data['provocadaPor'] = []; // Frio, Calor, Alimentos, etc.
    _data['duracao'] = ""; // Dias, Horas, Minutos, Segundos
  }

  @override
  Widget build(BuildContext context) {
    // Usando o provider de endodontia como um repositório genérico para fichas JSON
    final endoAsync = ref.watch(endodontiaViewModelProvider("anamnese_${widget.patientId}"));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(title: const Text("Ficha de Anamnese")),
      body: endoAsync.when(
        data: (savedData) {
          if (!_initialized) {
            _initFields();
            if (savedData != null) _data.addAll(savedData);
            _initialized = true;
          }
          return _buildForm();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erro: $err")),
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
            _buildSectionHeader("CABEÇALHO"),
            _buildInfoCard([
              _buildTextField("Paciente", initial: widget.patientName, readOnly: true),
              _buildTextField("Aluno(s)", onChanged: (v) => _data['aluno'] = v, initial: _data['aluno']),
            ]),

            _buildSectionHeader("HISTÓRIA MÉDICA (Preenchimento pelo Paciente)"),
            _buildInfoCard([
              _buildTextField("Data do último exame médico", onChanged: (v) => _data['ultimoExameMedico'] = v, initial: _data['ultimoExameMedico']),
              _buildTextField("Motivo", onChanged: (v) => _data['motivoExame'] = v, initial: _data['motivoExame']),
              _buildTextField("Uso atual de medicamentos", onChanged: (v) => _data['medicamentosAtuais'] = v, initial: _data['medicamentosAtuais']),
              _buildTextField("Posologia", onChanged: (v) => _data['posologia'] = v, initial: _data['posologia']),
              const SizedBox(height: 16),
              const Text("CONDIÇÕES SISTÊMICAS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF006494))),
              const SizedBox(height: 8),
              _buildSistemicoGrid(),
              const SizedBox(height: 16),
              _buildTextField("Outras informações importantes", maxLines: 2, onChanged: (v) => _data['outrasInfo'] = v, initial: _data['outrasInfo']),
            ]),

            _buildSectionHeader("HISTÓRIA DENTAL (Preenchimento pelo Aluno)"),
            _buildInfoCard([
              _buildTextField("Queixa principal (nas palavras do paciente)", maxLines: 3, onChanged: (v) => _data['queixaPrincipal'] = v, initial: _data['queixaPrincipal']),
              const SizedBox(height: 16),
              _buildDentalTable(),
            ]),

            _buildSectionHeader("SEMIOLOGIA SUBJETIVA (Análise da dor atual)"),
            _buildInfoCard([
              _buildPainAnalysisTable(),
              const Divider(height: 32),
              const Text("Provocada/aumentada por:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              _buildProvocadaPorOptions(),
              const Divider(height: 32),
              const Text("Quando inicia dura:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              _buildDuracaoOptions(),
            ]),

            const SizedBox(height: 48),
            _buildSaveButton(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSistemicoGrid() {
    final s = _data['sistemico'];
    return Wrap(
      spacing: 20,
      runSpacing: 16,
      children: [
        _buildSistemicoItem("1. Problemas Cardíacos", s['cardiacos']),
        _buildSistemicoItem("2. Problemas digestivos", s['digestivos']),
        _buildSistemicoItem("3. Problemas de Fígado", s['figado']),
        _buildSistemicoSimple("4. Problema de Sinusite", s['sinusite']),
        _buildPressaoItem(s['pressao']),
        _buildSistemicoItem("6. Problemas Neurológicos", s['neurologicos']),
        _buildSistemicoItem("7. Problemas Coagulação", s['coagulacao']),
        _buildDiabetesItem(s['diabetes']),
        _buildGravidezItem(s['gravidez']),
        _buildSistemicoItem("10. Alergia anestésicos/meds", s['alergia']),
      ],
    );
  }

  Widget _buildSistemicoItem(String label, Map item) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Checkbox(value: item['sim'], onChanged: (v) => setState(() => item['sim'] = v!)),
              const Text("Sim. Qual:", style: TextStyle(fontSize: 10)),
              Expanded(child: TextFormField(initialValue: item['qual'], style: const TextStyle(fontSize: 10), onChanged: (v) => item['qual'] = v)),
              Checkbox(value: !item['sim'], onChanged: (v) => setState(() => item['sim'] = !v!)),
              const Text("Não", style: TextStyle(fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSistemicoSimple(String label, Map item) {
    return SizedBox(
      width: 280,
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
          Checkbox(value: item['sim'], onChanged: (v) => setState(() => item['sim'] = v!)),
          const Text("Sim", style: TextStyle(fontSize: 10)),
          Checkbox(value: !item['sim'], onChanged: (v) => setState(() => item['sim'] = !v!)),
          const Text("Não", style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPressaoItem(Map item) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("5. Pressão arterial", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Row(
            children: [
              const Text("Qual:", style: TextStyle(fontSize: 10)),
              Expanded(child: TextFormField(initialValue: item['qual'], style: const TextStyle(fontSize: 10), onChanged: (v) => item['qual'] = v)),
              const Text("Usa meds?", style: TextStyle(fontSize: 10)),
              Checkbox(value: item['usaMeds'], onChanged: (v) => setState(() => item['usaMeds'] = v!)),
              const Text("S", style: TextStyle(fontSize: 10)),
              Checkbox(value: !item['usaMeds'], onChanged: (v) => setState(() => item['usaMeds'] = !v!)),
              const Text("N", style: TextStyle(fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDiabetesItem(Map item) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("8. Diabetes", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Checkbox(value: item['sim'], onChanged: (v) => setState(() => item['sim'] = v!)),
              const Text("Sim. Controlada?", style: TextStyle(fontSize: 10)),
              Expanded(child: TextFormField(initialValue: item['controlada'], style: const TextStyle(fontSize: 10), onChanged: (v) => item['controlada'] = v)),
              Checkbox(value: !item['sim'], onChanged: (v) => setState(() => item['sim'] = !v!)),
              const Text("Não", style: TextStyle(fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGravidezItem(Map item) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("9. Gravidez", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Checkbox(value: item['sim'], onChanged: (v) => setState(() => item['sim'] = v!)),
              const Text("Sim. Mês:", style: TextStyle(fontSize: 10)),
              Expanded(child: TextFormField(initialValue: item['mes'], style: const TextStyle(fontSize: 10), onChanged: (v) => item['mes'] = v)),
              Checkbox(value: !item['sim'], onChanged: (v) => setState(() => item['sim'] = !v!)),
              const Text("Não", style: TextStyle(fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDentalTable() {
    final p = _data['dentalPassada'];
    final a = _data['dentalAtual'];
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            Padding(padding: EdgeInsets.all(8), child: Text("PASSADA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: EdgeInsets.all(8), child: Text("ATUAL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ]
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tratamento Anterior:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  _buildSubField("Sim. Qual:", p['tratamentoAnterior'], 'qual'),
                  _buildSubField("Há quanto tempo?", p['tratamentoAnterior'], 'tempo'),
                  CheckboxListTile(dense: true, title: const Text("Não", style: TextStyle(fontSize: 10)), value: !p['tratamentoAnterior']['sim'], onChanged: (v) => setState(() => p['tratamentoAnterior']['sim'] = !v!)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tratamento Recente:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  _buildSubField("Sim. Qual:", a['tratamentoRecente'], 'qual'),
                  CheckboxListTile(dense: true, title: const Text("Não", style: TextStyle(fontSize: 10)), value: !a['tratamentoRecente']['sim'], onChanged: (v) => setState(() => a['tratamentoRecente']['sim'] = !v!)),
                ],
              ),
            ),
          ]
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Dor Pré-Tratamento Anterior:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  _buildSubField("Sim. Como era?", p['dorPreTratamento'], 'comoEra'),
                  _buildSubField("Controlada?", p['dorPreTratamento'], 'controlada'),
                  CheckboxListTile(dense: true, title: const Text("Não", style: TextStyle(fontSize: 10)), value: !p['dorPreTratamento']['sim'], onChanged: (v) => setState(() => p['dorPreTratamento']['sim'] = !v!)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Dor Após-Tratamento Atual:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  _buildSubField("Sim. Controlada com meds?", a['dorAposTratamento'], 'controladaMeds'),
                  CheckboxListTile(dense: true, title: const Text("Não", style: TextStyle(fontSize: 10)), value: !a['dorAposTratamento']['sim'], onChanged: (v) => setState(() => a['dorAposTratamento']['sim'] = !v!)),
                ],
              ),
            ),
          ]
        )
      ],
    );
  }

  Widget _buildSubField(String label, Map item, String key) {
    return Row(
      children: [
        Checkbox(value: item['sim'], onChanged: (v) => setState(() => item['sim'] = v!)),
        Text(label, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 4),
        Expanded(child: TextFormField(initialValue: item[key], style: const TextStyle(fontSize: 10), onChanged: (v) => item[key] = v, decoration: const InputDecoration(isDense: true))),
      ],
    );
  }

  Widget _buildPainAnalysisTable() {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      children: [
        _buildRadioGroup("Dor:", ["Presente", "Ausente"], _data, 'dor'),
        _buildRadioGroup("Estímulo:", ["Provocada", "Espontânea"], _data, 'estimulo'),
        _buildRadioGroup("Localização:", ["Localizada no dente", "Irradiada na face"], _data, 'localizacao'),
        _buildRadioGroup("Frequência:", ["Contínua", "Intermitente"], _data, 'frequencia'),
        _buildRadioGroup("Intensidade:", ["Aguda/Pulsátil", "Latente"], _data, 'intensidade'),
      ],
    );
  }

  Widget _buildRadioGroup(String label, List<String> opts, Map target, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ...opts.map((o) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio(value: o, groupValue: target[key], onChanged: (v) => setState(() => target[key] = v)),
            Text(o, style: const TextStyle(fontSize: 11)),
          ],
        )).toList(),
      ],
    );
  }

  Widget _buildProvocadaPorOptions() {
    final list = ["Frio", "Calor", "Alimentos", "Mastigação", "Ar", "Decúbito"];
    return Wrap(
      children: list.map((o) => SizedBox(
        width: 120,
        child: CheckboxListTile(
          dense: true, title: Text(o, style: const TextStyle(fontSize: 11)),
          value: (_data['provocadaPor'] as List).contains(o),
          onChanged: (v) => setState(() {
            v! ? _data['provocadaPor'].add(o) : _data['provocadaPor'].remove(o);
          }),
        ),
      )).toList(),
    );
  }

  Widget _buildDuracaoOptions() {
    final list = ["Dias", "Horas", "Minutos", "Segundos"];
    return Wrap(
      children: list.map((o) => SizedBox(
        width: 120,
        child: Row(
          children: [
            Radio(value: o, groupValue: _data['duracao'], onChanged: (v) => setState(() => _data['duracao'] = v)),
            Text(o, style: const TextStyle(fontSize: 11)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF006494), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () async {
          await ref.read(endodontiaViewModelProvider("anamnese_${widget.patientId}").notifier).save(_data);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Anamnese salva com sucesso!"), backgroundColor: Colors.green));
        },
        icon: const Icon(Icons.save),
        label: const Text("SALVAR FICHA DE ANAMNESE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(width: double.infinity, margin: const EdgeInsets.only(top: 24, bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF2D3748), borderRadius: BorderRadius.circular(8)), child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)));
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)));
  }

  Widget _buildTextField(String label, {int maxLines = 1, Function(String)? onChanged, String? initial, bool readOnly = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(initialValue: initial, readOnly: readOnly, maxLines: maxLines, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), onChanged: onChanged));
  }
}
