class ToothPairSpec {
  final String key;
  final String permanent;
  final String deciduous;
  final bool hasOcclusal;

  const ToothPairSpec({
    required this.key,
    required this.permanent,
    this.deciduous = '',
    this.hasOcclusal = true,
  });

  String get displayLabel =>
      deciduous.isEmpty ? permanent : '$permanent / $deciduous';
}

class OdontopediatriaTopicSpec {
  final String id;
  final String shortTitle;
  final String fullTitle;
  final String subtitle;

  const OdontopediatriaTopicSpec({
    required this.id,
    required this.shortTitle,
    required this.fullTitle,
    required this.subtitle,
  });
}

class OdontopediatriaConstants {
  static const List<OdontopediatriaTopicSpec> topics = [
    OdontopediatriaTopicSpec(
      id: 'identificacao',
      shortTitle: '1. Identificação',
      fullTitle: 'Identificação do Paciente e Termo de Autorização',
      subtitle: 'Dados cadastrais, responsáveis, motivo da consulta e termo de compromisso (UFMA)',
    ),
    OdontopediatriaTopicSpec(
      id: 'mae_responsavel',
      shortTitle: '2. Mãe / Resp.',
      fullTitle: 'Parte 1 — Dados da Mãe ou Responsável pela Criança',
      subtitle: 'Escolaridade, ocupação, renda, saúde geral e higiene bucal do responsável',
    ),
    OdontopediatriaTopicSpec(
      id: 'dieta_responsavel',
      shortTitle: '3. Dieta Resp.',
      fullTitle: 'Parte 2 — Dados da Dieta da Mãe / Responsável',
      subtitle: 'Consumo de bebidas açucaradas, refrigerantes, doces e salgadinhos',
    ),
    OdontopediatriaTopicSpec(
      id: 'pre_pos_natal_higiene',
      shortTitle: '4. Pré/Pós-Natal e Higiene',
      fullTitle: 'Parte 3 — Período Pré/Pós-Natal e Hábitos de Higiene Bucal da Criança',
      subtitle: 'Gestação, parto, amamentação, higiene bucal e histórico odontológico',
    ),
    OdontopediatriaTopicSpec(
      id: 'historia_medica_psico',
      shortTitle: '5. Saúde e Hábitos',
      fullTitle: 'História Médica, Comportamento Psicológico e Hábitos Deletérios',
      subtitle: 'História médica anterior/atual, doenças de infância, comportamento e hábitos',
    ),
    OdontopediatriaTopicSpec(
      id: 'consumo_alimentar',
      shortTitle: '6. Consumo Alimentar',
      fullTitle: 'Marcadores de Consumo Alimentar',
      subtitle: 'Menores de 6 meses, 6 a 23 meses e crianças com 2 anos ou mais',
    ),
    OdontopediatriaTopicSpec(
      id: 'ipv_isg',
      shortTitle: '7. IPV e ISG',
      fullTitle: 'Índice de Placa Visível (IPV) e Sangramento Gengival (ISG)',
      subtitle: 'Registro por face (V, P, M, D, O) com cálculo automático de percentual',
    ),
    OdontopediatriaTopicSpec(
      id: 'exame_clinico_rx',
      shortTitle: '8. Clínico e Rx',
      fullTitle: 'Exame Clínico, Observações Clínicas e Exame Radiográfico',
      subtitle: 'Dentes presentes, códigos de cárie (0–10), perfil de risco e radiolucidez (0–7)',
    ),
    OdontopediatriaTopicSpec(
      id: 'anomalias_orto',
      shortTitle: '9. Anomalias / Orto',
      fullTitle: 'Parte 4 e 5 — Anomalias Dentárias e Avaliação Ortodôntica',
      subtitle: 'Anomalias, tecidos moles, dentição decídua/mista/permanente, perfil facial e exames',
    ),
    OdontopediatriaTopicSpec(
      id: 'planejamento',
      shortTitle: '10. Planejamento',
      fullTitle: 'Procedimentos Clínicos Invasivos e Operacionalização por Consulta',
      subtitle: 'Relação por dente (Exo, Endo, Dentística) e planejamento da 1ª à 11ª consulta',
    ),
  ];

