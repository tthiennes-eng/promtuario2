import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/prontuario_viewmodel.dart';
import '../../domain/entities/odontogram.dart';

/// Widget de produção para o Odontograma Interativo.
/// Renderiza anatomicamente as faces dos dentes e gerencia estados clínicos.
class OdontogramWidget extends ConsumerWidget {
  final String patientId;

  const OdontogramWidget({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final odontogramAsync = ref.watch(prontuarioViewModelProvider(patientId));

    return odontogramAsync.when(
      data: (odontogram) => _buildOdontogramView(context, ref, odontogram),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erro: $err')),
    );
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
          ...left.map((n) => _ToothTile(number: n, condition: _getCondition(odontogram, n), ref: ref, patientId: patientId)),
          const SizedBox(width: 32),
          ...right.map((n) => _ToothTile(number: n, condition: _getCondition(odontogram, n), ref: ref, patientId: patientId)),
        ],
      ),
    );
  }

  ToothCondition _getCondition(Odontogram? odontogram, int number) {
    try {
      return odontogram?.teeth.firstWhere((t) => t.toothNumber == number) ?? 
             ToothCondition(toothNumber: number, condition: ConditionType.healthy, surfaces: []);
    } catch (_) {
      return ToothCondition(toothNumber: number, condition: ConditionType.healthy, surfaces: []);
    }
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
                Text(type.name.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
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
  final ToothCondition condition;
  final WidgetRef ref;
  final String patientId;

  const _ToothTile({required this.number, required this.condition, required this.ref, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(number.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showEditor(context),
            child: CustomPaint(
              size: const Size(40, 40),
              painter: ToothPainter(condition: condition),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ToothActionSheet(
        condition: condition,
        onSave: (updated) {
          ref.read(prontuarioViewModelProvider(patientId).notifier).updateToothCondition(updated);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class ToothPainter extends CustomPainter {
  final ToothCondition condition;
  ToothPainter({required this.condition});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final padding = size.width * 0.15;

    // Desenha as 5 faces (Oclusal, Vestibular, Lingual, Mesial, Distal)
    
    // 1. Centro (Oclusal/Incisal)
    _drawPolygon(canvas, [
      Offset(padding, padding),
      Offset(size.width - padding, padding),
      Offset(size.width - padding, size.height - padding),
      Offset(padding, size.height - padding),
    ], _getSurfaceColor(ToothSurface.occlusal), borderPaint);

    // 2. Superior (Vestibular)
    _drawPolygon(canvas, [
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(size.width - padding, padding),
      Offset(padding, padding),
    ], _getSurfaceColor(ToothSurface.buccal), borderPaint);

    // 3. Inferior (Lingual/Palatal)
    _drawPolygon(canvas, [
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ], _getSurfaceColor(ToothSurface.lingual), borderPaint);

    // 4. Esquerda (Mesial/Distal conforme o dente)
    _drawPolygon(canvas, [
      const Offset(0, 0),
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      Offset(0, size.height),
    ], _getSurfaceColor(ToothSurface.mesial), borderPaint);

    // 5. Direita (Mesial/Distal conforme o dente)
    _drawPolygon(canvas, [
      Offset(size.width - padding, padding),
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(size.width - padding, size.height - padding),
    ], _getSurfaceColor(ToothSurface.distal), borderPaint);

    // Se o dente estiver ausente ou com implante, desenha um ícone sobreposto
    if (condition.condition == ConditionType.missing) {
      _drawX(canvas, size);
    }
  }

  void _drawPolygon(Canvas canvas, List<Offset> points, Color color, Paint borderPaint) {
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(path, borderPaint);
  }

  void _drawX(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red.withOpacity(0.5)..strokeWidth = 3;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  Color _getSurfaceColor(ToothSurface surface) {
    if (condition.condition == ConditionType.healthy) return Colors.white;
    if (condition.surfaces.contains(surface)) {
      return OdontogramWidget._getConditionColor(condition.condition);
    }
    return Colors.white;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ToothActionSheet extends StatefulWidget {
  final ToothCondition condition;
  final Function(ToothCondition) onSave;

  const _ToothActionSheet({required this.condition, required this.onSave});

  @override
  State<_ToothActionSheet> createState() => _ToothActionSheetState();
}

class _ToothActionSheetState extends State<_ToothActionSheet> {
  late ConditionType _selectedType;
  late List<ToothSurface> _selectedSurfaces;
  final _obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.condition.condition;
    _selectedSurfaces = List.from(widget.condition.surfaces);
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
              Text('Dente ${widget.condition.toothNumber}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Diagnóstico Principal', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<ConditionType>(
            isExpanded: true,
            value: _selectedType,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: ConditionType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.name.toUpperCase()))).toList(),
            onChanged: (val) => setState(() => _selectedType = val!),
          ),
          if (_selectedType != ConditionType.missing && _selectedType != ConditionType.healthy) ...[
            const SizedBox(height: 24),
            const Text('Faces Acometidas', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ToothSurface.values.where((s) => s != ToothSurface.root).map((s) {
                final isSelected = _selectedSurfaces.contains(s);
                return FilterChip(
                  label: Text(s.name.toUpperCase()),
                  selected: isSelected,
                  selectedColor: Colors.blue.shade100,
                  onSelected: (val) {
                    setState(() {
                      val ? _selectedSurfaces.add(s) : _selectedSurfaces.remove(s);
                    });
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _obsController,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Ex: Cárie profunda, necessidade de endo...', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () => widget.onSave(widget.condition.copyWith(
                condition: _selectedType,
                surfaces: _selectedSurfaces,
                observation: _obsController.text,
              )),
              child: const Text('Atualizar Prontuário'),
            ),
          ),
        ],
      ),
    );
  }
}
