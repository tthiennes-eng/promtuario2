import 'package:flutter/material.dart';

class MenuAction {
  final IconData icon;
  final String label;
  final String actionId;

  MenuAction({
    required this.icon,
    required this.label,
    required this.actionId,
  });
}

class PatientMenuButton extends StatelessWidget {
  final Function(String) onActionSelected;

  const PatientMenuButton({super.key, required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    final clinicalActions = [
      MenuAction(icon: Icons.history, label: 'Ficha de Anamnese', actionId: 'anamnese'),
      MenuAction(icon: Icons.table_chart_outlined, label: 'Periograma', actionId: 'periograma'),
      MenuAction(icon: Icons.healing, label: 'Ficha de Endodontia', actionId: 'endodontia'),
      MenuAction(icon: Icons.assignment_outlined, label: 'Plano de Tratamento', actionId: 'plano'),
    ];

    final documentActions = [
      MenuAction(icon: Icons.description_outlined, label: 'Emitir Receita', actionId: 'receita'),
      MenuAction(icon: Icons.article_outlined, label: 'Emitir Atestado', actionId: 'atestado'),
    ];

    return PopupMenuButton<String>(
      icon: const Icon(Icons.add_circle_outline, size: 28, color: Color(0xFF006494)),
      tooltip: 'Ações e Fichas',
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onActionSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(
          enabled: false,
          child: Text("FICHAS CLÍNICAS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        ...clinicalActions.map((a) => PopupMenuItem(
          value: a.actionId,
          child: Row(
            children: [
              Icon(a.icon, color: const Color(0xFF2D3748), size: 20),
              const SizedBox(width: 12),
              Text(a.label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        )),
        const PopupMenuDivider(),
        const PopupMenuItem(
          enabled: false,
          child: Text("DOCUMENTOS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        ...documentActions.map((a) => PopupMenuItem(
          value: a.actionId,
          child: Row(
            children: [
              Icon(a.icon, color: const Color(0xFF2D3748), size: 20),
              const SizedBox(width: 12),
              Text(a.label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        )),
      ],
    );
  }
}
