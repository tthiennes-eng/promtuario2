import 'package:flutter/material.dart';
import 'package:promt/features/prontuario/presentation/widgets/odontogram_widget.dart';

class OdontogramScreen extends StatelessWidget {
  final String patientId;
  final String patientName;

  const OdontogramScreen({super.key, required this.patientId, required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Odontograma"),
            Text(patientName, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: OdontogramWidget(patientId: patientId),
    );
  }
}