  static const List<String> grauInstrucaoOptions = [
    '(1) Analfabeto ou fundamental incompleto',
    '(2) Fundamental completo',
    '(3) Ensino médio completo',
    '(4) Ensino médio incompleto',
    '(5) Ensino superior completo',
    '(6) Ensino superior incompleto',
    '(9) Não sabe relatar',
  ];

  static const List<String> relacaoTrabalhoOptions = [
    '(1) Trabalha por conta própria',
    '(2) Assalariado ou empregado',
    '(3) Dono de empresa / empregador',
    '(4) Faz bico',
    '(9) Não sabe',
  ];

  static const List<Map<String, String>> doencasResponsavel = [
    {'key': 'pressao_alta', 'label': 'Pressão alta?'},
    {'key': 'colesterol', 'label': 'Colesterol alto / triglicerídeo alto?'},
    {'key': 'diabetes', 'label': 'Diabetes?'},
    {'key': 'renal', 'label': 'Doença renal?'},
    {'key': 'cancer', 'label': 'Câncer?'},
    {
      'key': 'cardiovascular',
      'label': 'Problemas cardiovasculares (batimento acelerado no coração / palpitação / dor no peito)?',
    },
  ];

  static const List<String> higieneComoOptions = [
    '(1) Só com escova de dente',
    '(2) Escova de dente + creme dental (pasta)',
    '(3) Escova de dente + creme dental (pasta) + fio dental',
    '(4) Outros',
  ];

  static const List<String> escovacaoFrequenciaOptions = [
    '(1) Uma vez',
    '(2) Duas vezes',
    '(3) Três vezes',
    '(4) Quatro vezes',
    '(5) Mais de quatro vezes',
  ];

  static const List<String> escovacaoHorariosOptions = [
    '(1) Ao acordar',
    '(2) Após o café da manhã',
    '(3) Após o lanche da manhã',
    '(4) Após o almoço',
    '(5) Após o lanche da tarde',
    '(6) Após o jantar',
    '(7) Antes de dormir à noite',
  ];

  static const List<String> dietaFrequenciaOptions = [
    '(1) Diariamente',
    '(2) 2 a 3 vezes por semana',
    '(3) Finais de semana',
    '(4) Eventualmente',
  ];

  static const List<String> vasilhaRefrigeranteOptions = [
    '(1) Uma garrafa de 1 litro',
    '(2) Uma garrafa de 600 ml',
    '(3) Meia taça',
    '(4) Copo comum – 200 ml',
    '(5) Outros',
    '(9) Não sabe / não lembra',
  ];

  static const List<String> outrosAlimentosIntroducaoOptions = [
    '(1) Leite de vaca em pó infantil',
    '(2) Leite de vaca em pó comum',
    '(3) Leite de vaca líquido',
    '(4) Mingau (leite + farinha)',
    '(5) Sucos',
    '(6) Frutas',
    '(7) Sopa de legumes (papa salgada)',
    '(8) Sopa de legumes com carne ou frango',
  ];

  static const List<String> inicioLimpezaBocaOptions = [
    '(1) Antes dos dentes nascerem',
    '(2) Depois que o primeiro dente nasceu',
    '(3) Aos 6 meses',
    '(4) Entre 6 meses e 1 ano',
    '(5) Entre 1 ano e 2 anos de idade',
    '(6) Após 2 anos de idade',
  ];

  static const List<String> quemRealizaHigieneOptions = [
    '(1) A criança sozinha',
    '(2) A mãe',
    '(3) O pai',
    '(4) O avô/avó',
    '(5) Adulto cuidador – babá',
    '(6) O irmão mais velho',
    '(7) A professora da escola',
    '(8) Outros',
  ];

