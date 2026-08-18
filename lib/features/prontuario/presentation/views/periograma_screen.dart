import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/periograma.dart';
import '../widgets/dente_sondagem_widget.dart';
import '../viewmodels/periograma_viewmodel.dart';

class PeriogramaScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const PeriogramaScreen({super.key, required this.patientId, required this.patientName});

  @override
  ConsumerState<PeriogramaScreen> createState() => _PeriogramaScreenState();
}

class _PeriogramaScreenState extends ConsumerState<PeriogramaScreen> {
  late PeriogramaModel _model;
  bool _initialized = false;

  void _initEmptyModel() {
    final superior = [18, 17, 16, 15, 14, 13, 12, 11, 21, 22, 23, 24, 25, 26, 27, 28];
    final inferior = [48, 47, 46, 45, 44, 43, 42, 41, 31, 32, 33, 34, 35, 36, 37, 38];
    
    _model = PeriogramaModel(
      id: const Uuid().v4(),
      patientId: widget.patientId,
      date: DateTime.now(),
      dentes: [...superior, ...inferior].map((n) => DenteSondagem(toothNumber: n)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periAsync = ref.watch(periogramaViewModelProvider(widget.patientId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Periograma (Ficha Periodontal)"),
            Text(widget.patientName, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: periAsync.when(
        data: (data) {
          if (!_initialized) {
            if (data != null) {
              _model = PeriogramaModel.fromMap(data);
            } else {
              _initEmptyModel();
            }
            _initialized = true;
          }
          return _buildForm();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erro ao carregar periograma: $err")),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTipoExameCard(),
          const SizedBox(height: 24),
          _buildSectionHeader("ARCADA SUPERIOR"),
          _buildArcadaGrid(18, 11, 21, 28),
          const SizedBox(height: 32),
          _buildSectionHeader("ARCADA INFERIOR"),
          _buildArcadaGrid(48, 41, 31, 38),
          const SizedBox(height: 32),
          _buildResumoCalculado(),
          const SizedBox(height: 48),
          _buildSaveButton(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTipoExameCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text("Tipo de Exame: ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006494))),
            const SizedBox(width: 16),
            ...TipoExamePeriodontal.values.map((t) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Radio<TipoExamePeriodontal>(
                    value: t,
                    groupValue: _model.tipo,
                    onChanged: (v) => setState(() => _model.tipo = v!),
                  ),
                  Text(t.name == 'primeiro' ? 'Primeiro Exame' : t.name == 'reavaliacao' ? 'Reavaliação' : 'Manutenção'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildArcadaGrid(int startL, int endL, int startR, int endR) {
    final dentesL = _model.dentes.where((d) => d.toothNumber >= endL && d.toothNumber <= startL).toList();
    final dentesR = _model.dentes.where((d) => d.toothNumber >= startR && d.toothNumber <= endR).toList();
    
    dentesL.sort((a, b) => b.toothNumber.compareTo(a.toothNumber));
    dentesR.sort((a, b) => a.toothNumber.compareTo(b.toothNumber));

    return Column(
      children: [
        ...dentesL.map((d) => DenteSondagemWidget(dente: d, onChanged: () => setState(() {}))),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(thickness: 2, color: Colors.blueGrey),
        ),
        ...dentesR.map((d) => DenteSondagemWidget(dente: d, onChanged: () => setState(() {}))),
      ],
    );
  }

  Widget _buildResumoCalculado() {
    int totalPontos = 0;
    int pontosPlaca = 0;
    int pontosSangramento = 0;
    int sitios4mm = 0;
    int sitios6mm = 0;

    for (var dente in _model.dentes) {
      for (var ponto in dente.pontos) {
        totalPontos++;
        if (ponto.placa) pontosPlaca++;
        if (ponto.sangramento) pontosSangramento++;
        if (ponto.profundidade >= 6) {
          sitios6mm++;
        } else if (ponto.profundidade >= 4) {
          sitios4mm++;
        }
      }
    }

    double idxPlaca = totalPontos > 0 ? (pontosPlaca / totalPontos) * 100 : 0;
    double idxSangue = totalPontos > 0 ? (pontosSangramento / totalPontos) * 100 : 0;

    return Card(
      color: const Color(0xFF2D3748),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("RESUMO E ÍNDICES PERIODONTAIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildResumoItem("Índice de Placa", "${idxPlaca.toStringAsFixed(1)}%", Colors.blue.shade300),
                _buildResumoItem("Índice de Sangramento", "${idxSangue.toStringAsFixed(1)}%", Colors.red.shade300),
                _buildResumoItem("Sítios ≥ 4mm", "$sitios4mm", Colors.orange.shade300),
                _buildResumoItem("Sítios ≥ 6mm", "$sitios6mm", Colors.red.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF006494), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () async {
          try {
            await ref.read(periogramaViewModelProvider(widget.patientId).notifier).save(_model.toMap());
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Periograma salvo com sucesso!"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.red),
              );
            }
          }
        },
        icon: const Icon(Icons.save),
        label: const Text("SALVAR PERIOGRAMA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
