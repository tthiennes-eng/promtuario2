import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../viewmodels/prontuario_viewmodel.dart';
import '../viewmodels/treatment_plan_viewmodel.dart';
import '../../domain/entities/odontogram.dart';
import '../../domain/entities/treatment_plan.dart';

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
      ConditionType.healthy => 'Hígido',
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
      ToothSurface.occlusal => 'Oclusal/Incisal',
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
          const Text('Arcada Superior', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
          const SizedBox(height: 24),
          _buildQuadrantRow(context, ref, [18, 17, 16, 15, 14, 13, 12, 11], [21, 22, 23, 24, 25, 26, 27, 28], odontogram),
          const SizedBox(height: 32),
          const Divider(height: 1, thickness: 1, color: Colors.grey),
          const SizedBox(height: 32),
          _buildQuadrantRow(context, ref, [48, 47, 46, 45, 44, 43, 42, 41], [31, 32, 33, 34, 35, 36, 37, 38], odontogram),
          const SizedBox(height: 24),
          const Text('Arcada Inferior', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
          const SizedBox(height: 48),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildQuadrantRow(BuildContext context, WidgetRef ref, List<int> left, List<int> right, Odontogram? odontogram) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...left.map((n) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: _ToothTile(number: n, toothConditions: _getConditionsForTooth(odontogram, n), ref: ref, patientId: patientId, getSurfaceLabel: _getSurfaceLabel, getConditionLabel: _getConditionLabel),
        )),
        const SizedBox(width: 56),
        ...right.map((n) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: _ToothTile(number: n, toothConditions: _getConditionsForTooth(odontogram, n), ref: ref, patientId: patientId, getSurfaceLabel: _getSurfaceLabel, getConditionLabel: _getConditionLabel),
        )),
      ],
    );
  }

  List<ToothCondition> _getConditionsForTooth(Odontogram? odontogram, int number) {
    return odontogram?.teeth.where((t) => t.toothNumber == number).toList() ?? [];
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: ConditionType.values.map((type) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 14, height: 14, decoration: BoxDecoration(color: _getConditionColor(type), border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(_getConditionLabel(type), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          );
        }).toList(),
      ),
    );
  }

  static Color _getConditionColor(ConditionType type) {
    return switch (type) {
      ConditionType.healthy => Colors.white,
      ConditionType.decayed => Colors.red.shade600,
      ConditionType.restored => Colors.blue.shade600,
      ConditionType.missing => Colors.grey.shade400,
      ConditionType.implant => Colors.purple.shade600,
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

  const _ToothTile({required this.number, required this.toothConditions, required this.ref, required this.patientId, required this.getSurfaceLabel, required this.getConditionLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(number.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        GestureDetector(
          onTapDown: (details) => _handleTap(context, details.localPosition),
          child: CustomPaint(
            size: const Size(42, 42),
            painter: ToothPainter(conditions: toothConditions, toothNumber: number),
          ),
        ),
      ],
    );
  }

  void _handleTap(BuildContext context, Offset localPosition) {
    const size = 42.0;
    const padding = size * 0.25;
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
      bool isRightSide = (quadrant == 1 || quadrant == 4);
      if (localPosition.dx < padding) {
        selectedSurface = isRightSide ? ToothSurface.distal : ToothSurface.mesial;
      } else if (localPosition.dx > size - padding) {
        selectedSurface = isRightSide ? ToothSurface.mesial : ToothSurface.distal;
      }
    }

    if (selectedSurface != null) {
      _showFaceEditor(context, selectedSurface);
    }
  }

  void _showFaceEditor(BuildContext context, ToothSurface surface) {
    final existing = toothConditions.firstWhere(
      (c) => c.surfaces.contains(surface),
      orElse: () => ToothCondition(
        toothNumber: number,
        surfaces: [surface],
        condition: ConditionType.healthy,
      ),
    );

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) => _FaceActionSheet(
        toothNumber: number,
        surface: surface,
        condition: existing,
        getSurfaceLabel: getSurfaceLabel,
        getConditionLabel: getConditionLabel,
        onSave: (updated, addToPlan) async {
          await ref.read(prontuarioViewModelProvider(patientId).notifier).updateToothCondition(updated);
          if (addToPlan && updated.condition != ConditionType.healthy) {
            final procName = switch (updated.condition) {
              ConditionType.decayed => 'Restauração de Resina',
              ConditionType.endodontic => 'Tratamento Endodôntico (Canal)',
              ConditionType.prosthesis => 'Prótese Parcial Removível (PPR)',
              ConditionType.implant => 'Avaliação de Implante',
              ConditionType.missing => 'Reabilitação Protética',
              ConditionType.restored => 'Revisão de Restauração',
              ConditionType.healthy => 'Avaliação Clínica',
            };
            final item = TreatmentItem(
              id: const Uuid().v4(),
              procedureId: const Uuid().v4(),
              procedureName: procName,
              toothNumber: updated.toothNumber,
              observation:
                  'Origem: Odontograma (${getConditionLabel(updated.condition)} - Face ${getSurfaceLabel(surface)})${updated.observation != null && updated.observation!.trim().isNotEmpty ? " • ${updated.observation!.trim()}" : ""}',
              status: TreatmentItemStatus.pending,
            );
            try {
              await ref.read(treatmentPlanViewModelProvider(patientId).notifier).addItem(item);
            } catch (_) {}
          }
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }
}

class ToothPainter extends CustomPainter {
  final List<ToothCondition> conditions;
  final int toothNumber;
  
  ToothPainter({required this.conditions, required this.toothNumber});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 1.2;
    final padding = size.width * 0.25;
    final quadrant = toothNumber ~/ 10;
    final isRightSide = (quadrant == 1 || quadrant == 4);

    _drawFace(canvas, [Offset(padding, padding), Offset(size.width - padding, padding), Offset(size.width - padding, size.height - padding), Offset(padding, size.height - padding)], ToothSurface.occlusal, borderPaint);
    _drawFace(canvas, [const Offset(0, 0), Offset(size.width, 0), Offset(size.width - padding, padding), Offset(padding, padding)], ToothSurface.buccal, borderPaint);
    _drawFace(canvas, [Offset(padding, size.height - padding), Offset(size.width - padding, size.height - padding), Offset(size.width, size.height), Offset(0, size.height)], ToothSurface.lingual, borderPaint);

    if (isRightSide) {
      _drawFace(canvas, [const Offset(0, 0), Offset(padding, padding), Offset(padding, size.height - padding), Offset(0, size.height)], ToothSurface.distal, borderPaint);
      _drawFace(canvas, [Offset(size.width - padding, padding), Offset(size.width, 0), Offset(size.width, size.height), Offset(size.width - padding, size.height - padding)], ToothSurface.mesial, borderPaint);
    } else {
      _drawFace(canvas, [const Offset(0, 0), Offset(padding, padding), Offset(padding, size.height - padding), Offset(0, size.height)], ToothSurface.mesial, borderPaint);
      _drawFace(canvas, [Offset(size.width - padding, padding), Offset(size.width, 0), Offset(size.width, size.height), Offset(size.width - padding, size.height - padding)], ToothSurface.distal, borderPaint);
    }
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
  final Future<void> Function(ToothCondition, bool addToPlan) onSave;

  const _FaceActionSheet({
    required this.toothNumber,
    required this.surface,
    required this.condition,
    required this.onSave,
    required this.getSurfaceLabel,
    required this.getConditionLabel,
  });

  @override
  State<_FaceActionSheet> createState() => _FaceActionSheetState();
}

class _FaceActionSheetState extends State<_FaceActionSheet> {
  late ConditionType _type;
  final _obs = TextEditingController();
  bool _addToTreatmentPlan = false;

  @override
  void initState() {
    super.initState();
    _type = widget.condition.condition;
    _obs.text = widget.condition.observation ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(10)),
            child: Text('Dente ${widget.toothNumber} - Face ${widget.getSurfaceLabel(widget.surface)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<ConditionType>(
            initialValue: _type,
            items: ConditionType.values.map((t) => DropdownMenuItem(value: t, child: Text(widget.getConditionLabel(t)))).toList(),
            onChanged: (v) => setState(() => _type = v!),
            decoration: const InputDecoration(labelText: 'Condição Clínica', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(controller: _obs, maxLines: 2, decoration: const InputDecoration(labelText: 'Observação da Face', border: OutlineInputBorder(), hintText: 'Opcional')),
          if (_type != ConditionType.healthy) ...[
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _addToTreatmentPlan,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Incluir automaticamente no Plano de Tratamento', style: TextStyle(fontSize: 13)),
              onChanged: (v) => setState(() => _addToTreatmentPlan = v ?? false),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF006494)),
              onPressed: () => widget.onSave(
                widget.condition.copyWith(condition: _type, observation: _obs.text),
                _addToTreatmentPlan,
              ),
              child: const Text('SALVAR ALTERAÇÃO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
