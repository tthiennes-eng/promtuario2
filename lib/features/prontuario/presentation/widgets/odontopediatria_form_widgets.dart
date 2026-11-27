import 'package:flutter/material.dart';
import '../../domain/entities/odontopediatria_data.dart';

const Color kOdontoPrimary = Color(0xFF006494);
const Color kOdontoBg = Color(0xFFF1F5F9);

class OdontoSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? accentColor;
  final List<Widget> children;

  const OdontoSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.accentColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? kOdontoPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.07),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(fontSize: 11.5, color: Colors.blueGrey.shade600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OdontoTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const OdontoTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13.5),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kOdontoPrimary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class OdontoResponsiveRow extends StatelessWidget {
  final List<Widget> children;

  const OdontoResponsiveRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i < children.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class OdontoSingleChoice extends StatelessWidget {
  final String question;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const OdontoSingleChoice({
    super.key,
    required this.question,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = selected == opt;
              return ChoiceChip(
                label: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: kOdontoPrimary,
                backgroundColor: const Color(0xFFF8FAFC),
                side: BorderSide(
                  color: isSelected ? kOdontoPrimary : Colors.grey.shade300,
                ),
                onSelected: (_) => onChanged(isSelected ? '' : opt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class OdontoMultiChoice extends StatelessWidget {
  final String question;
  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<String> onToggle;

  const OdontoMultiChoice({
    super.key,
    required this.question,
    required this.options,
    required this.selectedValues,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = selectedValues.contains(opt);
              return FilterChip(
                label: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isSelected ? kOdontoPrimary : const Color(0xFF334155),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: kOdontoPrimary.withValues(alpha: 0.14),
                checkmarkColor: kOdontoPrimary,
                backgroundColor: const Color(0xFFF8FAFC),
                side: BorderSide(
                  color: isSelected ? kOdontoPrimary : Colors.grey.shade300,
                ),
                onSelected: (_) => onToggle(opt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class OdontoTriStateTable extends StatelessWidget {
  final String? headerLabel;
  final List<Map<String, String>> items;
  final List<String> choices;
  final String Function(String key) valueFor;
  final void Function(String key, String value) onChanged;

  const OdontoTriStateTable({
    super.key,
    this.headerLabel,
    required this.items,
    this.choices = const ['Sim', 'Não', 'Não sabe'],
    required this.valueFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          if (headerLabel != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Text(
                headerLabel!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
            ),
          for (int i = 0; i < items.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: i.isEven ? Colors.white : const Color(0xFFFAFBFD),
                border: i < items.length - 1
                    ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                    : null,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final key = items[i]['key']!;
                  final label = items[i]['label']!;
                  final current = valueFor(key);
                  final chips = Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: choices.map((c) {
                      final active = current == c;
                      return ChoiceChip(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(
                          c,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: active ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                        selected: active,
                        selectedColor: kOdontoPrimary,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: active ? kOdontoPrimary : Colors.grey.shade300,
                        ),
                        onSelected: (_) => onChanged(key, active ? '' : c),
                      );
                    }).toList(),
                  );
                  if (constraints.maxWidth < 540) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B))),
                        const SizedBox(height: 6),
                        chips,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B))),
                      ),
                      const SizedBox(width: 12),
                      chips,
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Grade interativa binária (0 / 1) para IPV e ISG com cálculo automático de percentual.
class OdontoBinarySurfaceGrid extends StatelessWidget {
  final String title;
  final String legendZero;
  final String legendOne;
  final List<String> surfaces;
  final bool disableOcclusalOnAnterior;
  final String gridKey;
  final OdontopediatriaModel model;
  final VoidCallback onChanged;

  const OdontoBinarySurfaceGrid({
    super.key,
    required this.title,
    required this.legendZero,
    required this.legendOne,
    required this.surfaces,
    required this.disableOcclusalOnAnterior,
    required this.gridKey,
    required this.model,
    required this.onChanged,
  });

  String _nextValue(String current) {
    if (current.isEmpty) return '0';
    if (current == '0') return '1';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final percent = model.computeBinaryIndexPercent(gridKey);
    return OdontoSectionCard(
      title: title,
      subtitle: 'Toque em cada célula para alternar: vazio → 0 ($legendZero) → 1 ($legendOne)',
      icon: Icons.grid_on_outlined,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: kOdontoPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kOdontoPrimary.withValues(alpha: 0.2)),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Códigos:  0 — $legendZero   |   1 — $legendOne',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: percent == null
                      ? Colors.grey.shade200
                      : (percent >= 20 ? Colors.red.shade100 : Colors.green.shade100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  percent == null
                      ? 'Percentual: — %'
                      : 'Percentual: ${percent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: percent == null
                        ? Colors.grey.shade700
                        : (percent >= 20 ? Colors.red.shade900 : Colors.green.shade900),
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final entry in OdontopediatriaConstants.ipvIsgQuadrants.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: Text(
              entry.key,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const FixedColumnWidth(54),
              columnWidths: const {0: FixedColumnWidth(84)},
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(6),
                      child: Text(
                        'Dente',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...surfaces.map(
                      (s) => Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          s,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                for (final tooth in entry.value)
                  TableRow(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        color: const Color(0xFFF8FAFC),
                        child: Text(
                          tooth.displayLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                      ...surfaces.map((s) {
                        final disabled = disableOcclusalOnAnterior && s == 'O' && !tooth.hasOcclusal;
                        if (disabled) {
                          return Container(
                            height: 34,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Text('—', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          );
                        }
                        final val = model.getGridCell(gridKey, tooth.key, s);
                        Color bg = Colors.white;
                        Color fg = const Color(0xFF334155);
                        if (val == '0') {
                          bg = Colors.green.shade50;
                          fg = Colors.green.shade800;
                        } else if (val == '1') {
                          bg = Colors.red.shade50;
                          fg = Colors.red.shade800;
                        }
                        return InkWell(
                          onTap: () {
                            model.setGridCell(gridKey, tooth.key, s, _nextValue(val));
                            onChanged();
                          },
                          child: Container(
                            height: 34,
                            color: bg,
                            alignment: Alignment.center,
                            child: Text(
                              val.isEmpty ? '·' : val,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: val.isEmpty ? FontWeight.normal : FontWeight.bold,
                                color: val.isEmpty ? Colors.grey.shade400 : fg,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Grade interativa com seleção de código numérico (Exame Clínico 0–10 ou Radiográfico 0–7).
class OdontoCodedSurfaceGrid extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> surfaces;
  final List<String> legendCodes;
  final int maxCode;
  final String gridKey;
  final bool includePresentToggle;
  final bool includeObservationField;
  final OdontopediatriaModel model;
  final TextEditingController Function(String key) controllerFor;
  final VoidCallback onChanged;

  const OdontoCodedSurfaceGrid({
    super.key,
    required this.title,
    required this.subtitle,
    required this.surfaces,
    required this.legendCodes,
    required this.maxCode,
    required this.gridKey,
    this.includePresentToggle = false,
    this.includeObservationField = false,
    required this.model,
    required this.controllerFor,
    required this.onChanged,
  });

  Future<void> _pickCode(BuildContext context, ToothPairSpec tooth, String surface, String current) async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Dente ${tooth.displayLabel} — Face $surface'),
        content: SizedBox(
          width: 340,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                dense: true,
                title: const Text('Limpar célula (vazio)'),
                leading: const Icon(Icons.clear, size: 18),
                onTap: () => Navigator.pop(ctx, ''),
              ),
              const Divider(height: 8),
              for (int code = 0; code <= maxCode; code++)
                ListTile(
                  dense: true,
                  selected: current == '$code',
                  title: Text(
                    code < legendCodes.length ? legendCodes[code] : '$code',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: current == '$code' ? const Icon(Icons.check, color: kOdontoPrimary, size: 18) : null,
                  onTap: () => Navigator.pop(ctx, '$code'),
                ),
            ],
          ),
        ),
      ),
    );
    if (chosen != null) {
      model.setGridCell(gridKey, tooth.key, surface, chosen);
      onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OdontoSectionCard(
      title: title,
      subtitle: subtitle,
      icon: Icons.fact_check_outlined,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 4,
            children: legendCodes
                .map((c) => Text(c, style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155))))
                .toList(),
          ),
        ),
        for (final entry in OdontopediatriaConstants.clinicalQuadrants.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Text(
              entry.key,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const FixedColumnWidth(46),
              columnWidths: {
                0: const FixedColumnWidth(80),
                if (includePresentToggle) 1: const FixedColumnWidth(68),
                if (includeObservationField)
                  (surfaces.length + (includePresentToggle ? 2 : 1)): const FixedColumnWidth(200),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(6),
                      child: Text('Dente', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    if (includePresentToggle)
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text('Presente', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      ),
                    ...surfaces.map(
                      (s) => Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(s, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (includeObservationField)
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text('Observações clínicas', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                for (final tooth in entry.value)
                  TableRow(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        color: const Color(0xFFF8FAFC),
                        alignment: Alignment.center,
                        child: Text(
                          tooth.displayLabel,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (includePresentToggle)
                        Center(
                          child: Checkbox(
                            visualDensity: VisualDensity.compact,
                            value: model.getBool('t8_presente_${tooth.key}'),
                            onChanged: (v) {
                              model.setBool('t8_presente_${tooth.key}', v ?? false);
                              onChanged();
                            },
                          ),
                        ),
                      ...surfaces.map((s) {
                        final val = model.getGridCell(gridKey, tooth.key, s);
                        final isPathology = val.isNotEmpty && val != '0' && val != '5';
                        return InkWell(
                          onTap: () => _pickCode(context, tooth, s, val),
                          child: Container(
                            height: 36,
                            alignment: Alignment.center,
                            color: val.isEmpty
                                ? Colors.white
                                : (val == '0'
                                    ? Colors.green.shade50
                                    : (isPathology ? Colors.orange.shade50 : Colors.blue.shade50)),
                            child: Text(
                              val.isEmpty ? '·' : val,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: val.isEmpty ? FontWeight.normal : FontWeight.bold,
                                color: val.isEmpty
                                    ? Colors.grey.shade400
                                    : (val == '0'
                                        ? Colors.green.shade800
                                        : (isPathology ? Colors.deepOrange.shade800 : Colors.blue.shade800)),
                              ),
                            ),
                          ),
                        );
                      }),
                      if (includeObservationField)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: TextField(
                            controller: controllerFor('t8_obs_${tooth.key}'),
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Obs...',
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