  static const List<String> motivoConsultaCriancaOptions = [
    '(1) Primeira consulta',
    '(2) Traumatismo – caiu e quebrou o dente',
    '(3) Lesões na boca – feridas na boca',
    '(5) Sangramento na gengiva',
    '(6) Cárie dentária: buracos nos dentes',
    '(7) Manchas nos dentes',
    '(8) Dor de dente',
    '(9) Outro',
  ];

  static const List<String> quandoDoeuOptions = [
    '(1) Nesta última semana',
    '(2) Há pouco tempo (semana)',
    '(3) Há muito tempo (meses atrás)',
    '(9) Não lembra / Não sabe',
  ];

  static const List<String> sentiaDorQuandoOptions = [
    '(1) Sempre / toda hora, principalmente à noite',
    '(2) Só quando comia (alimento quente, gelado, duro, doce)',
    '(3) Quando um novo dente estava nascendo na boca',
  ];

  static const List<String> procedimentoRealizadoOptions = [
    '(1) Extraiu o dente',
    '(2) Colocou uma massa no dente (medicação)',
    '(3) Tratou o dente (canal / restauração)',
    '(4) Não fez nada',
  ];

  static const List<String> doencasInfanciaOptions = [
    'Sarampo',
    'Caxumba',
    'Catapora',
    'Difteria',
    'Coqueluche',
    'Diabetes',
    'Bronquite',
    'Anemia',
    'Asma',
    'Visão',
    'Audição',
    'Coração',
    'Pulmões',
    'Pele',
    'Estômago',
    'Intestino',
    'Fígado',
    'Rins',
    'Bexiga',
    'Tireóide',
    'Hormonal',
    'Hemorragia',
    'Rinite alérgica',
    'AIDS-HIV',
    'Outras',
  ];

  static const List<String> outrosHabitosOptions = [
    'Roer unhas',
    'Morder lábios',
    'Morder objetos',
    'Respirar pela boca',
    'Deglutição atípica',
    'Interposição de língua',
    'Ronco Noturno',
  ];

  static const List<String> bruxismoDetalhesOptions = [
    'À noite',
    'Durante o dia',
    'Diariamente',
    'Eventualmente',
    'Outros hábitos',
  ];

  static const List<String> localAtendimentoOptions = [
    '01 - UBS',
    '02 - Unidade Móvel',
    '03 - Rua',
    '04 - Domicílio',
    '05 - Escola/Creche',
    '06 - Outros',
    '07 - Polo (Academia da Saúde)',
    '08 - Instituição/Abrigo',
    '09 - Unidade prisional ou congêneres',
    '10 - Unidade socioeducativa',
  ];

  static const List<Map<String, String>> consumoMenores6Meses = [
    {'key': 'peito', 'label': 'A criança ontem tomou leite do peito?'},
    {'key': 'mingau', 'label': 'Ontem a criança consumiu: Mingau'},
    {'key': 'agua_cha', 'label': 'Ontem a criança consumiu: Água/chá'},
    {'key': 'leite_vaca', 'label': 'Ontem a criança consumiu: Leite de vaca'},
    {'key': 'formula', 'label': 'Ontem a criança consumiu: Fórmula infantil'},
    {'key': 'suco_fruta', 'label': 'Ontem a criança consumiu: Suco de fruta'},
    {'key': 'fruta', 'label': 'Ontem a criança consumiu: Fruta'},
    {'key': 'comida_sal', 'label': 'Ontem a criança consumiu: Comida de sal (de panela, papa ou sopa)'},
    {'key': 'outros', 'label': 'Ontem a criança consumiu: Outros alimentos/bebidas'},
  ];

