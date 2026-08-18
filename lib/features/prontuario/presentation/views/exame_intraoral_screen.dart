import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/endodontia_viewmodel.dart';

class ExameIntraoralScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const ExameIntraoralScreen({super.key, required this.patientId, required this.patientName});

  @override
  ConsumerState<ExameIntraoralScreen> createState() => _ExameIntraoralScreenState();
}

class _ExameIntraoralScreenState extends ConsumerState<ExameIntraoralScreen> {
  final Map<String, dynamic> _data = {
    'moles': {
      'Ulceração': false, 'Alteração de cor': false, 'Edema Apical Entumecido': false,
      'Edema Apical Flutuante': false, 'Fístula': false, 'Bolsa Periodontal': false,
      'Sangramento à sondagem': false, 'Dor à sondagem': false, 'Retração gengival': false,
    },
    'profundidade': "",
    'dentais': {
      'Cárie': false, 'Abfração': false, 'Exposição Pulpar Aparente': false,
      'Restauração Ionômero': false, 'Alteração da cor dentária': false,
      'Restauração Amálgama': false, 'Mobilidade dental': false,
      'Restauração Resina': false, 'Dente em infra-oclusão': false,
      'Selamento Provisório': false, 'Dente em sobre-oclusão': false,
    }
  };
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final endoAsync = ref.watch(endodontiaViewModelProvider("intraoral_${widget.patientId}"));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(title: const Text("Exame Intraoral")),
      body: endoAsync.when(
        data: (saved) {
          if (!_initialized && saved != null) {
            _data.addAll(saved);
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
          _buildSectionHeader("INSPEÇÃO INTRA-ORAL"),
          
          const Text("Dos Tecidos Moles (Gengiva e Mucosa)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF006494))),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Wrap(
                    children: (_data['moles'] as Map).keys.map((k) => SizedBox(
                      width: 250,
                      child: CheckboxListTile(
                        dense: true, title: Text(k, style: const TextStyle(fontSize: 12)),
                        value: _data['moles'][k],
                        onChanged: (v) => setState(() => _data['moles'][k] = v!),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    )).toList(),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Text("Profundidade:", style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        SizedBox(width: 60, child: TextFormField(initialValue: _data['profundidade'], keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true), onChanged: (v) => _data['profundidade'] = v)),
                        const Text(" mm", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text("Dos Tecidos Dentais", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF006494))),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                children: (_data['dentais'] as Map).keys.map((k) => SizedBox(
                  width: 250,
                  child: CheckboxListTile(
                    dense: true, title: Text(k, style: const TextStyle(fontSize: 12)),
                    value: _data['dentais'][k],
                    onChanged: (v) => setState(() => _data['dentais'][k] = v!),
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
                await ref.read(endodontiaViewModelProvider("intraoral_${widget.patientId}").notifier).save(_data);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exame Intraoral salvo!"), backgroundColor: Colors.green));
              },
              icon: const Icon(Icons.save),
              label: const Text("SALVAR EXAME INTRAORAL"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF2D3748), borderRadius: BorderRadius.circular(8)), child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));
  }
}
