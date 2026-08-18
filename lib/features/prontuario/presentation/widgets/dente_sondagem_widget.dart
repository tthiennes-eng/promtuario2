import 'package:flutter/material.dart';
import '../../domain/entities/periograma.dart';

class DenteSondagemWidget extends StatelessWidget {
  final DenteSondagem dente;
  final VoidCallback onChanged;

  const DenteSondagemWidget({super.key, required this.dente, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildSondagemTable(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF006494).withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF006494),
            radius: 14,
            child: Text(dente.toothNumber.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 24),
          _buildDropdown<int>(
            label: "Mobilidade:",
            value: dente.mobilidade,
            items: [0, 1, 2, 3],
            onChanged: (v) {
              dente.mobilidade = v!;
              onChanged();
            },
          ),
          const SizedBox(width: 24),
          _buildDropdown<String>(
            label: "Envolv. Furca:",
            value: dente.furca,
            items: ["N/A", "I", "II", "III"],
            onChanged: (v) {
              dente.furca = v!;
              onChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T value, required List<T> items, required ValueChanged<T?> onChanged}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(width: 8),
        DropdownButton<T>(
          value: value,
          underline: const SizedBox(),
          style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i.toString()))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSondagemTable() {
    const labels = ["MV", "V", "DV", "ML", "L", "DL"];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
          5: FlexColumnWidth(1),
          6: FlexColumnWidth(1),
        },
        children: [
          // Header: Faces
          TableRow(
            children: [
              const SizedBox(),
              ...labels.map((l) => Center(child: Text(l, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)))),
            ],
          ),
          const TableRow(children: [SizedBox(height: 8), SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox()]),
          
          // Profundidade (PS)
          _buildDataRow("Prof. Sondagem", (p) => p.profundidade, (p, v) => p.profundidade = v, isProbing: true),
          
          // Recessão (MG)
          _buildDataRow("Margem Gengival", (p) => p.recessao, (p, v) {
            p.recessao = v;
            p.nivelInsercao = p.profundidade + p.recessao;
          }),
          
          // NIC (Calculado)
          TableRow(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("NIC (Calculado)", style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
              ),
              ...dente.pontos.map((p) => Center(
                child: Text("${p.profundidade + p.recessao}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              )),
            ],
          ),

          // Checkboxes (SS, SUP, PL)
          _buildCheckRow("Sangramento (SS)", (p) => p.sangramento, (p, v) => p.sangramento = v!, Colors.red),
          _buildCheckRow("Supuração (SUP)", (p) => p.supuracao, (p, v) => p.supuracao = v!, Colors.orange),
          _buildCheckRow("Placa (PL)", (p) => p.placa, (p, v) => p.placa = v!, Colors.blue),
        ],
      ),
    );
  }

  TableRow _buildDataRow(String label, int Function(PontoSondagem) getter, Function(PontoSondagem, int) setter, {bool isProbing = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ),
        ...dente.pontos.map((p) {
          final value = getter(p);
          Color? bgColor;
          if (isProbing) {
            if (value >= 6) bgColor = Colors.red.shade100;
            else if (value >= 4) bgColor = Colors.orange.shade100;
          }

          return Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextFormField(
              initialValue: value == 0 && !isProbing ? "" : value.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
              ),
              onChanged: (v) {
                setter(p, int.tryParse(v) ?? 0);
                onChanged();
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  TableRow _buildCheckRow(String label, bool Function(PontoSondagem) getter, Function(PontoSondagem, bool?) setter, Color color) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ),
        ...dente.pontos.map((p) => Checkbox(
          value: getter(p),
          activeColor: color,
          visualDensity: VisualDensity.compact,
          onChanged: (v) {
            setter(p, v);
            onChanged();
          },
        )).toList(),
      ],
    );
  }
}