  static const List<Map<String, String>> consumo6a23MesesItens = [
    {'key': 'outro_leite', 'label': 'Outro leite que não o leite do peito'},
    {'key': 'mingau_leite', 'label': 'Mingau com leite'},
    {'key': 'iogurte', 'label': 'Iogurte'},
    {'key': 'legumes', 'label': 'Legumes (não considerar os utilizados como temperos, nem batata, mandioca/aipim/macaxeira, cará e inhame)'},
    {'key': 'alaranjada_folhas', 'label': 'Vegetal ou fruta de cor alaranjada (abóbora ou jerimum, cenoura, mamão, manga) ou folhas verdes-escuras (couve, caruru, beldroega, bertalha, espinafre, mostarda)'},
    {'key': 'verdura_folha', 'label': 'Verdura de folha (alface, acelga, repolho)'},
    {'key': 'carne_ovo', 'label': 'Carne (boi, frango, peixe, porco, miúdos, outras) ou ovo'},
    {'key': 'figado', 'label': 'Fígado'},
    {'key': 'feijao', 'label': 'Feijão'},
    {'key': 'arroz_batata', 'label': 'Arroz, batata, inhame, aipim/macaxeira/mandioca, farinha ou macarrão (sem ser instantâneo)'},
    {'key': 'hamburguer_embutidos', 'label': 'Hambúrguer e/ou embutidos (presunto, mortadela, salame, linguiça, salsicha)'},
    {'key': 'bebidas_adocadas', 'label': 'Bebidas adoçadas (refrigerante, suco de caixinha, suco em pó, água de coco de caixinha, xaropes de guaraná/groselha, suco de fruta com adição de açúcar)'},
    {'key': 'macarrao_salgadinhos', 'label': 'Macarrão instantâneo, salgadinhos de pacote ou biscoitos salgados'},
    {'key': 'doces_guloseimas', 'label': 'Biscoito recheado, doces ou guloseimas (balas, pirulitos, chiclete, caramelo, gelatina)'},
  ];

  static const List<String> refeicoesDiaOptions = [
    'Café da manhã',
    'Lanche da manhã',
    'Almoço',
    'Lanche da tarde',
    'Jantar',
    'Ceia',
  ];

  static const List<Map<String, String>> consumo2AnosOuMaisItens = [
    {'key': 'feijao', 'label': 'Feijão'},
    {'key': 'frutas_frescas', 'label': 'Frutas frescas (não considerar suco de frutas)'},
    {'key': 'verduras_legumes', 'label': 'Verduras e/ou legumes (não considerar batata, mandioca, aipim, macaxeira, cará e inhame)'},
    {'key': 'hamburguer_embutidos', 'label': 'Hambúrguer e/ou embutidos (presunto, mortadela, salame, linguiça, salsicha)'},
    {'key': 'bebidas_adocadas', 'label': 'Bebidas adoçadas (refrigerante, suco de caixinha, suco em pó, água de coco de caixinha, xaropes de guaraná/groselha, suco de fruta com adição de açúcar)'},
    {'key': 'macarrao_salgadinhos', 'label': 'Macarrão instantâneo, salgadinhos de pacote ou biscoitos salgados'},
    {'key': 'doces_guloseimas', 'label': 'Biscoito recheado, doces ou guloseimas (balas, pirulitos, chiclete, caramelo, gelatina)'},
  ];

