import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/prontuario_viewmodel.dart';
import '../../domain/entities/odontogram.dart';

class OdontogramWidget extends ConsumerWidget {
  final String patientId;

  const OdontogramWidget({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final odontogramAsync = ref.watch(prontuarioViewModelProvider(patientId));

    return odontogramAsync.when(
      data: (odontogram) => _buildOdontogramView(context, ref, odontogram),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erro ao carregar odontograma: $err')),
    );
  }

  String _getConditionLabel(ConditionType type) {
    return switch (type) {
      ConditionType.healthy => 'Saudável',
      ConditionType.decayed => 'Cárie',
      ConditionType.restored => 'Restaurado',
      ConditionType.missing => 'Ausente',
      ConditionType.implant => 'Implante',
      ConditionType.endodontic => 'Endodontia',
      ConditionType.prosthesis => 'Prótese',
    };
  }

  String _getSurfaceLabel(ToothSurface surface) {
    return switch (surface) {
      ToothSurface.mesial => 'Mesial',
      ToothSurface.distal => 'Distal',
      ToothSurface.occlusal => 'Oclusal',
      ToothSurface.buccal => 'Vestibular',
      ToothSurface.lingual => 'Lingual',
      ToothSurface.palatal => 'Palatina',
      ToothSurface.root => 'Radicular',
    };
  }

  Widget _buildOdontogramView(BuildContext context, WidgetRef ref, Odontogram? odontogram) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildArcadeLabel('Arcada Superior'),
          const SizedBox(height: 16),
          _buildQuadrantRow(context, ref, [18, 17, 16, 15, 14, 13, 12, 11], [21, 22, 23, 24, 25, 26, 27, 28], odontogram),
          const Divider(height: 64, thickness: 2),
          _buildQuadrantRow(context, ref, [48, 47, 46, 45, 44, 43, 42, 41], [31, 32, 33, 34, 35, 36, 37, 38], odontogram),
          const SizedBox(height: 16),
          _buildArcadeLabel('Arcada Inferior'),
          const SizedBox(height: 48),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildArcadeLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.blueGrey));
  }

  Widget _buildQuadrantRow(BuildContext context, WidgetRef ref, List<int> left, List<int> right, Odontogram? odontogram) {
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...left.map((n) => _ToothTile(number: n, toothConditions: _getConditionsForTooth(odontogram, n), ref: ref, patientId: patientId, getSurfaceLabel: _getSurfaceLabel, getConditionLabel: _getConditionLabel)),
          const SizedBox(width: 32),
          ...right.map((n) => _ToothTile(number: n, toothConditions: _getConditionsForTooth(odontogram, n), ref: ref, patientId: patientId, getSurfaceLabel: _getSurfaceLabel, getConditionLabel: _getConditionLabel)),
        ],
      ),
    );
  }

  List<ToothCondition> _getConditionsForTooth(Odontogram? odontogram, int number) {
    return odontogram?.teeth.where((t) => t.toothNumber == number).toList() ?? [];
  }

  Widget _buildLegend(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 24,
          runSpacing: 12,
          children: ConditionType.values.map((type) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _getConditionColor(type),
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text(_getConditionLabel(type).toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  static Color _getConditionColor(ConditionType type) {
    return switch (type) {
      ConditionType.healthy => Colors.white,
      ConditionType.decayed => Colors.red.shade600,
      ConditionType.restored => Colors.blue.shade600,
      ConditionType.missing => Colors.grey.shade300,
      ConditionType.implant => Colors.deepPurple.shade400,
      ConditionType.endodontic => Colors.orange.shade600,
      ConditionType.prosthesis => Colors.amber.shade600,
    };
  }
}

class _ToothTile extends StatelessWidget {
  final int number;
  final List<ToothCondition> toothConditions;
  final WidgetRef ref;
  final String patientId;
  final String Function(ToothSurface) getSurfaceLabel;
  final String Function(ConditionType) getConditionLabel;

  const _ToothTile({
    required this.number, 
    required this.toothConditions, 
    required this.ref, 
    required this.patientId, 
    required this.getSurfaceLabel, 
    required this.getConditionLabel
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(number.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          GestureDetector(
            onTapDown: (details) => _handleTap(context, details.localPosition),
            child: CustomPaint(
              size: const Size(40, 40),
              painter: ToothPainter(conditions: toothConditions),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, Offset localPosition) {
    const size = 40.0;
    const padding = size * 0.15;
    
    ToothSurface? selectedSurface;
    
    // Identifica qual face foi clicada baseando-se na posição
    if (localPosition.dx > padding && localPosition.dx < size - padding &&
        localPosition.dy > padding && localPosition.dy < size - padding) {
      selectedSurface = ToothSurface.occlusal;
    } else if (localPosition.dy < padding) {
      selectedSurface = ToothSurface.buccal;
    } else if (localPosition.dy > size - padding) {
      selectedSurface = ToothSurface.lingual;
    } else if (localPosition.dx < padding) {
      selectedSurface = ToothSurface.mesial;
    } else if (localPosition.dx > size - padding) {
      selectedSurface = ToothSurface.distal;
    }

    if (selectedSurface != null) {
      _showFaceEditor(context, selectedSurface);
    }
  }

  void _showFaceEditor(BuildContext context, ToothSurface surface) {
    // Busca a condição atual dessa face específica
    final existingCondition = toothConditions.firstWhere(
      (c) => c.surfaces.contains(surface),
      orElse: () => ToothCondition(toothNumber: number, surfaces: [surface], condition: ConditionType.healthy),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ToothActionSheet(
        toothNumber: number,
        surface: surface,
        condition: existingCondition,
        getSurfaceLabel: getSurfaceLabel,
        getConditionLabel: getConditionLabel,
        onSave: (updated) {
          ref.read(prontuarioViewModelProvider(patientId).notifier).updateToothCondition(updated);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class ToothPainter extends CustomPainter {
  final List<ToothCondition> conditions;
  ToothPainter({required this.conditions});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final padding = size.width * 0.15;
    
    // Desenha cada face com sua respectiva cor de condição
    _drawPolygon(canvas, [
      Offset(padding, padding),
      Offset(size.width - padding, padding),
      Offset(size.width - padding, size.height - padding),
      Offset(padding, size.height - padding),
    ], _getSurfaceColor(ToothSurface.occlusal), borderPaint);

    _drawPolygon(canvas, [
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(size.width - padding, padding),
      Offset(padding, padding),
    ], _getSurfaceColor(ToothSurface.buccal), borderPaint);

    _drawPolygon(canvas, [
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ], _getSurfaceColor(ToothSurface.lingual), borderPaint);

    _drawPolygon(canvas, [
      const Offset(0, 0),
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      Offset(0, size.height),
    ], _getSurfaceColor(ToothSurface.mesial), borderPaint);

    _drawPolygon(canvas, [
      Offset(size.width - padding, padding),
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(size.width - padding, size.height - padding),
    ], _getSurfaceColor(ToothSurface.distal), borderPaint);

    // Verifica se o dente está ausente ou tem implante (afeta o dente todo)
    final toothWideCondition = conditions.any((c) => c.condition == ConditionType.missing || c.condition == ConditionType.implant);
    if (toothWideCondition) {
       _drawX(canvas, size);
    }
  }

  void _drawPolygon(Canvas canvas, List<Offset> points, Color color, Paint borderPaint) {
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawPath(path, borderPaint);
  }

  void _drawX(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red.withOpacity(0.5)..strokeWidth = 3;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  Color _getSurfaceColor(ToothSurface surface) {
    try {
      final condition = conditions.firstWhere((c) => c.surfaces.contains(surface));
      return OdontogramWidget._getConditionColor(condition.condition);
    } catch (_) {
      return Colors.white;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ToothActionSheet extends StatefulWidget {
  final int toothNumber;
  final ToothSurface surface;
  final ToothCondition condition;
  final String Function(ToothSurface) getSurfaceLabel;
  final String Function(ConditionType) getConditionLabel;
  final Function(ToothCondition) onSave;

  const _ToothActionSheet({
    required this.toothNumber, 
    required this.surface,
    required this.condition, 
    required this.onSave, 
    required this.getSurfaceLabel, 
    required this.getConditionLabel
  });

  @override
  State<_ToothActionSheet> createState() => _ToothActionSheetState();
}

class _ToothActionSheetState extends State<_ToothActionSheet> {
  late ConditionType _selectedType;
  final _obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.condition.condition;
    _obsController.text = widget.condition.observation ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dente ${widget.toothNumber} - Face ${widget.getSurfaceLabel(widget.surface)}', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Estado Clínico desta Face', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<ConditionType>(
            isExpanded: true,
            value: _selectedType,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: ConditionType.values.map((type) => DropdownMenuItem(
              value: type, 
              child: Text(widget.getConditionLabel(type).toUpperCase())
            )).toList(),
            onChanged: (val) => setState(() => _selectedType = val!),
          ),
          const SizedBox(height: 24),
          const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _obsController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Detalhes específicos para esta face...', 
              border: OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () => widget.onSave(widget.condition.copyWith(
                condition: _selectedType,
                observation: _obsController.text,
              )),
              child: const Text('Salvar Alteração na Face'),
            ),
          ),
        ],
      ),
    );
  }
}
