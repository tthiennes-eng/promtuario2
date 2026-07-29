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
      error: (err, stack) => Center(child: Text('Erro: ${err.toString()}')),
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
          const Text('Arcada Superior', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 16),
          _buildQuadrantRow(context, ref, [18, 17, 16, 15, 14, 13, 12, 11], [21, 22, 23, 24, 25, 26, 27, 28], odontogram),
          const Divider(height: 64, thickness: 2),
          _buildQuadrantRow(context, ref, [48, 47, 46, 45, 44, 43, 42, 41], [31, 32, 33, 34, 35, 36, 37, 38], odontogram),
          const SizedBox(height: 16),
          const Text('Arcada Inferior', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 48),
          _buildLegend(context),
        ],
      ),
    );
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
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: ConditionType.values.map((type) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: _getConditionColor(type), border: Border.all(color: Colors.grey))),
            const SizedBox(width: 4),
            Text(_getConditionLabel(type), style: const TextStyle(fontSize: 10)),
          ],
        );
      }).toList(),
    );
  }

  static Color _getConditionColor(ConditionType type) {
    return switch (type) {
      ConditionType.healthy => Colors.white,
      ConditionType.decayed => Colors.red,
      ConditionType.restored => Colors.blue,
      ConditionType.missing => Colors.grey.shade400,
      ConditionType.implant => Colors.purple,
      ConditionType.endodontic => Colors.orange,
      ConditionType.prosthesis => Colors.amber,
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

  const _ToothTile({required this.number, required this.toothConditions, required this.ref, required this.patientId, required this.getSurfaceLabel, required this.getConditionLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(number.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        GestureDetector(
          onTapDown: (details) => _handleTap(context, details.localPosition),
          child: CustomPaint(
            size: const Size(36, 36),
            painter: ToothPainter(conditions: toothConditions),
          ),
        ),
      ],
    );
  }

  void _handleTap(BuildContext context, Offset localPosition) {
    const size = 36.0;
    const padding = size * 0.2;
    ToothSurface? selectedSurface;

    if (localPosition.dx > padding && localPosition.dx < size - padding &&
        localPosition.dy > padding && localPosition.dy < size - padding) {
      selectedSurface = ToothSurface.occlusal;
    } else if (localPosition.dy < padding) {
      selectedSurface = ToothSurface.buccal;
    } else if (localPosition.dy > size - padding) {
      selectedSurface = ToothSurface.lingual;
    } else {
      int quadrant = number ~/ 10;
      bool mesialIsLeft = (quadrant == 2 || quadrant == 3);
      if (localPosition.dx < padding) {
        selectedSurface = mesialIsLeft ? ToothSurface.mesial : ToothSurface.distal;
      } else {
        selectedSurface = mesialIsLeft ? ToothSurface.distal : ToothSurface.mesial;
      }
    }

    if (selectedSurface != null) {
      _showFaceEditor(context, selectedSurface);
    }
  }

  void _showFaceEditor(BuildContext context, ToothSurface surface) {
    final existing = toothConditions.firstWhere(
      (c) => c.surfaces.contains(surface),
      orElse: () => ToothCondition(toothNumber: number, surfaces: [surface], condition: ConditionType.healthy),
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => _FaceActionSheet(
        toothNumber: number,
        surface: surface,
        condition: existing,
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
    final borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1;
    final padding = size.width * 0.2;

    _drawFace(canvas, [Offset(padding, padding), Offset(size.width - padding, padding), Offset(size.width - padding, size.height - padding), Offset(padding, size.height - padding)], ToothSurface.occlusal, borderPaint);
    _drawFace(canvas, [const Offset(0, 0), Offset(size.width, 0), Offset(size.width - padding, padding), Offset(padding, padding)], ToothSurface.buccal, borderPaint);
    _drawFace(canvas, [Offset(padding, size.height - padding), Offset(size.width - padding, size.height - padding), Offset(size.width, size.height), Offset(0, size.height)], ToothSurface.lingual, borderPaint);
    _drawFace(canvas, [const Offset(0, 0), Offset(padding, padding), Offset(padding, size.height - padding), Offset(0, size.height)], ToothSurface.mesial, borderPaint);
    _drawFace(canvas, [Offset(size.width - padding, padding), Offset(size.width, 0), Offset(size.width, size.height), Offset(size.width - padding, size.height - padding)], ToothSurface.distal, borderPaint);
  }

  void _drawFace(Canvas canvas, List<Offset> points, ToothSurface surface, Paint borderPaint) {
    final path = Path()..addPolygon(points, true);
    final color = _getSurfaceColor(surface);
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawPath(path, borderPaint);
  }

  Color _getSurfaceColor(ToothSurface surface) {
    try {
      final c = conditions.firstWhere((c) => c.surfaces.contains(surface));
      return OdontogramWidget._getConditionColor(c.condition);
    } catch (_) { return Colors.white; }
  }

  @override bool shouldRepaint(CustomPainter old) => true;
}

class _FaceActionSheet extends StatefulWidget {
  final int toothNumber;
  final ToothSurface surface;
  final ToothCondition condition;
  final String Function(ToothSurface) getSurfaceLabel;
  final String Function(ConditionType) getConditionLabel;
  final Function(ToothCondition) onSave;

  const _FaceActionSheet({required this.toothNumber, required this.surface, required this.condition, required this.onSave, required this.getSurfaceLabel, required this.getConditionLabel});

  @override
  State<_FaceActionSheet> createState() => _FaceActionSheetState();
}

class _FaceActionSheetState extends State<_FaceActionSheet> {
  late ConditionType _type;
  final _obs = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.condition.condition;
    _obs.text = widget.condition.observation ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Dente ${widget.toothNumber} - Face ${widget.getSurfaceLabel(widget.surface)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          DropdownButtonFormField<ConditionType>(
            value: _type,
            items: ConditionType.values.map((t) => DropdownMenuItem(value: t, child: Text(widget.getConditionLabel(t)))).toList(),
            onChanged: (v) => setState(() => _type = v!),
            decoration: const InputDecoration(labelText: 'Condição Clínca'),
          ),
          const SizedBox(height: 16),
          TextField(controller: _obs, decoration: const InputDecoration(labelText: 'Observação (Opcional)')),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () => widget.onSave(widget.condition.copyWith(condition: _type, observation: _obs.text)), child: const Text('Salvar Alteração'))),
        ],
      ),
    );
  }
}
