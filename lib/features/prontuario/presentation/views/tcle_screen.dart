import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:promt/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:promt/features/prontuario/data/services/prontuario_pdf_service.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/endodontia_viewmodel.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/prontuario_summary_provider.dart';

class TcleScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const TcleScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  ConsumerState<TcleScreen> createState() => _TcleScreenState();
}

class _TcleScreenState extends ConsumerState<TcleScreen> {
  static const String _defaultTerm =
      'Declaro que fui devidamente informado(a), de forma clara e compreensível, sobre o diagnóstico, '
      'as alternativas de tratamento odontológico, os benefícios esperados, os possíveis riscos e intercorrências '
      'inerentes aos procedimentos a serem realizados na Clínica Escola Odontológica Universitária.\n\n'
      'Autorizo a realização dos procedimentos acordados no Plano de Tratamento, bem como o registro de dados '
      'clínicos, exames radiográficos e fotografias intra e extraorais para fins exclusivamente assistenciais, '
      'acadêmicos e de auditoria, em conformidade com a Lei Geral de Proteção de Dados (LGPD - Lei nº 13.709/2018).';

  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _accepted = false;
  String? _acceptedAt;
  bool _isSaving = false;
  bool _loadedInitial = false;
  final _termController = TextEditingController(text: _defaultTerm);

  String get _storageKey => 'tcle_${widget.patientId}';

  @override
  void dispose() {
    _termController.dispose();
    super.dispose();
  }

  void _hydrateFromData(Map<String, dynamic>? data) {
    if (_loadedInitial || data == null) return;
    _loadedInitial = true;
    _accepted = data['accepted'] == true;
    _acceptedAt = data['acceptedAt']?.toString();
    final savedText = data['termText']?.toString();
    if (savedText != null && savedText.trim().isNotEmpty) {
      _termController.text = savedText;
    }
    final rawStrokes = data['strokes'];
    if (rawStrokes is List) {
      _strokes.clear();
      for (final stroke in rawStrokes) {
        if (stroke is List) {
          final pts = <Offset>[];
          for (final pt in stroke) {
            if (pt is Map && pt['x'] is num && pt['y'] is num) {
              pts.add(Offset((pt['x'] as num).toDouble(), (pt['y'] as num).toDouble()));
            }
          }
          if (pts.isNotEmpty) _strokes.add(pts);
        }
      }
    }
  }

  Map<String, dynamic> _buildPayload() {
    final user = ref.read(authViewModelProvider).user;
    final nowFormatted = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    return {
      'accepted': _accepted,
      'acceptedAt': _accepted ? (_acceptedAt ?? nowFormatted) : null,
      'termText': _termController.text.trim(),
      'professionalName': user?.name ?? 'Profissional Responsável',
      'strokes': _strokes
          .map((stroke) => stroke.map((p) => {'x': p.dx, 'y': p.dy}).toList())
          .toList(),
    };
  }

  Future<void> _save() async {
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marque a confirmação de ciência e consentimento antes de salvar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _isSaving = true;
      _acceptedAt = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    });
    try {
      final payload = _buildPayload();
      await ref.read(endodontiaViewModelProvider(_storageKey).notifier).save(payload);
      ref.invalidate(prontuarioSummaryProvider(widget.patientId));
      ref.invalidate(clinicalTimelineProvider(widget.patientId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Termo de Consentimento (TCLE) registrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar TCLE: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _exportPdf() async {
    try {
      final file = await ProntuarioPdfService.generateTclePdf(
        patientName: widget.patientName,
        tcleData: _buildPayload(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF salvo em: ${file.path}'),
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

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(endodontiaViewModelProvider(_storageKey));
    asyncData.whenData(_hydrateFromData);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TCLE / Consentimento (LGPD)'),
            Text(widget.patientName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar TCLE em PDF',
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: asyncData.isLoading && !_loadedInitial
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_accepted && _acceptedAt != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified_outlined, color: Colors.green.shade800),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Consentimento registrado em $_acceptedAt',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Texto do Termo de Consentimento',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _termController,
                            maxLines: 8,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            value: _accepted,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text(
                              'Li, compreendi e concordo com os termos acima e com o tratamento de dados (LGPD).',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            onChanged: (v) => setState(() => _accepted = v ?? false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Assinatura / Rubrica do Paciente ou Responsável',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => setState(() => _strokes.clear()),
                                icon: const Icon(Icons.clear, size: 16),
                                label: const Text('Limpar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: GestureDetector(
                              onPanStart: (details) {
                                setState(() {
                                  _currentStroke = [details.localPosition];
                                  _strokes.add(_currentStroke);
                                });
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  _currentStroke.add(details.localPosition);
                                });
                              },
                              onPanEnd: (_) => _currentStroke = [],
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: _SignaturePainter(_strokes),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('Registrar Consentimento (TCLE)'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF006494),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
