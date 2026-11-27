import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/services/prontuario_pdf_service.dart';
import '../../domain/entities/odontopediatria_data.dart';
import '../viewmodels/endodontia_viewmodel.dart';
import '../viewmodels/prontuario_summary_provider.dart';
import '../widgets/odontopediatria_form_widgets.dart';
import '../widgets/sheet_history_dialog.dart';

part 'odontopediatria_topics_1_5.dart';
part 'odontopediatria_topics_6_10.dart';

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
            icon: const Icon(Icons.history),
            tooltip: 'Histórico de Versões',
            onPressed: () => showSheetHistoryDialog(
              context: context,
              ref: ref,
              patientId: widget.patientId,
              sheetType: 'odontopediatria',
              sheetTitle: 'Odontopediatria',
            ),
          ),
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


  void _updateState(VoidCallback fn) => setState(fn);
}