  /// Dentes das tabelas IPV e ISG (Página 9 — inclui 18, 28, 38, 48).
  static const Map<String, List<ToothPairSpec>> ipvIsgQuadrants = {
    'Q1 — Superior Direito (18–11 / 55–51)': [
      ToothPairSpec(key: '18', permanent: '18'),
      ToothPairSpec(key: '17', permanent: '17'),
      ToothPairSpec(key: '16', permanent: '16'),
      ToothPairSpec(key: '15_55', permanent: '15', deciduous: '55'),
      ToothPairSpec(key: '14_54', permanent: '14', deciduous: '54'),
      ToothPairSpec(key: '13_53', permanent: '13', deciduous: '53', hasOcclusal: false),
      ToothPairSpec(key: '12_52', permanent: '12', deciduous: '52', hasOcclusal: false),
      ToothPairSpec(key: '11_51', permanent: '11', deciduous: '51', hasOcclusal: false),
    ],
    'Q2 — Superior Esquerdo (21–28 / 61–65)': [
      ToothPairSpec(key: '21_61', permanent: '21', deciduous: '61', hasOcclusal: false),
      ToothPairSpec(key: '22_62', permanent: '22', deciduous: '62', hasOcclusal: false),
      ToothPairSpec(key: '23_63', permanent: '23', deciduous: '63', hasOcclusal: false),
      ToothPairSpec(key: '24_64', permanent: '24', deciduous: '64'),
      ToothPairSpec(key: '25_65', permanent: '25', deciduous: '65'),
      ToothPairSpec(key: '26', permanent: '26'),
      ToothPairSpec(key: '27', permanent: '27'),
      ToothPairSpec(key: '28', permanent: '28'),
    ],
    'Q3 — Inferior Esquerdo (38–31 / 75–71)': [
      ToothPairSpec(key: '38', permanent: '38'),
      ToothPairSpec(key: '37', permanent: '37'),
      ToothPairSpec(key: '36', permanent: '36'),
      ToothPairSpec(key: '35_75', permanent: '35', deciduous: '75'),
      ToothPairSpec(key: '34_74', permanent: '34', deciduous: '74'),
      ToothPairSpec(key: '33_73', permanent: '33', deciduous: '73', hasOcclusal: false),
      ToothPairSpec(key: '32_72', permanent: '32', deciduous: '72', hasOcclusal: false),
      ToothPairSpec(key: '31_71', permanent: '31', deciduous: '71', hasOcclusal: false),
    ],
    'Q4 — Inferior Direito (41–48 / 81–85)': [
      ToothPairSpec(key: '41_81', permanent: '41', deciduous: '81', hasOcclusal: false),
      ToothPairSpec(key: '42_82', permanent: '42', deciduous: '82', hasOcclusal: false),
      ToothPairSpec(key: '43_83', permanent: '43', deciduous: '83', hasOcclusal: false),
      ToothPairSpec(key: '44_84', permanent: '44', deciduous: '84'),
      ToothPairSpec(key: '45_85', permanent: '45', deciduous: '85'),
      ToothPairSpec(key: '46', permanent: '46'),
      ToothPairSpec(key: '47', permanent: '47'),
      ToothPairSpec(key: '48', permanent: '48'),
    ],
  };

  /// Dentes das tabelas Exame Clínico, Exame Radiográfico e Procedimentos Invasivos (Páginas 10 e 14 — 17..47).
  static const Map<String, List<ToothPairSpec>> clinicalQuadrants = {
    'Q1 — Superior Direito (17–11 / 55–51)': [
      ToothPairSpec(key: '17', permanent: '17'),
      ToothPairSpec(key: '16', permanent: '16'),
      ToothPairSpec(key: '15_55', permanent: '15', deciduous: '55'),
      ToothPairSpec(key: '14_54', permanent: '14', deciduous: '54'),
      ToothPairSpec(key: '13_53', permanent: '13', deciduous: '53'),
      ToothPairSpec(key: '12_52', permanent: '12', deciduous: '52'),
      ToothPairSpec(key: '11_51', permanent: '11', deciduous: '51'),
    ],
    'Q2 — Superior Esquerdo (21–27 / 61–65)': [
      ToothPairSpec(key: '21_61', permanent: '21', deciduous: '61'),
      ToothPairSpec(key: '22_62', permanent: '22', deciduous: '62'),
      ToothPairSpec(key: '23_63', permanent: '23', deciduous: '63'),
      ToothPairSpec(key: '24_64', permanent: '24', deciduous: '64'),
      ToothPairSpec(key: '25_65', permanent: '25', deciduous: '65'),
      ToothPairSpec(key: '26', permanent: '26'),
      ToothPairSpec(key: '27', permanent: '27'),
    ],
    'Q3 — Inferior Esquerdo (37–31 / 75–71)': [
      ToothPairSpec(key: '37', permanent: '37'),
      ToothPairSpec(key: '36', permanent: '36'),
      ToothPairSpec(key: '35_75', permanent: '35', deciduous: '75'),
      ToothPairSpec(key: '34_74', permanent: '34', deciduous: '74'),
      ToothPairSpec(key: '33_73', permanent: '33', deciduous: '73'),
      ToothPairSpec(key: '32_72', permanent: '32', deciduous: '72'),
      ToothPairSpec(key: '31_71', permanent: '31', deciduous: '71'),
    ],
    'Q4 — Inferior Direito (41–47 / 81–85)': [
      ToothPairSpec(key: '41_81', permanent: '41', deciduous: '81'),
      ToothPairSpec(key: '42_82', permanent: '42', deciduous: '82'),
      ToothPairSpec(key: '43_83', permanent: '43', deciduous: '83'),
      ToothPairSpec(key: '44_84', permanent: '44', deciduous: '84'),
      ToothPairSpec(key: '45_85', permanent: '45', deciduous: '85'),
      ToothPairSpec(key: '46', permanent: '46'),
      ToothPairSpec(key: '47', permanent: '47'),
    ],
  };

