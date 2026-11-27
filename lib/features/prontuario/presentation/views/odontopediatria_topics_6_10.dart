part of 'odontopediatria_screen.dart';

extension _OdontopediatriaTopics6To10 on _OdontopediatriaScreenState {
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
                  onChanged: (v) => _updateState(() => _model.setString('t6_local', v ?? '')),
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
              onChanged: (k, v) => _updateState(() => _model.setString('t6_m6_$k', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t6_6a23_peito', v)),
            ),
            OdontoSingleChoice(
              question: 'Ontem, a criança comeu fruta inteira, em pedaço ou amassada?',
              options: const ['Sim', 'Não', 'Não Sabe'],
              selected: _model.getString('t6_6a23_fruta'),
              onChanged: (v) => _updateState(() => _model.setString('t6_6a23_fruta', v)),
            ),
            if (_model.getString('t6_6a23_fruta') == 'Sim')
              OdontoSingleChoice(
                question: 'Se sim, quantas vezes comeu fruta?',
                options: const ['1 vez', '2 vezes', '3 vezes ou mais', 'Não Sabe'],
                selected: _model.getString('t6_6a23_fruta_vezes'),
                onChanged: (v) => _updateState(() => _model.setString('t6_6a23_fruta_vezes', v)),
              ),
            OdontoSingleChoice(
              question: 'Ontem a criança comeu comida de sal (de panela, papa ou sopa)?',
              options: const ['Sim', 'Não', 'Não Sabe'],
              selected: _model.getString('t6_6a23_sal'),
              onChanged: (v) => _updateState(() => _model.setString('t6_6a23_sal', v)),
            ),
            if (_model.getString('t6_6a23_sal') == 'Sim') ...[
              OdontoSingleChoice(
                question: 'Se sim, quantas vezes comeu comida de sal?',
                options: const ['1 vez', '2 vezes', '3 vezes ou mais', 'Não Sabe'],
                selected: _model.getString('t6_6a23_sal_vezes'),
                onChanged: (v) => _updateState(() => _model.setString('t6_6a23_sal_vezes', v)),
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
                onChanged: (v) => _updateState(() => _model.setString('t6_6a23_sal_consistencia', v)),
              ),
            ],
            OdontoTriStateTable(
              headerLabel: 'Ontem a criança consumiu:',
              items: OdontopediatriaConstants.consumo6a23MesesItens,
              choices: const ['Sim', 'Não', 'Não Sabe'],
              valueFor: (k) => _model.getString('t6_6a23_$k'),
              onChanged: (k, v) => _updateState(() => _model.setString('t6_6a23_$k', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t6_2m_telas', v)),
            ),
            OdontoMultiChoice(
              question: 'Quais refeições você faz ao longo do dia?',
              options: OdontopediatriaConstants.refeicoesDiaOptions,
              selectedValues: _model.getStringList('t6_2m_refeicoes'),
              onToggle: (v) => _updateState(() => _model.toggleInList('t6_2m_refeicoes', v)),
            ),
            OdontoTriStateTable(
              headerLabel: 'Ontem, você consumiu:',
              items: OdontopediatriaConstants.consumo2AnosOuMaisItens,
              choices: const ['Sim', 'Não', 'Não Sabe'],
              valueFor: (k) => _model.getString('t6_2m_$k'),
              onChanged: (k, v) => _updateState(() => _model.setString('t6_2m_$k', v)),
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
          onChanged: () => _updateState(() {}),
        ),
        OdontoBinarySurfaceGrid(
          title: 'ISG — ÍNDICE DE SANGRAMENTO GENGIVAL',
          legendZero: 'ausência de sangramento',
          legendOne: 'presença de sangramento',
          surfaces: const ['V', 'P', 'M', 'D'],
          disableOcclusalOnAnterior: false,
          gridKey: 't7_isg_grid',
          model: _model,
          onChanged: () => _updateState(() {}),
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
          onChanged: () => _updateState(() {}),
        ),
        OdontoSectionCard(
          title: 'PERFIL DO PACIENTE COM RELAÇÃO À DOENÇA CÁRIE',
          icon: Icons.assessment_outlined,
          children: [
            OdontoMultiChoice(
              question: 'Selecione a classificação aplicável ao paciente',
              options: OdontopediatriaConstants.perfilCarieOptions,
              selectedValues: _model.getStringList('t8_perfil_carie'),
              onToggle: (v) => _updateState(() => _model.toggleInList('t8_perfil_carie', v)),
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
          onChanged: () => _updateState(() {}),
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
                              onSelected: (_) => _updateState(() => _model.toggleInList('${keyPrefix}_$i', side)),
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
              onChanged: (v) => _updateState(() => _model.setString('t9_tm_${key}_status', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t9_outras_anomalias', v)),
            ),
            if (_model.getString('t9_outras_anomalias') == '(1) Sim')
              OdontoTextField(label: 'Especifique outras anomalias', controller: _ctrl('t9_outras_anomalias_detalhe')),
            OdontoSingleChoice(
              question: 'Dentes decíduos anquilosados?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t9_anquilosados'),
              onChanged: (v) => _updateState(() => _model.setString('t9_anquilosados', v)),
            ),
            if (_model.getString('t9_anquilosados') == '(1) Sim')
              OdontoTextField(label: 'Quais dentes anquilosados?', controller: _ctrl('t9_anquilosados_detalhe')),
            OdontoSingleChoice(
              question: 'Problemas na sequência de erupção e esfoliação dos dentes?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t9_seq_erupcao'),
              onChanged: (v) => _updateState(() => _model.setString('t9_seq_erupcao', v)),
            ),
            if (_model.getString('t9_seq_erupcao') == '(1) Sim')
              OdontoTextField(label: 'Descreva o problema de erupção/esfoliação', controller: _ctrl('t9_seq_erupcao_detalhe')),
            OdontoTextField(label: 'Perda Precoce dos Dentes Decíduos', controller: _ctrl('t9_perda_precoce')),
            OdontoSingleChoice(
              question: 'Recorrência Familiar?',
              options: const ['(1) Sim', '(2) Não'],
              selected: _model.getString('t9_recorrencia_familiar'),
              onChanged: (v) => _updateState(() => _model.setString('t9_recorrencia_familiar', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t9_orto_q1_avaliacao', v)),
            ),
            OdontoResponsiveRow(
              children: [
                OdontoSingleChoice(
                  question: '2.1 Linha Mediana da Maxila',
                  options: const ['(1) Normal', '(2) Desviada para Direita', '(3) Desviada para Esquerda'],
                  selected: _model.getString('t9_orto_q21_maxila'),
                  onChanged: (v) => _updateState(() => _model.setString('t9_orto_q21_maxila', v)),
                ),
                OdontoSingleChoice(
                  question: '2.2 Linha Mediana da Mandíbula',
                  options: const ['(1) Normal', '(2) Desviada para Direita', '(3) Desviada para Esquerda'],
                  selected: _model.getString('t9_orto_q22_mandibula'),
                  onChanged: (v) => _updateState(() => _model.setString('t9_orto_q22_mandibula', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t9_orto_q7_transversal', v)),
            ),
            OdontoSingleChoice(
              question: '8. Análise Vertical dos arcos',
              options: const ['(1) Sobremordida', '(2) Mordida aberta anterior', '(3) Topo-a-Topo'],
              selected: _model.getString('t9_orto_q8_vertical'),
              onChanged: (v) => _updateState(() => _model.setString('t9_orto_q8_vertical', v)),
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
              onChanged: (v) => _updateState(() => _model.setString('t9_mp_oclusao', v)),
            ),
            if (_model.getString('t9_mp_oclusao') == 'Classe II') ...[
              OdontoMultiChoice(
                question: 'Detalhes Classe II (divisão / subdivisão)',
                options: const ['Div: 1', 'Div: 2', 'Sub div: direito', 'Sub div: esquerdo'],
                selectedValues: _model.getStringList('t9_mp_oclusao_c2'),
                onToggle: (v) => _updateState(() => _model.toggleInList('t9_mp_oclusao_c2', v)),
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
                onToggle: (v) => _updateState(() => _model.toggleInList('t9_mp_oclusao_c3', v)),
              ),
            OdontoSingleChoice(
              question: 'Classificação da Dentição',
              options: OdontopediatriaConstants.classificacaoDenticaoOptions,
              selected: _model.getString('t9_mp_denticao'),
              onChanged: (v) => _updateState(() => _model.setString('t9_mp_denticao', v)),
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
                  onChanged: (v) => _updateState(() => _model.setString('t9_facial_perfil', v)),
                ),
                OdontoSingleChoice(
                  question: '10. Sequência Eruptiva',
                  options: const ['(1) Favorável', '(2) Alterada'],
                  selected: _model.getString('t9_seq_eruptiva'),
                  onChanged: (v) => _updateState(() => _model.setString('t9_seq_eruptiva', v)),
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
                        onChanged: (v) => _updateState(() => _model.setBool('t9_ex_${exam['key']}_sel', v ?? false)),
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
