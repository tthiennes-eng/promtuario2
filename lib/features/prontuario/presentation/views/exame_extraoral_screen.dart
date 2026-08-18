import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/endodontia_viewmodel.dart';

class ExameExtraoralScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const ExameExtraoralScreen({super.key, required this.patientId, required this.patientName});

  @override
  ConsumerState<ExameExtraoralScreen> createState() => _ExameExtraoralScreenState();
}

class _ExameExtraoralScreenState extends ConsumerState<ExameExtraoralScreen> {
  final Map<String, bool> _data = {
    'Assimetria facial': false,
    'Tumefação/Edema Facial': false,
    'Fístula Cutânea': false,
    'Enfartamento Ganglionar': false,
  };
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final endoAsync = ref.watch(endodontiaViewModelProvider("extraoral_${widget.patientId}"));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(title: const Text("Exame Extraoral")),
      body: endoAsync.when(
        data: (saved) {
          if (!_initialized && saved != null) {
            saved.forEach((k, v) => _data[k] = v);
            _initialized = true;
          }
          return _buildForm();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erro: $err")),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF2D3748), borderRadius: BorderRadius.circular(8)),
            child: const Text("INSPEÇÃO EXTRA-ORAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                children: _data.keys.map((k) => SizedBox(
                  width: 250,
                  child: CheckboxListTile(
                    title: Text(k, style: const TextStyle(fontSize: 13)),
                    value: _data[k],
                    onChanged: (v) => setState(() => _data[k] = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF006494)),
              onPressed: () async {
                await ref.read(endodontiaViewModelProvider("extraoral_${widget.patientId}").notifier).save(_data);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exame Extraoral salvo!"), backgroundColor: Colors.green));
              },
              icon: const Icon(Icons.save),
              label: const Text("SALVAR EXAME EXTRAORAL"),
            ),
          )
        ],
      ),
    );
  }
}