  static const List<String> exameClinicoCodigos = [
    '0 - Superfície hígida',
    '1 - Mancha Branca Ativa',
    '2 - Mancha Branca Inativa',
    '3 - Cavidade Ativa',
    '4 - Cavidade Inativa',
    '5 - Restauração',
    '6 - Restauração Defeituosa',
    '7 - Restauração Fraturada',
    '8 - Recidiva de lesão de cárie',
    '9 - Destruição Coronária',
    '10 - Fístula',
  ];

  static const List<String> exameRxCodigos = [
    '0 - Ausente',
    '1 - Metade ext. de esmalte',
    '2 - Metade int. de esmalte',
    '3 - Metade ext. de dentina',
    '4 - Metade int. de dentina',
    '5 - Comunicação pulpar',
    '6 - Rarefação apical/furca',
    '7 - Rarefação crista óssea',
  ];

  static const List<String> perfilCarieOptions = [
    'Livre de Cárie — Sem fatores etiológicos',
    'Livre de Cárie — Com fatores etiológicos',
    'Com experiência de Cárie — Sem atividade',
    'Com experiência de Cárie — Com atividade',
    'Com experiência de Cárie — Sem necessidades invasivas',
    'Com experiência de Cárie — Com necessidades invasivas',
  ];

  static const List<String> classificacaoDenticaoOptions = [
    'Dentição decídua',
    '1º período transitório da dentadura mista / irrupção dos primeiros molares permanentes',
    'Período inter-transitório da dentadura mista / troca dos caninos decíduos',
    '2º período transitório da dentadura mista / troca dos molares decíduos',
    'Dentadura permanente / irrupção dos segundos molares permanentes',
  ];

  static const List<Map<String, String>> examesComplementares = [
    {'key': 'panoramica', 'label': '(1) Radiografias Panorâmicas'},
    {'key': 'periapical', 'label': '(2) Radiografias Periapicais'},
    {'key': 'oclusal', 'label': '(3) Radiografias Oclusais'},
    {'key': 'interproximal', 'label': '(4) Radiografias Interproximais'},
    {'key': 'laboratorial', 'label': '(5) Exames Laboratoriais'},
    {'key': 'modelo_estudo', 'label': '(6) Modelo de Estudo'},
    {'key': 'fotografia', 'label': '(7) Fotografia'},
  ];

  static const String termoAutorizacaoTexto =
      'Autorizo as Disciplinas de Odontopediatria e Clínica Integrada Infantil do Departamento de Odontologia II da Universidade Federal do Maranhão (UFMA) a realizarem os exames clínicos, radiográficos, modelos de estudo, documentação fotográfica e os tratamentos clínicos preventivos, curativos e/ou cirúrgicos necessários, inclusive sob anestesia local, no paciente acima identificado. Comprometo-me a cumprir as normas da sala clínica, comparecer rigorosamente às consultas agendadas e comunicar previamente eventuais impedimentos.';
}

