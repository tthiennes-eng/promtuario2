import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/services/prontuario_pdf_service.dart';
import '../../domain/entities/odontopediatria_data.dart';
import '../viewmodels/endodontia_viewmodel.dart';
import '../viewmodels/prontuario_summary_provider.dart';
import '../widgets/odontopediatria_form_widgets.dart';

class OdontopediatriaScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const OdontopediatriaScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  ConsumerState<OdontopediatriaScreen> createState() => _OdontopediatriaScreenState();
}

class _OdontopediatriaScreenState extends ConsumerState<OdontopediatriaScreen> {
  OdontopediatriaModel _model = OdontopediatriaModel();
  final Map<String, TextEditingController> _controllers = {};
  final ScrollController _bodyScrollController = ScrollController();

  int _selectedTopicIndex = 0;
  bool _initialized = false;
  bool _isSaving = false;

  String get _storageKey => 'odontopediatria_${widget.patientId}';

  @override
  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    _bodyScrollController.dispose();
    super.dispose();
  }

  TextEditingController _ctrl(String key) {
    return _controllers.putIfAbsent(key, () {
      final initial = _model.getString(key);
      final c = TextEditingController(text: initial);
      c.addListener(() {
        _model.setString(key, c.text);
      });
      return c;
    });
  }

  void _syncModelToControllers(Map<String, dynamic>? saved) {
    final loaded = OdontopediatriaModel.fromMap(saved);
    if (loaded.getString('t1_nome').isEmpty) {
      loaded.setString('t1_nome', widget.patientName);
    }
    if (loaded.getString('t1_termo_paciente').isEmpty) {
      loaded.setString('t1_termo_paciente', widget.patientName);
    }
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    if (loaded.getString('t1_data_atendimento').isEmpty) {
      loaded.setString('t1_data_atendimento', today);
    }
    _model = loaded;
    for (final entry in _controllers.entries) {
      final nextText = _model.getString(entry.key);
      if (entry.value.text != nextText) {
        entry.value.text = nextText;
      }
    }
  }

  void _flushControllersToModel() {
    for (final entry in _controllers.entries) {
      _model.setString(entry.key, entry.value.text);
    }
  }

  void _selectTopic(int index) {
    if (index < 0 || index >= OdontopediatriaConstants.topics.length) return;
    setState(() => _selectedTopicIndex = index);
    if (_bodyScrollController.hasClients) {
      _bodyScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      _flushControllersToModel();
      await ref.read(endodontiaViewModelProvider(_storageKey).notifier).save(_model.toMap());
      ref.invalidate(prontuarioSummaryProvider(widget.patientId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ficha de Odontopediatria salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar ficha: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _exportPdf() async {
    try {
      _flushControllersToModel();
      final file = await ProntuarioPdfService.generateOdontopediatriaPdf(
        patientName: widget.patientName,
        data: _model.toMap(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF de Odontopediatria salvo em: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _prefixForTopic(int index) => 't${index + 1}_';

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(endodontiaViewModelProvider(_storageKey));

    if (!_initialized && asyncData is AsyncData<Map<String, dynamic>?>) {
      _syncModelToControllers(asyncData.value);
      _initialized = true;
    }

    final topics = OdontopediatriaConstants.topics;
    final currentTopic = topics[_selectedTopicIndex];

    return Scaffold(
      backgroundColor: kOdontoBg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Odontopediatria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              widget.patientName,
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar Ficha de Odontopediatria (PDF)',
            onPressed: _exportPdf,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(backgroundColor: kOdontoPrimary),
              icon: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Salvar'),
            ),
          ),
        ],
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro ao carregar ficha: $err')),
        data: (_) => Column(
          children: [
            _buildTopicBar(topics),
            Expanded(
              child: SingleChildScrollView(
                controller: _bodyScrollController,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1020),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTopicBanner(currentTopic, _selectedTopicIndex, topics.length),
                        const SizedBox(height: 14),
                        _buildTopicContent(_selectedTopicIndex),
                        const SizedBox(height: 12),
                        _buildFooterNavigation(topics.length),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicBar(List<OdontopediatriaTopicSpec> topics) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < topics.length; i++) ...[
              _buildTopicPill(i, topics[i]),
              if (i < topics.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopicPill(int index, OdontopediatriaTopicSpec topic) {
    final selected = index == _selectedTopicIndex;
    final filledCount = _model.countFilledByPrefix(_prefixForTopic(index));
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _selectTopic(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kOdontoPrimary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? kOdontoPrimary
                : (filledCount > 0 ? Colors.green.shade400 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              topic.shortTitle,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF334155),
              ),
            ),
            if (filledCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withValues(alpha: 0.22) : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$filledCount',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopicBanner(OdontopediatriaTopicSpec topic, int index, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006494), Color(0xFF004E75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TÓPICO ${index + 1} DE $total',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic.fullTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  topic.subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNavigation(int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: _selectedTopicIndex > 0 ? () => _selectTopic(_selectedTopicIndex - 1) : null,
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Tópico Anterior'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Salvar Ficha'),
        ),
        OutlinedButton.icon(
          onPressed: _selectedTopicIndex < total - 1 ? () => _selectTopic(_selectedTopicIndex + 1) : null,
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: const Text('Próximo Tópico'),
        ),
      ],
    );
  }

  Widget _buildTopicContent(int index) {
    switch (index) {
      case 0:
        return _buildTopic1Identificacao();
      case 1:
        return _buildTopic2MaeResponsavel();
      case 2:
        return _buildTopic3DietaResponsavel();
      case 3:
        return _buildTopic4PrePosNatalEHigiene();
      case 4:
        return _buildTopic5HistoriaMedicaEComportamento();
      case 5:
        return _buildTopic6ConsumoAlimentar();
      case 6:
        return _buildTopic7IpvIsg();
      case 7:
        return _buildTopic8ExameClinicoRx();
      case 8:
        return _buildTopic9AnomaliasEOrto();
      case 9:
      default:
        return _buildTopic10Planejamento();
    }
  }

  // ---------------------------------------------------------------------------
  // TÓPICO 1 — IDENTIFICAÇÃO E TERMO DE AUTORIZAÇÃO (PÁGINA 1)
  // ---------------------------------------------------------------------------
  Widget _buildTopic1Identificacao() {
    return Column(
      children: [
        OdontoSectionCard(
          title: 'UNIVERSIDADE FEDERAL DO MARANHÃO — ODONTOPEDIATRIA / CLÍNICA INTEGRADA INFANTIL',
          subtitle: 'Centro de Ciências Biológicas e da Saúde • Departamento de Odontologia II',
          icon: Icons.school_outlined,
          children: [
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Aluno', controller: _ctrl('t1_aluno')),
                OdontoTextField(label: 'Período', controller: _ctrl('t1_periodo')),
                OdontoTextField(label: 'Data de Atendimento', controller: _ctrl('t1_data_atendimento'), hint: 'dd/mm/aaaa'),
              ],
            ),
          ],
        ),
        OdontoSectionCard(
          title: 'IDENTIFICAÇÃO DO PACIENTE',
          icon: Icons.badge_outlined,
          children: [
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Nome', controller: _ctrl('t1_nome')),
                OdontoTextField(label: 'Idade', controller: _ctrl('t1_idade')),
                OdontoTextField(label: 'Data de Nascimento', controller: _ctrl('t1_data_nascimento'), hint: 'dd/mm/aaaa'),
              ],
            ),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: 'Sexo',
                  options: const ['Masculino', 'Feminino'],
                  selected: _model.getString('t1_sexo'),
                  onChanged: (v) => setState(() => _model.setString('t1_sexo', v)),
                ),
                OdontoTextField(label: 'Cor / Raça', controller: _ctrl('t1_cor')),
              ],
            ),
            OdontoSingleChoice(
              question: 'Portador de alguma necessidade / deficiência?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t1_necessidade_especial'),
              onChanged: (v) => setState(() => _model.setString('t1_necessidade_especial', v)),
            ),
            if (_model.getString('t1_necessidade_especial') == '(1) Sim')
              OdontoTextField(label: 'Qual necessidade / deficiência?', controller: _ctrl('t1_necessidade_qual')),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Endereço Residencial', controller: _ctrl('t1_endereco')),
                OdontoTextField(label: 'Cidade', controller: _ctrl('t1_cidade')),
              ],
            ),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Telefone', controller: _ctrl('t1_telefone')),
                OdontoTextField(label: 'Celular', controller: _ctrl('t1_celular')),
              ],
            ),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Pai', controller: _ctrl('t1_pai')),
                OdontoTextField(label: 'Profissão do Pai', controller: _ctrl('t1_profissao_pai')),
              ],
            ),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Mãe', controller: _ctrl('t1_mae')),
                OdontoTextField(label: 'Profissão da Mãe', controller: _ctrl('t1_profissao_mae')),
              ],
            ),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Local de Trabalho do Responsável', controller: _ctrl('t1_trabalho_resp')),
                OdontoTextField(label: 'Endereço do Trabalho', controller: _ctrl('t1_endereco_trabalho')),
                OdontoTextField(label: 'Telefone para Contato', controller: _ctrl('t1_telefone_contato')),
              ],
            ),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Contatos Médicos', controller: _ctrl('t1_contatos_medicos')),
                OdontoTextField(label: 'Acompanhante Habitual nas Consultas', controller: _ctrl('t1_acompanhante')),
              ],
            ),
            OdontoTextField(
              label: 'Motivo da Consulta',
              controller: _ctrl('t1_motivo_consulta'),
              maxLines: 2,
            ),
          ],
        ),
        OdontoSectionCard(
          title: 'AUTORIZAÇÃO E TERMO DE COMPROMISSO',
          icon: Icons.verified_user_outlined,
          children: [
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Eu (Nome do Responsável)', controller: _ctrl('t1_termo_responsavel')),
                OdontoTextField(label: 'RG Nº', controller: _ctrl('t1_termo_rg')),
                OdontoTextField(label: 'Paciente', controller: _ctrl('t1_termo_paciente')),
              ],
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                OdontopediatriaConstants.termoAutorizacaoTexto,
                style: TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xFF334155)),
              ),
            ),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(
                  label: 'Local e Data',
                  controller: _ctrl('t1_termo_local_data'),
                  hint: 'São Luís, ___ de ___ de 20__',
                ),
                OdontoTextField(
                  label: 'Assinatura (Pai, Mãe ou Responsável)',
                  controller: _ctrl('t1_termo_assinatura'),
                ),
              ],
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Responsável leu, concordou e assinou a Autorização e o Termo de Compromisso.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              value: _model.getBool('t1_termo_aceito'),
              onChanged: (v) => setState(() => _model.setBool('t1_termo_aceito', v ?? false)),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TÓPICO 2 — PARTE 1: DADOS DA MÃE OU RESPONSÁVEL (PÁGINAS 2–3)
  // ---------------------------------------------------------------------------
  Widget _buildTopic2MaeResponsavel() {
    return Column(
      children: [
        OdontoSectionCard(
          title: 'DADOS SOCIOECONÔMICOS DA MÃE OU RESPONSÁVEL',
          icon: Icons.family_restroom_outlined,
          children: [
            OdontoSingleChoice(
              question: 'Vínculo do entrevistado com a criança',
              options: const ['(1) Mãe', '(2) Responsável pela criança'],
              selected: _model.getString('t2_vinculo'),
              onChanged: (v) => setState(() => _model.setString('t2_vinculo', v)),
            ),
            if (_model.getString('t2_vinculo') == '(2) Responsável pela criança')
              OdontoTextField(label: 'Parentesco', controller: _ctrl('t2_parentesco')),
            OdontoSingleChoice(
              question: '1. Qual o grau de instrução da MÃE?',
              options: OdontopediatriaConstants.grauInstrucaoOptions,
              selected: _model.getString('t2_q1_instrucao_mae'),
              onChanged: (v) => setState(() => _model.setString('t2_q1_instrucao_mae', v)),
            ),
            OdontoSingleChoice(
              question: '2. Qual o grau de instrução do PAI?',
              options: OdontopediatriaConstants.grauInstrucaoOptions,
              selected: _model.getString('t2_q2_instrucao_pai'),
              onChanged: (v) => setState(() => _model.setString('t2_q2_instrucao_pai', v)),
            ),
            OdontoSingleChoice(
              question: '3. Ocupação da mãe: a mãe da criança trabalha fora de casa?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t2_q3_mae_trabalha_fora'),
              onChanged: (v) => setState(() => _model.setString('t2_q3_mae_trabalha_fora', v)),
            ),
            if (_model.getString('t2_q3_mae_trabalha_fora') == '(1) Sim')
              OdontoMultiChoice(
                question: 'Turnos em que a mãe trabalha fora',
                options: const ['(1.1) Manhã', '(1.2) Tarde', '(1.3) Noite'],
                selectedValues: _model.getStringList('t2_q3_turnos'),
                onToggle: (v) => setState(() => _model.toggleInList('t2_q3_turnos', v)),
              ),
            OdontoTextField(
              label: '4. Ocupação atual da pessoa com maior renda da família e valor da renda (salários mínimos)',
              controller: _ctrl('t2_q4_renda_familiar'),
              maxLines: 2,
            ),
            OdontoSingleChoice(
              question: '5. Qual a relação de trabalho do chefe da família?',
              options: OdontopediatriaConstants.relacaoTrabalhoOptions,
              selected: _model.getString('t2_q5_relacao_trabalho'),
              onChanged: (v) => setState(() => _model.setString('t2_q5_relacao_trabalho', v)),
            ),
          ],
        ),
        OdontoSectionCard(
          title: 'SAÚDE GERAL E HIGIENE BUCAL DO RESPONSÁVEL',
          icon: Icons.health_and_safety_outlined,
          children: [
            OdontoTriStateTable(
              headerLabel: '6. Você tem alguma dessas doenças já diagnosticadas?',
              items: OdontopediatriaConstants.doencasResponsavel,
              choices: const ['(1) Sim', '(2) Não', '(9) Não sabe'],
              valueFor: (key) => _model.getString('t2_q6_$key'),
              onChanged: (key, val) => setState(() => _model.setString('t2_q6_$key', val)),
            ),
            OdontoSingleChoice(
              question: '7. Você tem algum problema de saúde atualmente?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t2_q7_problema_saude'),
              onChanged: (v) => setState(() => _model.setString('t2_q7_problema_saude', v)),
            ),
            if (_model.getString('t2_q7_problema_saude') == '(1) Sim')
              OdontoTextField(label: 'Qual problema de saúde?', controller: _ctrl('t2_q7_qual')),
            OdontoSingleChoice(
              question: '8. Você já recebeu informações sobre como cuidar da sua saúde?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t2_q8_info_saude'),
              onChanged: (v) => setState(() => _model.setString('t2_q8_info_saude', v)),
            ),
            if (_model.getString('t2_q8_info_saude') == '(1) Sim')
              OdontoTextField(label: 'Quem deu a informação?', controller: _ctrl('t2_q8_quem')),
            OdontoSingleChoice(
              question: '9. Você já foi ao dentista?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t2_q9_foi_dentista'),
              onChanged: (v) => setState(() => _model.setString('t2_q9_foi_dentista', v)),
            ),
            if (_model.getString('t2_q9_foi_dentista') == '(1) Sim')
              OdontoTextField(label: 'Qual o motivo da consulta?', controller: _ctrl('t2_q9_motivo')),
            OdontoSingleChoice(
              question: '10. Como você realiza a sua higiene bucal?',
              options: OdontopediatriaConstants.higieneComoOptions,
              selected: _model.getString('t2_q10_como_higiene'),
              onChanged: (v) => setState(() => _model.setString('t2_q10_como_higiene', v)),
            ),
            if (_model.getString('t2_q10_como_higiene') == '(4) Outros')
              OdontoTextField(label: 'Outros (especifique o tipo)', controller: _ctrl('t2_q10_outros')),
            OdontoTextField(
              label: '11. Qual creme dental (pasta) você utiliza na sua higiene bucal?',
              controller: _ctrl('t2_q11_creme_dental'),
            ),
            OdontoSingleChoice(
              question: '12. Qual o NÚMERO DE VEZES que VOCÊ escova os seus dentes durante 1 dia?',
              options: OdontopediatriaConstants.escovacaoFrequenciaOptions,
              selected: _model.getString('t2_q12_vezes_escova'),
              onChanged: (v) => setState(() => _model.setString('t2_q12_vezes_escova', v)),
            ),
            OdontoMultiChoice(
              question: '13. Quais os HORÁRIOS que você escova os seus dentes durante o dia?',
              options: OdontopediatriaConstants.escovacaoHorariosOptions,
              selectedValues: _model.getStringList('t2_q13_horarios'),
              onToggle: (v) => setState(() => _model.toggleInList('t2_q13_horarios', v)),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TÓPICO 3 — PARTE 2: DADOS DA DIETA DA MÃE/RESPONSÁVEL (PÁGINA 3)
  // ---------------------------------------------------------------------------
  Widget _buildTopic3DietaResponsavel() {
    return OdontoSectionCard(
      title: 'PARTE 2 — DADOS DA DIETA DA MÃE / RESPONSÁVEL',
      icon: Icons.local_cafe_outlined,
      children: [
        OdontoSingleChoice(
          question: '1. Você bebe líquidos com açúcar (sucos, refrigerantes, leites, achocolatados)?',
          options: const ['(1) Sim', '(2) Não'],
          selected: _model.getString('t3_q1_liquidos_acucar'),
          onChanged: (v) => setState(() => _model.setString('t3_q1_liquidos_acucar', v)),
        ),
        OdontoSingleChoice(
          question: '2. Você toma refrigerantes?',
          options: const ['(1) Sim', '(2) Não'],
          selected: _model.getString('t3_q2_refrigerantes'),
          onChanged: (v) => setState(() => _model.setString('t3_q2_refrigerantes', v)),
        ),
        if (_model.getString('t3_q2_refrigerantes') == '(1) Sim') ...[
          OdontoTextField(label: 'Quais tipos de refrigerantes?', controller: _ctrl('t3_q2_tipos')),
          OdontoSingleChoice(
            question: 'Frequência de consumo de refrigerantes',
            options: OdontopediatriaConstants.dietaFrequenciaOptions,
            selected: _model.getString('t3_q2_frequencia'),
            onChanged: (v) => setState(() => _model.setString('t3_q2_frequencia', v)),
          ),
        ],
        OdontoSingleChoice(
          question: '3. Qual o tipo de vasilha você costuma tomar refrigerante?',
          options: OdontopediatriaConstants.vasilhaRefrigeranteOptions,
          selected: _model.getString('t3_q3_vasilha'),
          onChanged: (v) => setState(() => _model.setString('t3_q3_vasilha', v)),
        ),
        OdontoSingleChoice(
          question: '5. Você consome biscoitos doces, biscoitos recheados, bolos, bombons, chicletes?',
          options: const ['(1) Sim', '(2) Não', '(9) Não consome'],
          selected: _model.getString('t3_q5_doces'),
          onChanged: (v) => setState(() => _model.setString('t3_q5_doces', v)),
        ),
        if (_model.getString('t3_q5_doces') == '(1) Sim')
          OdontoSingleChoice(
            question: 'Frequência de consumo de doces/biscoitos',
            options: OdontopediatriaConstants.dietaFrequenciaOptions,
            selected: _model.getString('t3_q5_frequencia'),
            onChanged: (v) => setState(() => _model.setString('t3_q5_frequencia', v)),
          ),
        OdontoSingleChoice(
          question: '6. Você consome salgadinhos de pacote (pipoca, ruffles, cheetos)?',
          options: const ['(1) Sim', '(2) Não', '(9) Não consome'],
          selected: _model.getString('t3_q6_salgadinhos'),
          onChanged: (v) => setState(() => _model.setString('t3_q6_salgadinhos', v)),
        ),
        if (_model.getString('t3_q6_salgadinhos') == '(1) Sim')
          OdontoSingleChoice(
            question: 'Frequência de consumo de salgadinhos de pacote',
            options: OdontopediatriaConstants.dietaFrequenciaOptions,
            selected: _model.getString('t3_q6_frequencia'),
            onChanged: (v) => setState(() => _model.setString('t3_q6_frequencia', v)),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TÓPICO 4 — PARTE 3: PERÍODO PRÉ/PÓS-NATAL E HIGIENE BUCAL DA CRIANÇA (PÁGS 4–6)
  // ---------------------------------------------------------------------------
  Widget _buildTopic4PrePosNatalEHigiene() {
    return Column(
      children: [
        OdontoSectionCard(
          title: 'PARTE 3 — PERÍODO PRÉ E PÓS-NATAL (PRIMEIROS ANOS DE VIDA DA CRIANÇA)',
          icon: Icons.child_friendly_outlined,
          children: [
            OdontoSingleChoice(
              question: '1. Como foi sua gestação?',
              options: const ['(1) Normal', '(2) Problemática / Complicações'],
              selected: _model.getString('t4_pn_q1_gestacao'),
              onChanged: (v) => setState(() => _model.setString('t4_pn_q1_gestacao', v)),
            ),
            if (_model.getString('t4_pn_q1_gestacao') == '(2) Problemática / Complicações')
              OdontoTextField(label: 'Especifique as complicações da gestação', controller: _ctrl('t4_pn_q1_detalhe')),
            OdontoSingleChoice(
              question: '2. Tipo de Parto',
              options: const ['(1) Normal', '(2) Cesária', '(3) Fórceps'],
              selected: _model.getString('t4_pn_q2_parto'),
              onChanged: (v) => setState(() => _model.setString('t4_pn_q2_parto', v)),
            ),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: '3. A criança nasceu prematura?',
                  options: const ['(1) Sim', '(2) Não'],
                  selected: _model.getString('t4_pn_q3_prematura'),
                  onChanged: (v) => setState(() => _model.setString('t4_pn_q3_prematura', v)),
                ),
                OdontoTextField(
                  label: '4. Nasceu de quantos meses de gestação?',
                  controller: _ctrl('t4_pn_q4_meses_gestacao'),
                ),
                OdontoSingleChoice(
                  question: '5. Parto de gêmeos?',
                  options: const ['(1) Sim', '(2) Não'],
                  selected: _model.getString('t4_pn_q5_gemeos'),
                  onChanged: (v) => setState(() => _model.setString('t4_pn_q5_gemeos', v)),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.amber.shade900),
                      const SizedBox(width: 6),
                      Text(
                        'IMPORTANTE — Consulte a carteira de saúde',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OdontoResponsiveRow(
                    children: [
                      OdontoTextField(label: '6. Peso ao nascer (kg)', controller: _ctrl('t4_pn_q6_peso_nascer')),
                      OdontoTextField(label: '7. Comprimento ao nascer (cm)', controller: _ctrl('t4_pn_q7_comp_nascer')),
                    ],
                  ),
                  OdontoResponsiveRow(
                    children: [
                      OdontoTextField(label: '8. Peso com 1 ANO (kg)', controller: _ctrl('t4_pn_q8_peso_1ano')),
                      OdontoTextField(label: '9. Comprimento com 1 ANO (cm)', controller: _ctrl('t4_pn_q9_comp_1ano')),
                    ],
                  ),
                ],
              ),
            ),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(
                  label: '10. Alimentou-se SOMENTE de leite materno até (meses / anos)',
                  controller: _ctrl('t4_pn_q10_amamentacao_exclusiva_ate'),
                ),
                OdontoSingleChoice(
                  question: '11. Está sendo amamentado exclusivamente no peito no momento?',
                  options: const ['(1) Sim', '(2) Não'],
                  selected: _model.getString('t4_pn_q11_exclusivo_agora'),
                  onChanged: (v) => setState(() => _model.setString('t4_pn_q11_exclusivo_agora', v)),
                ),
              ],
            ),
            OdontoTextField(
              label: '12. Por quanto tempo amamentou no peito (tempo total — meses / anos)?',
              controller: _ctrl('t4_pn_q12_tempo_total_peito'),
              hint: 'Tempo total de amamentação no peito, mesmo associada a outros alimentos',
            ),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: '13. Costuma acordar durante a noite para mamar no peito?',
                  options: const ['(1) Sim', '(2) Não'],
                  selected: _model.getString('t4_pn_q13_acorda_noite'),
                  onChanged: (v) => setState(() => _model.setString('t4_pn_q13_acorda_noite', v)),
                ),
                OdontoSingleChoice(
                  question: '14. Costuma dormir mamando no peito?',
                  options: const ['(1) Sim', '(2) Não'],
                  selected: _model.getString('t4_pn_q14_dorme_mamando'),
                  onChanged: (v) => setState(() => _model.setString('t4_pn_q14_dorme_mamando', v)),
                ),
              ],
            ),
            OdontoTextField(
              label: '15. Quando a criança começou a comer/beber OUTROS alimentos além do leite materno? (meses / anos)',
              controller: _ctrl('t4_pn_q15_outros_alimentos_idade'),
            ),
            OdontoMultiChoice(
              question: '16. Quais foram estes alimentos?',
              options: OdontopediatriaConstants.outrosAlimentosIntroducaoOptions,
              selectedValues: _model.getStringList('t4_pn_q16_quais_alimentos'),
              onToggle: (v) => setState(() => _model.toggleInList('t4_pn_q16_quais_alimentos', v)),
            ),
          ],
        ),
        OdontoSectionCard(
          title: 'A. HÁBITOS DE HIGIENE BUCAL E HISTÓRICO ODONTOLÓGICO DA CRIANÇA',
          icon: Icons.clean_hands_outlined,
          children: [
            OdontoSingleChoice(
              question: '1. Quando começou a fazer a limpeza da boca da criança?',
              options: OdontopediatriaConstants.inicioLimpezaBocaOptions,
              selected: _model.getString('t4_hb_q1_inicio_limpeza'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q1_inicio_limpeza', v)),
            ),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(
                  label: '2. Quando nasceram os primeiros DENTES da criança? (meses)',
                  controller: _ctrl('t4_hb_q2_primeiros_dentes'),
                ),
                OdontoSingleChoice(
                  question: '3. A criança já realiza higiene da boca sozinha?',
                  options: const ['(1) Sim', '(2) Não'],
                  selected: _model.getString('t4_hb_q3_sozinha'),
                  onChanged: (v) => setState(() => _model.setString('t4_hb_q3_sozinha', v)),
                ),
              ],
            ),
            OdontoMultiChoice(
              question: '4. Atualmente, QUEM realiza a higiene da boca da criança?',
              options: OdontopediatriaConstants.quemRealizaHigieneOptions,
              selectedValues: _model.getStringList('t4_hb_q4_quem'),
              onToggle: (v) => setState(() => _model.toggleInList('t4_hb_q4_quem', v)),
            ),
            if (_model.getStringList('t4_hb_q4_quem').contains('(8) Outros'))
              OdontoTextField(label: 'Outros (quem realiza)', controller: _ctrl('t4_hb_q4_outros')),
            OdontoSingleChoice(
              question: '5. Atualmente, COMO realiza a higiene da boca?',
              options: OdontopediatriaConstants.higieneComoOptions,
              selected: _model.getString('t4_hb_q5_como'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q5_como', v)),
            ),
            if (_model.getString('t4_hb_q5_como') == '(4) Outros')
              OdontoTextField(label: 'Outros (como realiza)', controller: _ctrl('t4_hb_q5_outros')),
            OdontoSingleChoice(
              question: '6. QUAL creme dental (pasta) é utilizado na higiene da boca do seu filho?',
              options: const ['(1) Infantil', '(2) O mesmo que todos os adultos da casa'],
              selected: _model.getString('t4_hb_q6_tipo_pasta'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q6_tipo_pasta', v)),
            ),
            OdontoTextField(label: 'Qual marca / nome do creme dental?', controller: _ctrl('t4_hb_q6_qual_pasta')),
            OdontoSingleChoice(
              question: '7. O creme dental (pasta) tem FLÚOR?',
              options: const ['(1) Sim', '(2) Não', '(9) Não sabe / Não lembra'],
              selected: _model.getString('t4_hb_q7_tem_fluor'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q7_tem_fluor', v)),
            ),
            OdontoSingleChoice(
              question: '8. Qual o NÚMERO DE VEZES que a criança escova os dentes durante o dia?',
              options: OdontopediatriaConstants.escovacaoFrequenciaOptions,
              selected: _model.getString('t4_hb_q8_vezes'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q8_vezes', v)),
            ),
            OdontoMultiChoice(
              question: '9. Marque TODOS os HORÁRIOS que a criança escova os dentes durante o dia',
              options: OdontopediatriaConstants.escovacaoHorariosOptions,
              selectedValues: _model.getStringList('t4_hb_q9_horarios'),
              onToggle: (v) => setState(() => _model.toggleInList('t4_hb_q9_horarios', v)),
            ),
            const Divider(height: 24),
            OdontoSingleChoice(
              question: '10. A criança já foi ao dentista?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t4_hb_q10_foi_dentista'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q10_foi_dentista', v)),
            ),
            OdontoMultiChoice(
              question: '11. Qual o motivo da consulta ao cirurgião-dentista?',
              options: OdontopediatriaConstants.motivoConsultaCriancaOptions,
              selectedValues: _model.getStringList('t4_hb_q11_motivo'),
              onToggle: (v) => setState(() => _model.toggleInList('t4_hb_q11_motivo', v)),
            ),
            if (_model.getStringList('t4_hb_q11_motivo').contains('(9) Outro'))
              OdontoTextField(label: 'Outro motivo', controller: _ctrl('t4_hb_q11_outro')),
            OdontoSingleChoice(
              question: '12. Em caso de dor, quando foi que doeu o dente do seu filho?',
              options: OdontopediatriaConstants.quandoDoeuOptions,
              selected: _model.getString('t4_hb_q12_quando_doeu'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q12_quando_doeu', v)),
            ),
            OdontoSingleChoice(
              question: '13. Seu filho sentia dor quando?',
              options: OdontopediatriaConstants.sentiaDorQuandoOptions,
              selected: _model.getString('t4_hb_q13_dor_quando'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q13_dor_quando', v)),
            ),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: '14. Seu filho chorou?',
                  options: const ['(1) Sim', '(2) Não', '(3) Às vezes'],
                  selected: _model.getString('t4_hb_q14_chorou'),
                  onChanged: (v) => setState(() => _model.setString('t4_hb_q14_chorou', v)),
                ),
                OdontoSingleChoice(
                  question: '15. Acordou à noite por causa da dor?',
                  options: const ['(1) Sim', '(2) Não', '(9) Não lembra / Não sabe'],
                  selected: _model.getString('t4_hb_q15_acordou_dor'),
                  onChanged: (v) => setState(() => _model.setString('t4_hb_q15_acordou_dor', v)),
                ),
              ],
            ),
            OdontoMultiChoice(
              question: '16. Se o seu filho foi ao dentista, qual procedimento realizado?',
              options: OdontopediatriaConstants.procedimentoRealizadoOptions,
              selectedValues: _model.getStringList('t4_hb_q16_procedimento'),
              onToggle: (v) => setState(() => _model.toggleInList('t4_hb_q16_procedimento', v)),
            ),
            OdontoSingleChoice(
              question: '17. Seu filho teve alguma reação alérgica ao anestésico utilizado?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t4_hb_q17_alergia_anestesico'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q17_alergia_anestesico', v)),
            ),
            OdontoSingleChoice(
              question: '18. A criança já tomou ANTIBIÓTICO? (ex.: Amoxicilina, Penicilina, Eritromicina, Clavulin)',
              options: const ['(1) Sim', '(2) Não', '(9) Não sabe / Não lembra'],
              selected: _model.getString('t4_hb_q18_antibiotico'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q18_antibiotico', v)),
            ),
            OdontoTextField(label: 'Obs. Antibiótico', controller: _ctrl('t4_hb_q18_obs')),
            OdontoSingleChoice(
              question: '19. A criança recebeu orientação de higiene bucal?',
              options: const ['(1) Sim', '(2) Não', '(9) Não sabe / Não lembra'],
              selected: _model.getString('t4_hb_q19_orientacao'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q19_orientacao', v)),
            ),
            OdontoTextField(label: 'Obs. Orientação de higiene bucal', controller: _ctrl('t4_hb_q19_obs')),
            OdontoSingleChoice(
              question: '20. A criança já fez uso do Flúor (ATF / Bochecho / Uso profissional)?',
              options: const ['(1) Sim', '(2) Não', '(9) Não sabe / Não lembra'],
              selected: _model.getString('t4_hb_q20_uso_fluor'),
              onChanged: (v) => setState(() => _model.setString('t4_hb_q20_uso_fluor', v)),
            ),
            OdontoTextField(label: 'Obs. Uso de Flúor', controller: _ctrl('t4_hb_q20_obs')),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TÓPICO 5 — HISTÓRIA MÉDICA, COMPORTAMENTO PSICOLÓGICO E HÁBITOS (PÁGS 6–7)
  // ---------------------------------------------------------------------------
  Widget _buildTopic5HistoriaMedicaEComportamento() {
    return Column(
      children: [
        OdontoSectionCard(
          title: 'HISTÓRIA MÉDICA ANTERIOR',
          icon: Icons.medical_information_outlined,
          children: [
            OdontoSingleChoice(
              question: 'Já foi submetido a algum tratamento cirúrgico?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hma_cirurgia'),
              onChanged: (v) => setState(() => _model.setString('t5_hma_cirurgia', v)),
            ),
            if (_model.getString('t5_hma_cirurgia') == '(1) Sim')
              OdontoTextField(label: 'Qual tratamento cirúrgico?', controller: _ctrl('t5_hma_cirurgia_qual')),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Estado de saúde atual', controller: _ctrl('t5_hma_estado_saude')),
                OdontoTextField(label: 'Data do último exame médico', controller: _ctrl('t5_hma_ultimo_exame'), hint: 'dd/mm/aaaa'),
              ],
            ),
            OdontoSingleChoice(
              question: 'Já esteve hospitalizado?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hma_hospitalizado'),
              onChanged: (v) => setState(() => _model.setString('t5_hma_hospitalizado', v)),
            ),
            if (_model.getString('t5_hma_hospitalizado') == '(1) Sim')
              OdontoTextField(label: 'Motivo da hospitalização', controller: _ctrl('t5_hma_hospitalizado_motivo')),
            OdontoSingleChoice(
              question: 'Tem alergia?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hma_alergia'),
              onChanged: (v) => setState(() => _model.setString('t5_hma_alergia', v)),
            ),
            if (_model.getString('t5_hma_alergia') == '(1) Sim')
              OdontoTextField(label: 'A quê?', controller: _ctrl('t5_hma_alergia_qual')),
            OdontoSingleChoice(
              question: 'A vacinação está em dia?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hma_vacinacao'),
              onChanged: (v) => setState(() => _model.setString('t5_hma_vacinacao', v)),
            ),
            OdontoTextField(label: 'Quais vacinas / observações?', controller: _ctrl('t5_hma_vacinacao_quais')),
            OdontoSingleChoice(
              question: 'Está em tratamento médico?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hma_tratamento_medico'),
              onChanged: (v) => setState(() => _model.setString('t5_hma_tratamento_medico', v)),
            ),
            if (_model.getString('t5_hma_tratamento_medico') == '(1) Sim')
              OdontoTextField(label: 'Especifique o tratamento médico', controller: _ctrl('t5_hma_tratamento_detalhe')),
            OdontoSingleChoice(
              question: 'Está tomando algum medicamento?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hma_medicamento_atual'),
              onChanged: (v) => setState(() => _model.setString('t5_hma_medicamento_atual', v)),
            ),
            if (_model.getString('t5_hma_medicamento_atual') == '(1) Sim')
              OdontoTextField(label: 'Qual medicamento?', controller: _ctrl('t5_hma_medicamento_qual')),
            OdontoTextField(
              label: 'Medicamentos utilizados no passado',
              controller: _ctrl('t5_hma_medicamentos_passado'),
            ),
            OdontoMultiChoice(
              question: 'Doenças de infância',
              options: OdontopediatriaConstants.doencasInfanciaOptions,
              selectedValues: _model.getStringList('t5_hma_doencas_infancia'),
              onToggle: (v) => setState(() => _model.toggleInList('t5_hma_doencas_infancia', v)),
            ),
            OdontoTextField(
              label: 'Especifique os problemas',
              controller: _ctrl('t5_hma_doencas_especifique'),
              maxLines: 2,
            ),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Tipo Sanguíneo', controller: _ctrl('t5_hma_tipo_sanguineo')),
                OdontoTextField(label: 'Obs.', controller: _ctrl('t5_hma_obs')),
              ],
            ),
          ],
        ),
        OdontoSectionCard(
          title: 'HISTÓRIA MÉDICA ATUAL',
          icon: Icons.monitor_heart_outlined,
          children: [
            OdontoTextField(label: 'Estado Geral de saúde', controller: _ctrl('t5_hmat_estado_geral')),
            OdontoSingleChoice(
              question: 'Respiração',
              options: const ['(1) Nasal', '(2) Bucal', '(3) Mista'],
              selected: _model.getString('t5_hmat_respiracao'),
              onChanged: (v) => setState(() => _model.setString('t5_hmat_respiracao', v)),
            ),
            OdontoSingleChoice(
              question: 'Alteração na Visão / Fonação / Andar / Na pele?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hmat_alteracao'),
              onChanged: (v) => setState(() => _model.setString('t5_hmat_alteracao', v)),
            ),
            if (_model.getString('t5_hmat_alteracao') == '(1) Sim')
              OdontoTextField(label: 'Especifique a alteração', controller: _ctrl('t5_hmat_alteracao_detalhe')),
            OdontoTextField(label: 'Obs.', controller: _ctrl('t5_hmat_obs1')),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Uso de Medicamentos', controller: _ctrl('t5_hmat_uso_meds')),
                OdontoTextField(label: 'Tipo de Alergia', controller: _ctrl('t5_hmat_tipo_alergia')),
              ],
            ),
            OdontoTextField(label: 'Observações adicionais', controller: _ctrl('t5_hmat_obs2')),
          ],
        ),
        OdontoSectionCard(
          title: 'COMPORTAMENTO PSICOLÓGICO',
          icon: Icons.psychology_outlined,
          children: [
            OdontoSingleChoice(
              question: 'Adaptação Escolar',
              options: const [
                '(1) Normal',
                '(2) Agitado',
                '(3) Hiperativo',
                '(4) Apático',
                '(5) Déficit de atenção',
                '(6) Outro problema comportamental',
              ],
              selected: _model.getString('t5_psico_escolar'),
              onChanged: (v) => setState(() => _model.setString('t5_psico_escolar', v)),
            ),
            if (_model.getString('t5_psico_escolar') == '(6) Outro problema comportamental')
              OdontoTextField(label: 'Qual problema comportamental?', controller: _ctrl('t5_psico_escolar_outro')),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: 'Adaptação Familiar',
                  options: const ['(1) Normal', '(2) Agitado', '(3) Agressivo'],
                  selected: _model.getString('t5_psico_familiar'),
                  onChanged: (v) => setState(() => _model.setString('t5_psico_familiar', v)),
                ),
                OdontoSingleChoice(
                  question: 'Sono',
                  options: const ['(1) Tranquilo', '(2) Agitado', '(3) Acorda várias vezes à noite'],
                  selected: _model.getString('t5_psico_sono'),
                  onChanged: (v) => setState(() => _model.setString('t5_psico_sono', v)),
                ),
              ],
            ),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: 'Qual o período escolar que frequenta?',
                  options: const ['(1) Manhã', '(2) Tarde', '(3) Integral'],
                  selected: _model.getString('t5_psico_periodo'),
                  onChanged: (v) => setState(() => _model.setString('t5_psico_periodo', v)),
                ),
                OdontoSingleChoice(
                  question: 'Tem dificuldades na escola?',
                  options: const ['(1) Sim', '(2) Não'],
                  selected: _model.getString('t5_psico_dificuldade'),
                  onChanged: (v) => setState(() => _model.setString('t5_psico_dificuldade', v)),
                ),
              ],
            ),
            if (_model.getString('t5_psico_dificuldade') == '(1) Sim')
              OdontoTextField(label: 'Quais dificuldades escolares?', controller: _ctrl('t5_psico_dificuldade_detalhe')),
          ],
        ),
        OdontoSectionCard(
          title: 'B. HÁBITOS DELETÉRIOS',
          icon: Icons.warning_amber_outlined,
          children: [
            OdontoSingleChoice(
              question: 'A criança tem/teve hábito de sucção de chupeta?',
              options: const ['(2) Não', '(1) Sim'],
              selected: _model.getString('t5_hd_chupeta'),
              onChanged: (v) => setState(() => _model.setString('t5_hd_chupeta', v)),
            ),
            if (_model.getString('t5_hd_chupeta') == '(1) Sim') ...[
              OdontoMultiChoice(
                question: 'Período da sucção de chupeta',
                options: const ['(1.1) À noite', '(1.2) Durante o dia'],
                selectedValues: _model.getStringList('t5_hd_chupeta_periodo'),
                onToggle: (v) => setState(() => _model.toggleInList('t5_hd_chupeta_periodo', v)),
              ),
              OdontoResponsiveRow(
                children: [
                  OdontoTextField(label: 'Início do hábito (idade)', controller: _ctrl('t5_hd_chupeta_inicio')),
                  OdontoTextField(label: 'Até que idade?', controller: _ctrl('t5_hd_chupeta_fim')),
                ],
              ),
            ],
            const Divider(height: 20),
            OdontoSingleChoice(
              question: 'A criança tem/teve hábito de sucção de dedos?',
              options: const ['(2) Não', '(1) Sim'],
              selected: _model.getString('t5_hd_dedo'),
              onChanged: (v) => setState(() => _model.setString('t5_hd_dedo', v)),
            ),
            if (_model.getString('t5_hd_dedo') == '(1) Sim') ...[
              OdontoMultiChoice(
                question: 'Período da sucção de dedos',
                options: const ['(1.1) À noite', '(1.2) Durante o dia'],
                selectedValues: _model.getStringList('t5_hd_dedo_periodo'),
                onToggle: (v) => setState(() => _model.toggleInList('t5_hd_dedo_periodo', v)),
              ),
              OdontoResponsiveRow(
                children: [
                  OdontoTextField(label: 'Início do hábito (idade)', controller: _ctrl('t5_hd_dedo_inicio')),
                  OdontoTextField(label: 'Até que idade?', controller: _ctrl('t5_hd_dedo_fim')),
                ],
              ),
            ],
            const Divider(height: 20),
            OdontoSingleChoice(
              question: 'A criança tem outros tipos de hábitos?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hd_outros'),
              onChanged: (v) => setState(() => _model.setString('t5_hd_outros', v)),
            ),
            if (_model.getString('t5_hd_outros') == '(1) Sim') ...[
              OdontoMultiChoice(
                question: 'Quais hábitos?',
                options: OdontopediatriaConstants.outrosHabitosOptions,
                selectedValues: _model.getStringList('t5_hd_outros_lista'),
                onToggle: (v) => setState(() => _model.toggleInList('t5_hd_outros_lista', v)),
              ),
              OdontoTextField(label: 'Cessou — idade', controller: _ctrl('t5_hd_outros_cessou')),
            ],
            const Divider(height: 20),
            OdontoSingleChoice(
              question: 'A criança tem o hábito de ranger ou apertar os dentes?',
              options: const ['(2) Não', '(1) Sim'],
              selected: _model.getString('t5_hd_bruxismo'),
              onChanged: (v) => setState(() => _model.setString('t5_hd_bruxismo', v)),
            ),
            if (_model.getString('t5_hd_bruxismo') == '(1) Sim') ...[
              OdontoMultiChoice(
                question: 'Características do ranger / apertar os dentes',
                options: OdontopediatriaConstants.bruxismoDetalhesOptions,
                selectedValues: _model.getStringList('t5_hd_bruxismo_detalhes'),
                onToggle: (v) => setState(() => _model.toggleInList('t5_hd_bruxismo_detalhes', v)),
              ),
              OdontoTextField(label: 'Outros hábitos (especifique)', controller: _ctrl('t5_hd_bruxismo_outros')),
            ],
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TÓPICO 6 — MARCADORES DE CONSUMO ALIMENTAR (PÁGINA 8)
  // ---------------------------------------------------------------------------
  Widget _buildTopic6ConsumoAlimentar() {
    return Column(
      children: [
        OdontoSectionCard(
          title: 'IDENTIFICAÇÃO DO FORMULÁRIO — MARCADORES DE CONSUMO ALIMENTAR',
          icon: Icons.restaurant_outlined,
          children: [
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Data', controller: _ctrl('t6_data'), hint: 'dd/mm/aaaa'),
                DropdownButtonFormField<String>(
                  initialValue: OdontopediatriaConstants.localAtendimentoOptions.contains(_model.getString('t6_local'))
                      ? _model.getString('t6_local')
                      : null,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Local de Atendimento',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: OdontopediatriaConstants.localAtendimentoOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) => setState(() => _model.setString('t6_local', v ?? '')),
                ),
              ],
            ),
          ],
        ),
        OdontoSectionCard(
          title: 'CRIANÇAS MENORES DE 6 MESES',
          subtitle: 'Marque Sim, Não ou Não Sabe para cada item consumido ontem',
          icon: Icons.baby_changing_station_outlined,
          children: [
            OdontoTriStateTable(
              items: OdontopediatriaConstants.consumoMenores6Meses,
              choices: const ['Sim', 'Não', 'Não Sabe'],
              valueFor: (k) => _model.getString('t6_m6_$k'),
              onChanged: (k, v) => setState(() => _model.setString('t6_m6_$k', v)),
            ),
          ],
        ),
        OdontoSectionCard(
          title: 'CRIANÇAS DE 6 A 23 MESES',
          icon: Icons.child_care_outlined,
          children: [
            OdontoSingleChoice(
              question: 'A criança ontem tomou leite do peito?',
              options: const ['Sim', 'Não', 'Não Sabe'],
              selected: _model.getString('t6_6a23_peito'),
              onChanged: (v) => setState(() => _model.setString('t6_6a23_peito', v)),
            ),
            OdontoSingleChoice(
              question: 'Ontem, a criança comeu fruta inteira, em pedaço ou amassada?',
              options: const ['Sim', 'Não', 'Não Sabe'],
              selected: _model.getString('t6_6a23_fruta'),
              onChanged: (v) => setState(() => _model.setString('t6_6a23_fruta', v)),
            ),
            if (_model.getString('t6_6a23_fruta') == 'Sim')
              OdontoSingleChoice(
                question: 'Se sim, quantas vezes comeu fruta?',
                options: const ['1 vez', '2 vezes', '3 vezes ou mais', 'Não Sabe'],
                selected: _model.getString('t6_6a23_fruta_vezes'),
                onChanged: (v) => setState(() => _model.setString('t6_6a23_fruta_vezes', v)),
              ),
            OdontoSingleChoice(
              question: 'Ontem a criança comeu comida de sal (de panela, papa ou sopa)?',
              options: const ['Sim', 'Não', 'Não Sabe'],
              selected: _model.getString('t6_6a23_sal'),
              onChanged: (v) => setState(() => _model.setString('t6_6a23_sal', v)),
            ),
            if (_model.getString('t6_6a23_sal') == 'Sim') ...[
              OdontoSingleChoice(
                question: 'Se sim, quantas vezes comeu comida de sal?',
                options: const ['1 vez', '2 vezes', '3 vezes ou mais', 'Não Sabe'],
                selected: _model.getString('t6_6a23_sal_vezes'),
                onChanged: (v) => setState(() => _model.setString('t6_6a23_sal_vezes', v)),
              ),
              OdontoSingleChoice(
                question: 'Se sim, essa comida foi oferecida:',
                options: const [
                  'Em pedaços',
                  'Amassada',
                  'Passada na peneira',
                  'Liquidificada',
                  'Só o caldo',
                  'Não Sabe',
                ],
                selected: _model.getString('t6_6a23_sal_consistencia'),
                onChanged: (v) => setState(() => _model.setString('t6_6a23_sal_consistencia', v)),
              ),
            ],
            OdontoTriStateTable(
              headerLabel: 'Ontem a criança consumiu:',
              items: OdontopediatriaConstants.consumo6a23MesesItens,
              choices: const ['Sim', 'Não', 'Não Sabe'],
              valueFor: (k) => _model.getString('t6_6a23_$k'),
              onChanged: (k, v) => setState(() => _model.setString('t6_6a23_$k', v)),
            ),
          ],
        ),
        OdontoSectionCard(
          title: 'CRIANÇAS COM 2 ANOS OU MAIS, ADOLESCENTES, ADULTOS, GESTANTES E IDOSOS',
          icon: Icons.dining_outlined,
          children: [
            OdontoSingleChoice(
              question: 'Você tem costume de realizar as refeições assistindo à TV, mexendo no computador e/ou celular?',
              options: const ['Sim', 'Não', 'Não Sabe'],
              selected: _model.getString('t6_2m_telas'),
              onChanged: (v) => setState(() => _model.setString('t6_2m_telas', v)),
            ),
            OdontoMultiChoice(
              question: 'Quais refeições você faz ao longo do dia?',
              options: OdontopediatriaConstants.refeicoesDiaOptions,
              selectedValues: _model.getStringList('t6_2m_refeicoes'),
              onToggle: (v) => setState(() => _model.toggleInList('t6_2m_refeicoes', v)),
            ),
            OdontoTriStateTable(
              headerLabel: 'Ontem, você consumiu:',
              items: OdontopediatriaConstants.consumo2AnosOuMaisItens,
              choices: const ['Sim', 'Não', 'Não Sabe'],
              valueFor: (k) => _model.getString('t6_2m_$k'),
              onChanged: (k, v) => setState(() => _model.setString('t6_2m_$k', v)),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TÓPICO 7 — ÍNDICES IPV E ISG (PÁGINA 9)
  // ---------------------------------------------------------------------------
  Widget _buildTopic7IpvIsg() {
    return Column(
      children: [
        OdontoSectionCard(
          title: 'DATA DO EXAME IPV / ISG',
          icon: Icons.calendar_today_outlined,
          children: [
            OdontoTextField(label: 'Data do exame', controller: _ctrl('t7_data'), hint: 'dd/mm/aaaa'),
          ],
        ),
        OdontoBinarySurfaceGrid(
          title: 'IPV — ÍNDICE DE PLACA VISÍVEL',
          legendZero: 'ausência de placa',
          legendOne: 'presença de placa',
          surfaces: const ['V', 'P', 'M', 'D', 'O'],
          disableOcclusalOnAnterior: true,
          gridKey: 't7_ipv_grid',
          model: _model,
          onChanged: () => setState(() {}),
        ),
        OdontoBinarySurfaceGrid(
          title: 'ISG — ÍNDICE DE SANGRAMENTO GENGIVAL',
          legendZero: 'ausência de sangramento',
          legendOne: 'presença de sangramento',
          surfaces: const ['V', 'P', 'M', 'D'],
          disableOcclusalOnAnterior: false,
          gridKey: 't7_isg_grid',
          model: _model,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TÓPICO 8 — EXAME CLÍNICO E RADIOGRÁFICO (PÁGINA 10)
  // ---------------------------------------------------------------------------
  Widget _buildTopic8ExameClinicoRx() {
    return Column(
      children: [
        OdontoSectionCard(
          title: 'DATA E ORIENTAÇÃO DO EXAME CLÍNICO / RADIOGRÁFICO',
          subtitle: 'Marque a coluna "Presente" para os dentes presentes na boca no dia do exame clínico.',
          icon: Icons.biotech_outlined,
          children: [
            OdontoTextField(label: 'Data do exame', controller: _ctrl('t8_data'), hint: 'dd/mm/aaaa'),
          ],
        ),
        OdontoCodedSurfaceGrid(
          title: 'EXAME CLÍNICO E OBSERVAÇÕES CLÍNICAS',
          subtitle: 'Toque em cada face (V, P, M, D, O) para selecionar o código de 0 a 10',
          surfaces: const ['V', 'P', 'M', 'D', 'O'],
          legendCodes: OdontopediatriaConstants.exameClinicoCodigos,
          maxCode: 10,
          gridKey: 't8_clinico_grid',
          includePresentToggle: true,
          includeObservationField: true,
          model: _model,
          controllerFor: _ctrl,
          onChanged: () => setState(() {}),
        ),
        OdontoSectionCard(
          title: 'PERFIL DO PACIENTE COM RELAÇÃO À DOENÇA CÁRIE',
          icon: Icons.assessment_outlined,
          children: [
            OdontoMultiChoice(
              question: 'Selecione a classificação aplicável ao paciente',
              options: OdontopediatriaConstants.perfilCarieOptions,
              selectedValues: _model.getStringList('t8_perfil_carie'),
              onToggle: (v) => setState(() => _model.toggleInList('t8_perfil_carie', v)),
            ),
          ],
        ),
        OdontoCodedSurfaceGrid(
          title: 'EXAME RADIOGRÁFICO (CÓDIGOS DE RADIOLUCIDEZ)',
          subtitle: 'Toque em cada face (M, D, O) para selecionar o código de 0 a 7',
          surfaces: const ['M', 'D', 'O'],
          legendCodes: OdontopediatriaConstants.exameRxCodigos,
          maxCode: 7,
          gridKey: 't8_rx_grid',
          model: _model,
          controllerFor: _ctrl,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TÓPICO 9 — PARTE 4 E 5: ANOMALIAS DENTÁRIAS E AVALIAÇÃO ORTODÔNTICA (PÁGS 11–13)
  // ---------------------------------------------------------------------------
  Widget _buildTopic9AnomaliasEOrto() {
    Widget sideSelector(String label, String keyPrefix, List<String> rows, List<String> sides) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < rows.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: i.isEven ? Colors.white : const Color(0xFFFAFBFD),
                        border: i < rows.length - 1
                            ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                            : null,
                      ),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 240,
                            child: Text(rows[i], style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                          ),
                          for (final side in sides)
                            FilterChip(
                              visualDensity: VisualDensity.compact,
                              label: Text(side, style: const TextStyle(fontSize: 11.5)),
                              selected: _model.getStringList('${keyPrefix}_$i').contains(side),
                              selectedColor: kOdontoPrimary.withValues(alpha: 0.16),
                              checkmarkColor: kOdontoPrimary,
                              onSelected: (_) => setState(() => _model.toggleInList('${keyPrefix}_$i', side)),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget softTissueRow(String label, String key) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: OdontoResponsiveRow(
          children: [
            OdontoSingleChoice(
              question: label,
              options: const ['Normal', 'Alterado'],
              selected: _model.getString('t9_tm_${key}_status'),
              onChanged: (v) => setState(() => _model.setString('t9_tm_${key}_status', v)),
            ),
            OdontoTextField(label: 'Obs. ($label)', controller: _ctrl('t9_tm_${key}_obs')),
          ],
        ),
      );
    }

    return Column(
      children: [
        OdontoSectionCard(
          title: 'PARTE 4 — EXAME DOS DENTES E PERIODONTO (ANOMALIAS DENTÁRIAS)',
          icon: Icons.search_outlined,
          children: [
            const Text('Alteração de número', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: '(1) Anodontia — Dentes', controller: _ctrl('t9_anodontia')),
                OdontoTextField(label: '(2) Supranumerários — Dentes', controller: _ctrl('t9_supranumerarios')),
              ],
            ),
            const Text('Alterações Formativas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: '(1) Hipoplasia de Esmalte — Dentes', controller: _ctrl('t9_hipoplasia_esmalte')),
                OdontoTextField(label: '(2) Hipoplasia de Dentina — Dentes', controller: _ctrl('t9_hipoplasia_dentina')),
                OdontoTextField(label: '(3) Amelogênese — Dentes', controller: _ctrl('t9_amelogenese')),
              ],
            ),
            OdontoSingleChoice(
              question: '(4) Outras anomalias dentárias?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t9_outras_anomalias'),
              onChanged: (v) => setState(() => _model.setString('t9_outras_anomalias', v)),
            ),
            if (_model.getString('t9_outras_anomalias') == '(1) Sim')
              OdontoTextField(label: 'Especifique outras anomalias', controller: _ctrl('t9_outras_anomalias_detalhe')),
            OdontoSingleChoice(
              question: 'Dentes decíduos anquilosados?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t9_anquilosados'),
              onChanged: (v) => setState(() => _model.setString('t9_anquilosados', v)),
            ),
            if (_model.getString('t9_anquilosados') == '(1) Sim')
              OdontoTextField(label: 'Quais dentes anquilosados?', controller: _ctrl('t9_anquilosados_detalhe')),
            OdontoSingleChoice(
              question: 'Problemas na sequência de erupção e esfoliação dos dentes?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t9_seq_erupcao'),
              onChanged: (v) => setState(() => _model.setString('t9_seq_erupcao', v)),
            ),
            if (_model.getString('t9_seq_erupcao') == '(1) Sim')
              OdontoTextField(label: 'Descreva o problema de erupção/esfoliação', controller: _ctrl('t9_seq_erupcao_detalhe')),
            OdontoTextField(label: 'Perda Precoce dos Dentes Decíduos', controller: _ctrl('t9_perda_precoce')),
            OdontoSingleChoice(
              question: 'Recorrência Familiar?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t9_recorrencia_familiar'),
              onChanged: (v) => setState(() => _model.setString('t9_recorrencia_familiar', v)),
            ),
            if (_model.getString('t9_recorrencia_familiar') == '(1) Sim')
              OdontoTextField(label: 'Detalhes da recorrência familiar', controller: _ctrl('t9_recorrencia_detalhe')),
            const Divider(height: 24),
            softTissueRow('Freio labial superior', 'freio_sup'),
            softTissueRow('Freio labial inferior', 'freio_inf'),
            softTissueRow('Freio lingual', 'freio_ling'),
            softTissueRow('Língua', 'lingua'),
            OdontoTextField(label: 'Problema Posicional — Dentes', controller: _ctrl('t9_problema_posicional')),
          ],
        ),
        OdontoSectionCard(
          title: 'PARTE 5 — AVALIAÇÃO ORTODÔNTICA — DENTIÇÃO DECÍDUA',
          icon: Icons.straighten_outlined,
          children: [
            OdontoSingleChoice(
              question: '1. Você já levou seu filho para fazer alguma avaliação ortodôntica nos dentes?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t9_orto_q1_avaliacao'),
              onChanged: (v) => setState(() => _model.setString('t9_orto_q1_avaliacao', v)),
            ),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: '2.1 Linha Mediana da Maxila',
                  options: const ['(1) Normal', '(2) Desviada para Direita', '(3) Desviada para Esquerda'],
                  selected: _model.getString('t9_orto_q21_maxila'),
                  onChanged: (v) => setState(() => _model.setString('t9_orto_q21_maxila', v)),
                ),
                OdontoSingleChoice(
                  question: '2.2 Linha Mediana da Mandíbula',
                  options: const ['(1) Normal', '(2) Desviada para Direita', '(3) Desviada para Esquerda'],
                  selected: _model.getString('t9_orto_q22_mandibula'),
                  onChanged: (v) => setState(() => _model.setString('t9_orto_q22_mandibula', v)),
                ),
              ],
            ),
            sideSelector(
              '3. Tipo de Arco (Baume)',
              't9_orto_q3_baume',
              const ['(1) Tipo I', '(2) Tipo II'],
              const ['(1) Superior', '(2) Inferior'],
            ),
            sideSelector(
              '4. Relação Terminal 2º Molar decíduo',
              't9_orto_q4_molar2',
              const [
                '(1) Plano Reto',
                '(2) Degrau mesial para mandíbula',
                '(3) Degrau distal para mandíbula',
              ],
              const ['(1) Direito', '(2) Esquerdo'],
            ),
            sideSelector(
              '5. Relação Canino',
              't9_orto_q5_canino',
              const ['(1) Classe I', '(2) Classe II', '(3) Classe III'],
              const ['(1) Direito', '(2) Esquerdo'],
            ),
            sideSelector(
              '6. Presença de Espaço Primata',
              't9_orto_q6_primata',
              const ['(1) Na Maxila', '(2) Na Mandíbula'],
              const ['(1) Direito', '(2) Esquerdo'],
            ),
            OdontoSingleChoice(
              question: '7. Relação Transversal dos arcos',
              options: const [
                '(1) Mordida cruzada posterior funcional (topo-a-topo bilateral)',
                '(2) Oclusão Normal',
                '(3) Mordida Cruzada Posterior unilateral',
                '(4) Mordida Cruzada Posterior invertida',
              ],
              selected: _model.getString('t9_orto_q7_transversal'),
              onChanged: (v) => setState(() => _model.setString('t9_orto_q7_transversal', v)),
            ),
            OdontoSingleChoice(
              question: '8. Análise Vertical dos arcos',
              options: const ['(1) Sobremordida', '(2) Mordida aberta anterior', '(3) Topo-a-Topo'],
              selected: _model.getString('t9_orto_q8_vertical'),
              onChanged: (v) => setState(() => _model.setString('t9_orto_q8_vertical', v)),
            ),
          ],
        ),
        OdontoSectionCard(
          title: 'DENTIÇÃO MISTA E PERMANENTE',
          icon: Icons.layers_outlined,
          children: [
            sideSelector(
              'Primeiros molares',
              't9_mp_molares',
              const ['Classe I', 'Classe II', 'Classe III'],
              const ['Esquerdo', 'Direito'],
            ),
            sideSelector(
              'Caninos',
              't9_mp_caninos',
              const ['Classe I', 'Classe II', 'Classe III'],
              const ['Esquerdo', 'Direito'],
            ),
            OdontoSingleChoice(
              question: 'Classificação da Oclusão',
              options: const ['Normal', 'Classe I', 'Classe II', 'Classe III'],
              selected: _model.getString('t9_mp_oclusao'),
              onChanged: (v) => setState(() => _model.setString('t9_mp_oclusao', v)),
            ),
            if (_model.getString('t9_mp_oclusao') == 'Classe II') ...[
              OdontoMultiChoice(
                question: 'Detalhes Classe II (divisão / subdivisão)',
                options: const ['Div: 1', 'Div: 2', 'Sub div: direito', 'Sub div: esquerdo'],
                selectedValues: _model.getStringList('t9_mp_oclusao_c2'),
                onToggle: (v) => setState(() => _model.toggleInList('t9_mp_oclusao_c2', v)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Nota: Quando os molares de um lado apresentam relação de Classe I e o outro lado Classe II, recebe a denominação de subdivisão direita ou esquerda, conforme a chave de oclusão de Classe II esteja do lado direito ou esquerdo.',
                  style: TextStyle(fontSize: 11.5, color: Colors.blueGrey.shade600, fontStyle: FontStyle.italic),
                ),
              ),
            ],
            if (_model.getString('t9_mp_oclusao') == 'Classe III')
              OdontoMultiChoice(
                question: 'Detalhes Classe III (subdivisão)',
                options: const ['Sub div: direito', 'Sub div: esquerdo'],
                selectedValues: _model.getStringList('t9_mp_oclusao_c3'),
                onToggle: (v) => setState(() => _model.toggleInList('t9_mp_oclusao_c3', v)),
              ),
            OdontoSingleChoice(
              question: 'Classificação da Dentição',
              options: OdontopediatriaConstants.classificacaoDenticaoOptions,
              selected: _model.getString('t9_mp_denticao'),
              onChanged: (v) => setState(() => _model.setString('t9_mp_denticao', v)),
            ),
          ],
        ),
        OdontoSectionCard(
          title: 'EXAME FACIAL, INDICAÇÃO ORTODÔNTICA, EXAMES COMPLEMENTARES E ENDODONTIA',
          icon: Icons.assignment_turned_in_outlined,
          children: [
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: 'Exame Facial — Perfil do Paciente',
                  options: const ['(1) Reto', '(2) Côncavo', '(3) Convexo'],
                  selected: _model.getString('t9_facial_perfil'),
                  onChanged: (v) => setState(() => _model.setString('t9_facial_perfil', v)),
                ),
                OdontoSingleChoice(
                  question: '10. Sequência Eruptiva',
                  options: const ['(1) Favorável', '(2) Alterada'],
                  selected: _model.getString('t9_seq_eruptiva'),
                  onChanged: (v) => setState(() => _model.setString('t9_seq_eruptiva', v)),
                ),
              ],
            ),
            const Text(
              'Indicação ao Tratamento Ortodôntico',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            OdontoTextField(label: 'Diagnóstico', controller: _ctrl('t9_orto_diagnostico'), maxLines: 3),
            OdontoTextField(label: 'Tipo de Aparelho', controller: _ctrl('t9_orto_aparelho'), maxLines: 2),
            const Divider(height: 24),
            const Text(
              'Exames Complementares',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            for (final exam in OdontopediatriaConstants.examesComplementares)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(exam['label']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        value: _model.getBool('t9_ex_${exam['key']}_sel'),
                        onChanged: (v) => setState(() => _model.setBool('t9_ex_${exam['key']}_sel', v ?? false)),
                      ),
                      OdontoResponsiveRow(
                        children: [
                          OdontoTextField(
                            label: 'Data',
                            controller: _ctrl('t9_ex_${exam['key']}_data'),
                            hint: 'dd/mm/aaaa',
                          ),
                          OdontoTextField(
                            label: 'Observações',
                            controller: _ctrl('t9_ex_${exam['key']}_obs'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(height: 24),
            const Text(
              'Indicação ao Tratamento Endodôntico de dente permanente jovem',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Arcada Superior — Dentes', controller: _ctrl('t9_endo_sup_dentes')),
                OdontoTextField(label: 'Arcada Superior — Obs.', controller: _ctrl('t9_endo_sup_obs')),
              ],
            ),
            OdontoResponsiveRow(
              children: [
                OdontoTextField(label: 'Arcada Inferior — Dentes', controller: _ctrl('t9_endo_inf_dentes')),
                OdontoTextField(label: 'Arcada Inferior — Obs.', controller: _ctrl('t9_endo_inf_obs')),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TÓPICO 10 — PROCEDIMENTOS INVASIVOS E PLANEJAMENTO POR CONSULTA (PÁGINA 14)
  // ---------------------------------------------------------------------------
  Widget _buildTopic10Planejamento() {
    return Column(
      children: [
        OdontoSectionCard(
          title: 'RELAÇÃO DOS PROCEDIMENTOS CLÍNICOS INVASIVOS (EXO, ENDO, DENTÍSTICA)',
          subtitle: 'Registre os procedimentos planejados ou realizados por dente',
          icon: Icons.medical_services_outlined,
          children: [
            for (final entry in OdontopediatriaConstants.clinicalQuadrants.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 8),
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
              ),
              for (final tooth in entry.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                        decoration: BoxDecoration(
                          color: kOdontoPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tooth.displayLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: kOdontoPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _ctrl('t10_inv_${tooth.key}'),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Ex.: Restauração, Exodontia, Pulpotomia...',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
            ],
          ],
        ),
        OdontoSectionCard(
          title: 'OPERACIONALIZAÇÃO (PLANEJAMENTO POR CONSULTA)',
          subtitle: 'Planejamento sequencial da 1ª à 11ª consulta',
          icon: Icons.event_note_outlined,
          children: [
            for (int c = 1; c <= 11; c++)
              OdontoTextField(
                label: '$cª Consulta',
                controller: _ctrl('t10_consulta_$c'),
                maxLines: 2,
                hint: 'Procedimentos planejados para a $cª consulta...',
              ),
          ],
        ),
      ],
    );
  }
}
