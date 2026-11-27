part of 'odontopediatria_screen.dart';

extension _OdontopediatriaTopics1To5 on _OdontopediatriaScreenState {
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
                  onChanged: (v) => _updateState(() => _model.setString('t1_sexo', v)),
                ),
                OdontoTextField(label: 'Cor / Raça', controller: _ctrl('t1_cor')),
              ],
            ),
            OdontoSingleChoice(
              question: 'Portador de alguma necessidade / deficiência?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t1_necessidade_especial'),
              onChanged: (v) => _updateState(() => _model.setString('t1_necessidade_especial', v)),
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
              onChanged: (v) => _updateState(() => _model.setBool('t1_termo_aceito', v ?? false)),
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
              onChanged: (v) => _updateState(() => _model.setString('t2_vinculo', v)),
            ),
            if (_model.getString('t2_vinculo') == '(2) Responsável pela criança')
              OdontoTextField(label: 'Parentesco', controller: _ctrl('t2_parentesco')),
            OdontoSingleChoice(
              question: '1. Qual o grau de instrução da MÃE?',
              options: OdontopediatriaConstants.grauInstrucaoOptions,
              selected: _model.getString('t2_q1_instrucao_mae'),
              onChanged: (v) => _updateState(() => _model.setString('t2_q1_instrucao_mae', v)),
            ),
            OdontoSingleChoice(
              question: '2. Qual o grau de instrução do PAI?',
              options: OdontopediatriaConstants.grauInstrucaoOptions,
              selected: _model.getString('t2_q2_instrucao_pai'),
              onChanged: (v) => _updateState(() => _model.setString('t2_q2_instrucao_pai', v)),
            ),
            OdontoSingleChoice(
              question: '3. Ocupação da mãe: a mãe da criança trabalha fora de casa?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t2_q3_mae_trabalha_fora'),
              onChanged: (v) => _updateState(() => _model.setString('t2_q3_mae_trabalha_fora', v)),
            ),
            if (_model.getString('t2_q3_mae_trabalha_fora') == '(1) Sim')
              OdontoMultiChoice(
                question: 'Turnos em que a mãe trabalha fora',
                options: const ['(1.1) Manhã', '(1.2) Tarde', '(1.3) Noite'],
                selectedValues: _model.getStringList('t2_q3_turnos'),
                onToggle: (v) => _updateState(() => _model.toggleInList('t2_q3_turnos', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t2_q5_relacao_trabalho', v)),
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
              onChanged: (key, val) => _updateState(() => _model.setString('t2_q6_$key', val)),
            ),
            OdontoSingleChoice(
              question: '7. Você tem algum problema de saúde atualmente?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t2_q7_problema_saude'),
              onChanged: (v) => _updateState(() => _model.setString('t2_q7_problema_saude', v)),
            ),
            if (_model.getString('t2_q7_problema_saude') == '(1) Sim')
              OdontoTextField(label: 'Qual problema de saúde?', controller: _ctrl('t2_q7_qual')),
            OdontoSingleChoice(
              question: '8. Você já recebeu informações sobre como cuidar da sua saúde?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t2_q8_info_saude'),
              onChanged: (v) => _updateState(() => _model.setString('t2_q8_info_saude', v)),
            ),
            if (_model.getString('t2_q8_info_saude') == '(1) Sim')
              OdontoTextField(label: 'Quem deu a informação?', controller: _ctrl('t2_q8_quem')),
            OdontoSingleChoice(
              question: '9. Você já foi ao dentista?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t2_q9_foi_dentista'),
              onChanged: (v) => _updateState(() => _model.setString('t2_q9_foi_dentista', v)),
            ),
            if (_model.getString('t2_q9_foi_dentista') == '(1) Sim')
              OdontoTextField(label: 'Qual o motivo da consulta?', controller: _ctrl('t2_q9_motivo')),
            OdontoSingleChoice(
              question: '10. Como você realiza a sua higiene bucal?',
              options: OdontopediatriaConstants.higieneComoOptions,
              selected: _model.getString('t2_q10_como_higiene'),
              onChanged: (v) => _updateState(() => _model.setString('t2_q10_como_higiene', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t2_q12_vezes_escova', v)),
            ),
            OdontoMultiChoice(
              question: '13. Quais os HORÁRIOS que você escova os seus dentes durante o dia?',
              options: OdontopediatriaConstants.escovacaoHorariosOptions,
              selectedValues: _model.getStringList('t2_q13_horarios'),
              onToggle: (v) => _updateState(() => _model.toggleInList('t2_q13_horarios', v)),
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
          onChanged: (v) => _updateState(() => _model.setString('t3_q1_liquidos_acucar', v)),
        ),
        OdontoSingleChoice(
          question: '2. Você toma refrigerantes?',
          options: const ['(1) Sim', '(2) Não'],
          selected: _model.getString('t3_q2_refrigerantes'),
          onChanged: (v) => _updateState(() => _model.setString('t3_q2_refrigerantes', v)),
        ),
        if (_model.getString('t3_q2_refrigerantes') == '(1) Sim') ...[
          OdontoTextField(label: 'Quais tipos de refrigerantes?', controller: _ctrl('t3_q2_tipos')),
          OdontoSingleChoice(
            question: 'Frequência de consumo de refrigerantes',
            options: OdontopediatriaConstants.dietaFrequenciaOptions,
            selected: _model.getString('t3_q2_frequencia'),
            onChanged: (v) => _updateState(() => _model.setString('t3_q2_frequencia', v)),
          ),
        ],
        OdontoSingleChoice(
          question: '3. Qual o tipo de vasilha você costuma tomar refrigerante?',
          options: OdontopediatriaConstants.vasilhaRefrigeranteOptions,
          selected: _model.getString('t3_q3_vasilha'),
          onChanged: (v) => _updateState(() => _model.setString('t3_q3_vasilha', v)),
        ),
        OdontoSingleChoice(
          question: '5. Você consome biscoitos doces, biscoitos recheados, bolos, bombons, chicletes?',
          options: const ['(1) Sim', '(2) Não', '(9) Não consome'],
          selected: _model.getString('t3_q5_doces'),
          onChanged: (v) => _updateState(() => _model.setString('t3_q5_doces', v)),
        ),
        if (_model.getString('t3_q5_doces') == '(1) Sim')
          OdontoSingleChoice(
            question: 'Frequência de consumo de doces/biscoitos',
            options: OdontopediatriaConstants.dietaFrequenciaOptions,
            selected: _model.getString('t3_q5_frequencia'),
            onChanged: (v) => _updateState(() => _model.setString('t3_q5_frequencia', v)),
          ),
        OdontoSingleChoice(
          question: '6. Você consome salgadinhos de pacote (pipoca, ruffles, cheetos)?',
          options: const ['(1) Sim', '(2) Não', '(9) Não consome'],
          selected: _model.getString('t3_q6_salgadinhos'),
          onChanged: (v) => _updateState(() => _model.setString('t3_q6_salgadinhos', v)),
        ),
        if (_model.getString('t3_q6_salgadinhos') == '(1) Sim')
          OdontoSingleChoice(
            question: 'Frequência de consumo de salgadinhos de pacote',
            options: OdontopediatriaConstants.dietaFrequenciaOptions,
            selected: _model.getString('t3_q6_frequencia'),
            onChanged: (v) => _updateState(() => _model.setString('t3_q6_frequencia', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t4_pn_q1_gestacao', v)),
            ),
            if (_model.getString('t4_pn_q1_gestacao') == '(2) Problemática / Complicações')
              OdontoTextField(label: 'Especifique as complicações da gestação', controller: _ctrl('t4_pn_q1_detalhe')),
            OdontoSingleChoice(
              question: '2. Tipo de Parto',
              options: const ['(1) Normal', '(2) Cesária', '(3) Fórceps'],
              selected: _model.getString('t4_pn_q2_parto'),
              onChanged: (v) => _updateState(() => _model.setString('t4_pn_q2_parto', v)),
            ),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: '3. A criança nasceu prematura?',
                  options: const ['(1) Sim', '(2) Não'],
                  selected: _model.getString('t4_pn_q3_prematura'),
                  onChanged: (v) => _updateState(() => _model.setString('t4_pn_q3_prematura', v)),
                ),
                OdontoTextField(
                  label: '4. Nasceu de quantos meses de gestação?',
                  controller: _ctrl('t4_pn_q4_meses_gestacao'),
                ),
                OdontoSingleChoice(
                  question: '5. Parto de gêmeos?',
                  options: const ['(1) Sim', '(2) Não'],
                  selected: _model.getString('t4_pn_q5_gemeos'),
                  onChanged: (v) => _updateState(() => _model.setString('t4_pn_q5_gemeos', v)),
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
                  onChanged: (v) => _updateState(() => _model.setString('t4_pn_q11_exclusivo_agora', v)),
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
                  onChanged: (v) => _updateState(() => _model.setString('t4_pn_q13_acorda_noite', v)),
                ),
                OdontoSingleChoice(
                  question: '14. Costuma dormir mamando no peito?',
                  options: const ['(1) Sim', '(2) Não'],
                  selected: _model.getString('t4_pn_q14_dorme_mamando'),
                  onChanged: (v) => _updateState(() => _model.setString('t4_pn_q14_dorme_mamando', v)),
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
              onToggle: (v) => _updateState(() => _model.toggleInList('t4_pn_q16_quais_alimentos', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q1_inicio_limpeza', v)),
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
                  onChanged: (v) => _updateState(() => _model.setString('t4_hb_q3_sozinha', v)),
                ),
              ],
            ),
            OdontoMultiChoice(
              question: '4. Atualmente, QUEM realiza a higiene da boca da criança?',
              options: OdontopediatriaConstants.quemRealizaHigieneOptions,
              selectedValues: _model.getStringList('t4_hb_q4_quem'),
              onToggle: (v) => _updateState(() => _model.toggleInList('t4_hb_q4_quem', v)),
            ),
            if (_model.getStringList('t4_hb_q4_quem').contains('(8) Outros'))
              OdontoTextField(label: 'Outros (quem realiza)', controller: _ctrl('t4_hb_q4_outros')),
            OdontoSingleChoice(
              question: '5. Atualmente, COMO realiza a higiene da boca?',
              options: OdontopediatriaConstants.higieneComoOptions,
              selected: _model.getString('t4_hb_q5_como'),
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q5_como', v)),
            ),
            if (_model.getString('t4_hb_q5_como') == '(4) Outros')
              OdontoTextField(label: 'Outros (como realiza)', controller: _ctrl('t4_hb_q5_outros')),
            OdontoSingleChoice(
              question: '6. QUAL creme dental (pasta) é utilizado na higiene da boca do seu filho?',
              options: const ['(1) Infantil', '(2) O mesmo que todos os adultos da casa'],
              selected: _model.getString('t4_hb_q6_tipo_pasta'),
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q6_tipo_pasta', v)),
            ),
            OdontoTextField(label: 'Qual marca / nome do creme dental?', controller: _ctrl('t4_hb_q6_qual_pasta')),
            OdontoSingleChoice(
              question: '7. O creme dental (pasta) tem FLÚOR?',
              options: const ['(1) Sim', '(2) Não', '(9) Não sabe / Não lembra'],
              selected: _model.getString('t4_hb_q7_tem_fluor'),
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q7_tem_fluor', v)),
            ),
            OdontoSingleChoice(
              question: '8. Qual o NÚMERO DE VEZES que a criança escova os dentes durante o dia?',
              options: OdontopediatriaConstants.escovacaoFrequenciaOptions,
              selected: _model.getString('t4_hb_q8_vezes'),
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q8_vezes', v)),
            ),
            OdontoMultiChoice(
              question: '9. Marque TODOS os HORÁRIOS que a criança escova os dentes durante o dia',
              options: OdontopediatriaConstants.escovacaoHorariosOptions,
              selectedValues: _model.getStringList('t4_hb_q9_horarios'),
              onToggle: (v) => _updateState(() => _model.toggleInList('t4_hb_q9_horarios', v)),
            ),
            const Divider(height: 24),
            OdontoSingleChoice(
              question: '10. A criança já foi ao dentista?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t4_hb_q10_foi_dentista'),
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q10_foi_dentista', v)),
            ),
            OdontoMultiChoice(
              question: '11. Qual o motivo da consulta ao cirurgião-dentista?',
              options: OdontopediatriaConstants.motivoConsultaCriancaOptions,
              selectedValues: _model.getStringList('t4_hb_q11_motivo'),
              onToggle: (v) => _updateState(() => _model.toggleInList('t4_hb_q11_motivo', v)),
            ),
            if (_model.getStringList('t4_hb_q11_motivo').contains('(9) Outro'))
              OdontoTextField(label: 'Outro motivo', controller: _ctrl('t4_hb_q11_outro')),
            OdontoSingleChoice(
              question: '12. Em caso de dor, quando foi que doeu o dente do seu filho?',
              options: OdontopediatriaConstants.quandoDoeuOptions,
              selected: _model.getString('t4_hb_q12_quando_doeu'),
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q12_quando_doeu', v)),
            ),
            OdontoSingleChoice(
              question: '13. Seu filho sentia dor quando?',
              options: OdontopediatriaConstants.sentiaDorQuandoOptions,
              selected: _model.getString('t4_hb_q13_dor_quando'),
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q13_dor_quando', v)),
            ),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: '14. Seu filho chorou?',
                  options: const ['(1) Sim', '(2) Não', '(3) Às vezes'],
                  selected: _model.getString('t4_hb_q14_chorou'),
                  onChanged: (v) => _updateState(() => _model.setString('t4_hb_q14_chorou', v)),
                ),
                OdontoSingleChoice(
                  question: '15. Acordou à noite por causa da dor?',
                  options: const ['(1) Sim', '(2) Não', '(9) Não lembra / Não sabe'],
                  selected: _model.getString('t4_hb_q15_acordou_dor'),
                  onChanged: (v) => _updateState(() => _model.setString('t4_hb_q15_acordou_dor', v)),
                ),
              ],
            ),
            OdontoMultiChoice(
              question: '16. Se o seu filho foi ao dentista, qual procedimento realizado?',
              options: OdontopediatriaConstants.procedimentoRealizadoOptions,
              selectedValues: _model.getStringList('t4_hb_q16_procedimento'),
              onToggle: (v) => _updateState(() => _model.toggleInList('t4_hb_q16_procedimento', v)),
            ),
            OdontoSingleChoice(
              question: '17. Seu filho teve alguma reação alérgica ao anestésico utilizado?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t4_hb_q17_alergia_anestesico'),
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q17_alergia_anestesico', v)),
            ),
            OdontoSingleChoice(
              question: '18. A criança já tomou ANTIBIÓTICO? (ex.: Amoxicilina, Penicilina, Eritromicina, Clavulin)',
              options: const ['(1) Sim', '(2) Não', '(9) Não sabe / Não lembra'],
              selected: _model.getString('t4_hb_q18_antibiotico'),
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q18_antibiotico', v)),
            ),
            OdontoTextField(label: 'Obs. Antibiótico', controller: _ctrl('t4_hb_q18_obs')),
            OdontoSingleChoice(
              question: '19. A criança recebeu orientação de higiene bucal?',
              options: const ['(1) Sim', '(2) Não', '(9) Não sabe / Não lembra'],
              selected: _model.getString('t4_hb_q19_orientacao'),
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q19_orientacao', v)),
            ),
            OdontoTextField(label: 'Obs. Orientação de higiene bucal', controller: _ctrl('t4_hb_q19_obs')),
            OdontoSingleChoice(
              question: '20. A criança já fez uso do Flúor (ATF / Bochecho / Uso profissional)?',
              options: const ['(1) Sim', '(2) Não', '(9) Não sabe / Não lembra'],
              selected: _model.getString('t4_hb_q20_uso_fluor'),
              onChanged: (v) => _updateState(() => _model.setString('t4_hb_q20_uso_fluor', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t5_hma_cirurgia', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t5_hma_hospitalizado', v)),
            ),
            if (_model.getString('t5_hma_hospitalizado') == '(1) Sim')
              OdontoTextField(label: 'Motivo da hospitalização', controller: _ctrl('t5_hma_hospitalizado_motivo')),
            OdontoSingleChoice(
              question: 'Tem alergia?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hma_alergia'),
              onChanged: (v) => _updateState(() => _model.setString('t5_hma_alergia', v)),
            ),
            if (_model.getString('t5_hma_alergia') == '(1) Sim')
              OdontoTextField(label: 'A quê?', controller: _ctrl('t5_hma_alergia_qual')),
            OdontoSingleChoice(
              question: 'A vacinação está em dia?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hma_vacinacao'),
              onChanged: (v) => _updateState(() => _model.setString('t5_hma_vacinacao', v)),
            ),
            OdontoTextField(label: 'Quais vacinas / observações?', controller: _ctrl('t5_hma_vacinacao_quais')),
            OdontoSingleChoice(
              question: 'Está em tratamento médico?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hma_tratamento_medico'),
              onChanged: (v) => _updateState(() => _model.setString('t5_hma_tratamento_medico', v)),
            ),
            if (_model.getString('t5_hma_tratamento_medico') == '(1) Sim')
              OdontoTextField(label: 'Especifique o tratamento médico', controller: _ctrl('t5_hma_tratamento_detalhe')),
            OdontoSingleChoice(
              question: 'Está tomando algum medicamento?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hma_medicamento_atual'),
              onChanged: (v) => _updateState(() => _model.setString('t5_hma_medicamento_atual', v)),
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
              onToggle: (v) => _updateState(() => _model.toggleInList('t5_hma_doencas_infancia', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t5_hmat_respiracao', v)),
            ),
            OdontoSingleChoice(
              question: 'Alteração na Visão / Fonação / Andar / Na pele?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t5_hmat_alteracao'),
              onChanged: (v) => _updateState(() => _model.setString('t5_hmat_alteracao', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t5_psico_escolar', v)),
            ),
            if (_model.getString('t5_psico_escolar') == '(6) Outro problema comportamental')
              OdontoTextField(label: 'Qual problema comportamental?', controller: _ctrl('t5_psico_escolar_outro')),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: 'Adaptação Familiar',
                  options: const ['(1) Normal', '(2) Agitado', '(3) Agressivo'],
                  selected: _model.getString('t5_psico_familiar'),
                  onChanged: (v) => _updateState(() => _model.setString('t5_psico_familiar', v)),
                ),
                OdontoSingleChoice(
                  question: 'Sono',
                  options: const ['(1) Tranquilo', '(2) Agitado', '(3) Acorda várias vezes à noite'],
                  selected: _model.getString('t5_psico_sono'),
                  onChanged: (v) => _updateState(() => _model.setString('t5_psico_sono', v)),
                ),
              ],
            ),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: 'Qual o período escolar que frequenta?',
                  options: const ['(1) Manhã', '(2) Tarde', '(3) Integral'],
                  selected: _model.getString('t5_psico_periodo'),
                  onChanged: (v) => _updateState(() => _model.setString('t5_psico_periodo', v)),
                ),
                OdontoSingleChoice(
                  question: 'Tem dificuldades na escola?',
                  options: const ['(1) Sim', '(2) Não'],
                  selected: _model.getString('t5_psico_dificuldade'),
                  onChanged: (v) => _updateState(() => _model.setString('t5_psico_dificuldade', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t5_hd_chupeta', v)),
            ),
            if (_model.getString('t5_hd_chupeta') == '(1) Sim') ...[
              OdontoMultiChoice(
                question: 'Período da sucção de chupeta',
                options: const ['(1.1) À noite', '(1.2) Durante o dia'],
                selectedValues: _model.getStringList('t5_hd_chupeta_periodo'),
                onToggle: (v) => _updateState(() => _model.toggleInList('t5_hd_chupeta_periodo', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t5_hd_dedo', v)),
            ),
            if (_model.getString('t5_hd_dedo') == '(1) Sim') ...[
              OdontoMultiChoice(
                question: 'Período da sucção de dedos',
                options: const ['(1.1) À noite', '(1.2) Durante o dia'],
                selectedValues: _model.getStringList('t5_hd_dedo_periodo'),
                onToggle: (v) => _updateState(() => _model.toggleInList('t5_hd_dedo_periodo', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t5_hd_outros', v)),
            ),
            if (_model.getString('t5_hd_outros') == '(1) Sim') ...[
              OdontoMultiChoice(
                question: 'Quais hábitos?',
                options: OdontopediatriaConstants.outrosHabitosOptions,
                selectedValues: _model.getStringList('t5_hd_outros_lista'),
                onToggle: (v) => _updateState(() => _model.toggleInList('t5_hd_outros_lista', v)),
              ),
              OdontoTextField(label: 'Cessou — idade', controller: _ctrl('t5_hd_outros_cessou')),
            ],
            const Divider(height: 20),
            OdontoSingleChoice(
              question: 'A criança tem o hábito de ranger ou apertar os dentes?',
              options: const ['(2) Não', '(1) Sim'],
              selected: _model.getString('t5_hd_bruxismo'),
              onChanged: (v) => _updateState(() => _model.setString('t5_hd_bruxismo', v)),
            ),
            if (_model.getString('t5_hd_bruxismo') == '(1) Sim') ...[
              OdontoMultiChoice(
                question: 'Características do ranger / apertar os dentes',
                options: OdontopediatriaConstants.bruxismoDetalhesOptions,
                selectedValues: _model.getStringList('t5_hd_bruxismo_detalhes'),
                onToggle: (v) => _updateState(() => _model.toggleInList('t5_hd_bruxismo_detalhes', v)),
              ),
              OdontoTextField(label: 'Outros hábitos (especifique)', controller: _ctrl('t5_hd_bruxismo_outros')),
            ],
          ],
        ),
      ],
    );
  }

}