/// Modelo estruturado da Ficha Clínica de Odontopediatria (10 tópicos / 14 páginas).
class OdontopediatriaModel {
  final Map<String, dynamic> data;

  OdontopediatriaModel([Map<String, dynamic>? initial])
      : data = initial != null ? _deepCopyMap(initial) : <String, dynamic>{};

  static Map<String, dynamic> _deepCopyMap(Map<String, dynamic> source) {
    final out = <String, dynamic>{};
    source.forEach((k, v) {
      if (v is Map) {
        out[k] = _deepCopyMap(Map<String, dynamic>.from(v));
      } else if (v is List) {
        out[k] = v.map((item) => item is Map ? _deepCopyMap(Map<String, dynamic>.from(item)) : item).toList();
      } else {
        out[k] = v;
      }
    });
    return out;
  }

  factory OdontopediatriaModel.fromMap(Map<String, dynamic>? map) =>
      OdontopediatriaModel(map);

  Map<String, dynamic> toMap() => _deepCopyMap(data);

  String getString(String key) => (data[key] ?? '').toString();

  void setString(String key, String value) {
    if (value.isEmpty) {
      data.remove(key);
    } else {
      data[key] = value;
    }
  }

  bool getBool(String key) => data[key] == true;

  void setBool(String key, bool value) {
    if (!value) {
      data.remove(key);
    } else {
      data[key] = true;
    }
  }

  List<String> getStringList(String key) {
    final raw = data[key];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  void toggleInList(String key, String value) {
    final list = getStringList(key);
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }
    if (list.isEmpty) {
      data.remove(key);
    } else {
      data[key] = list;
    }
  }

  String getGridCell(String gridKey, String toothKey, String surface) {
    final grid = data[gridKey];
    if (grid is Map) {
      final tooth = grid[toothKey];
      if (tooth is Map) {
        return (tooth[surface] ?? '').toString();
      }
    }
    return '';
  }

  void setGridCell(String gridKey, String toothKey, String surface, String value) {
    final grid = data[gridKey] is Map
        ? Map<String, dynamic>.from(data[gridKey] as Map)
        : <String, dynamic>{};
    final tooth = grid[toothKey] is Map
        ? Map<String, dynamic>.from(grid[toothKey] as Map)
        : <String, dynamic>{};
    if (value.isEmpty) {
      tooth.remove(surface);
    } else {
      tooth[surface] = value;
    }
    if (tooth.isEmpty) {
      grid.remove(toothKey);
    } else {
      grid[toothKey] = tooth;
    }
    if (grid.isEmpty) {
      data.remove(gridKey);
    } else {
      data[gridKey] = grid;
    }
  }

  /// Calcula automaticamente o percentual de superfícies com valor '1' (placa/sangramento)
  /// sobre o total de superfícies avaliadas ('0' ou '1').
  double? computeBinaryIndexPercent(String gridKey) {
    final grid = data[gridKey];
    if (grid is! Map) return null;
    int total = 0;
    int positive = 0;
    for (final toothEntry in grid.values) {
      if (toothEntry is Map) {
        for (final val in toothEntry.values) {
          final s = val.toString().trim();
          if (s == '0' || s == '1') {
            total++;
            if (s == '1') positive++;
          }
        }
      }
    }
    if (total == 0) return null;
    return (positive / total) * 100.0;
  }

  /// Conta quantas chaves preenchidas pertencem a um prefixo de tópico.
  int countFilledByPrefix(String prefix) {
    int count = 0;
    data.forEach((k, v) {
      if (!k.startsWith(prefix)) return;
      if (v is String && v.trim().isNotEmpty) {
        count++;
      } else if (v is bool && v) {
        count++;
      } else if (v is List && v.isNotEmpty) {
        count++;
      } else if (v is Map && v.isNotEmpty) {
        count++;
      }
    });
    return count;
  }
}
