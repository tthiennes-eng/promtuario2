import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/features/prontuario/domain/entities/evolution.dart';
import 'package:promt/features/prontuario/domain/entities/odontogram.dart';
import 'package:promt/features/prontuario/domain/entities/prescription.dart';
import 'package:promt/features/prontuario/domain/entities/treatment_plan.dart';

/// Serviço central de geração de PDFs clínicos do prontuário odontológico.
class ProntuarioPdfService {
  static final _dateFmt = DateFormat('dd/MM/yyyy');
  static final _dateTimeFmt = DateFormat('dd/MM/yyyy HH:mm');

  static Future<Directory> _ensureExportDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'OdontoClinica_PDFs'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static String _sanitizeFileName(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static Future<File> _saveDocument(pw.Document doc, String prefix, String patientName) async {
    final dir = await _ensureExportDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final safeName = _sanitizeFileName(patientName);
    final fileName = '${prefix}_${safeName.isEmpty ? "paciente" : safeName}_$stamp.pdf';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static pw.Widget _header(String title, String patientName, {String? subtitle}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#006494'),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CLÍNICA ESCOLA ODONTOLÓGICA UNIVERSITÁRIA',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                title.toUpperCase(),
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  subtitle,
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 9),
                ),
              ],
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Paciente: $patientName',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Emitido em: ${_dateTimeFmt.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Divider(color: PdfColors.grey400),
      ],
    );
  }

  static pw.Widget _signatureFooter(String professionalName) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 36),
        pw.Center(
          child: pw.Column(
            children: [
              pw.Container(width: 240, height: 1, color: PdfColors.black),
              pw.SizedBox(height: 4),
              pw.Text(
                professionalName.isEmpty ? 'Profissional / Professor Supervisor' : professionalName,
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Cirurgião-Dentista / CRO',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Future<File> generatePrescriptionPdf({
    required String patientName,
    required Prescription prescription,
    String? clinicName,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _header('Receituário Odontológico', patientName, subtitle: clinicName),
            pw.SizedBox(height: 16),
            pw.Text(
              'PRESCRIÇÃO',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            ...prescription.items.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final item = entry.value;
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '$idx. ${item.medicineName} — ${item.dosage}',
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    if (item.instructions.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Uso: ${item.instructions}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ],
                ),
              );
            }),
            if (prescription.observations != null &&
                prescription.observations!.trim().isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text(
                'Observações / Recomendações:',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(prescription.observations!, style: const pw.TextStyle(fontSize: 10)),
            ],
            pw.Spacer(),
            _signatureFooter(prescription.doctorName),
          ],
        ),
      ),
    );
    return _saveDocument(doc, 'receita', patientName);
  }

  static Future<File> generateCertificatePdf({
    required String patientName,
    required MedicalCertificate certificate,
    String? clinicName,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _header('Atestado Odontológico', patientName, subtitle: clinicName),
            pw.SizedBox(height: 28),
            pw.Text(
              certificate.content,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 6),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Dias de afastamento/repouso: ${certificate.daysOfRest} dia(s)',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            if (certificate.cid != null && certificate.cid!.trim().isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text('CID-10: ${certificate.cid}', style: const pw.TextStyle(fontSize: 10)),
            ],
            pw.Spacer(),
            _signatureFooter(certificate.doctorName),
          ],
        ),
      ),
    );
    return _saveDocument(doc, 'atestado', patientName);
  }

  static Future<File> generateTreatmentPlanPdf({
    required String patientName,
    required TreatmentPlan plan,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          _header('Plano de Tratamento Odontológico', patientName),
          pw.SizedBox(height: 12),
          pw.Text('Descrição: ${plan.description}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Status do Plano: ${plan.status.name.toUpperCase()}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#006494')),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headers: const ['#', 'Procedimento', 'Dente', 'Status', 'Observações'],
            data: plan.items.asMap().entries.map((e) {
              final item = e.value;
              return [
                '${e.key + 1}',
                item.procedureName,
                item.toothNumber != null ? '${item.toothNumber}' : 'Geral',
                item.status.name.toUpperCase(),
                item.observation ?? '-',
              ];
            }).toList(),
          ),
          _signatureFooter('Professor Supervisor / Responsável'),
        ],
      ),
    );
    return _saveDocument(doc, 'plano_tratamento', patientName);
  }

  static Future<File> generatePprPdf({
    required String patientName,
    required Map<String, dynamic> pprData,
  }) async {
    final doc = pw.Document();
    String field(String key) => (pprData[key] ?? '').toString().trim();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _header('Ficha de Planejamento e Delineamento - PPR', patientName),
          pw.SizedBox(height: 8),
          pw.Text('Aluno: ${field("aluno")}   |   Professor: ${field("professor")}', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('Prontuário: ${field("prontuario")}   |   Data: ${field("data")}', style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 10),
          pw.Text('Classificação de Kennedy: ${field("classificacaoKennedy")}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Text('Observações / Notas Técnicas:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Text(field('observacoes').isEmpty ? 'Sem observações registradas.' : field('observacoes'), style: const pw.TextStyle(fontSize: 9)),
          _signatureFooter(field('professor').isEmpty ? 'Professor Responsável' : field('professor')),
        ],
      ),
    );
    return _saveDocument(doc, 'ficha_ppr', patientName);
  }

  static Future<File> generateDtmPdf({
    required String patientName,
    required Map<String, dynamic> dtmData,
  }) async {
    final doc = pw.Document();
    String field(String key) => (dtmData[key] ?? '').toString().trim();
    String sub(String parent, String key) {
      final m = dtmData[parent];
      if (m is Map) return (m[key] ?? '').toString().trim();
      return '';
    }

    final rawRows = dtmData['tratamentos'];
    final rows = <List<String>>[];
    if (rawRows is List) {
      for (final item in rawRows) {
        if (item is Map) {
          final d = (item['data'] ?? '').toString().trim();
          final dente = (item['dente'] ?? '').toString().trim();
          final trat = (item['tratamentoRealizado'] ?? '').toString().trim();
          if (d.isNotEmpty || dente.isNotEmpty || trat.isNotEmpty) {
            rows.add([d, dente, trat]);
          }
        }
      }
    }

    final prof = field('profissional').isEmpty ? 'Dra. Andrea Alac' : field('profissional');
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _header('Ficha Clínica - DTM', patientName, subtitle: '$prof  |  Data: ${field("data")}'),
          pw.SizedBox(height: 10),
          pw.Text('AVALIAÇÃO DE RISCO (avaliado pela sua dentista)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Risco de Cárie: ${field("riscoCarie").isEmpty ? "-" : field("riscoCarie")}', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('Risco Oclusal: ${field("riscoOclusal").isEmpty ? "-" : field("riscoOclusal")}', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('Risco DTM: ${field("riscoDtm").isEmpty ? "-" : field("riscoDtm")}', style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 12),
          pw.Text('COR DOS DENTES', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Cor atual dos dentes — Anterior: ${sub("corAtual", "anterior")} | Canino: ${sub("corAtual", "canino")} | Posterior: ${sub("corAtual", "posterior")}', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('Após o clareamento — Anterior: ${sub("aposClareamento", "anterior")} | Canino: ${sub("aposClareamento", "canino")} | Posterior: ${sub("aposClareamento", "posterior")}', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('Cor da porcelana ou resina foto — Anterior: ${sub("corPorcelanaResina", "anterior")} | Canino: ${sub("corPorcelanaResina", "canino")} | Posterior: ${sub("corPorcelanaResina", "posterior")}', style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 14),
          pw.Text('TRATAMENTO REALIZADO', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#006494')),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headers: const ['Data', 'Dente', 'TRATAMENTO REALIZADO'],
            data: rows.isEmpty ? const [['-', '-', 'Nenhum tratamento registrado']] : rows,
          ),
          _signatureFooter(prof),
        ],
      ),
    );
    return _saveDocument(doc, 'ficha_dtm', patientName);
  }

  static Future<File> generateTclePdf({
    required String patientName,
    required Map<String, dynamic> tcleData,
  }) async {
    final doc = pw.Document();
    final accepted = tcleData['accepted'] == true;
    final acceptedAt = (tcleData['acceptedAt'] ?? '').toString();
    final text = (tcleData['termText'] ?? '').toString();
    final witness = (tcleData['professionalName'] ?? '').toString();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          _header('Termo de Consentimento Livre e Esclarecido (TCLE / LGPD)', patientName),
          pw.SizedBox(height: 12),
          pw.Text(text, style: const pw.TextStyle(fontSize: 10, lineSpacing: 4), textAlign: pw.TextAlign.justify),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: accepted ? PdfColors.green700 : PdfColors.grey500),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              accepted
                  ? 'CONSENTIMENTO REGISTRADO ELETRONICAMENTE em $acceptedAt'
                  : 'Consentimento ainda não assinado.',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          _signatureFooter(witness),
        ],
      ),
    );
    return _saveDocument(doc, 'tcle', patientName);
  }

  static Future<File> generateFullProntuarioPdf({
    required Patient patient,
    Map<String, dynamic>? anamnese,
    Odontogram? odontogram,
    List<Evolution> evolutions = const [],
    List<TreatmentPlan> plans = const [],
    List<Prescription> prescriptions = const [],
    List<MedicalCertificate> certificates = const [],
    Map<String, dynamic>? tcle,
  }) async {
    final doc = pw.Document();
    final age = DateTime.now().year - patient.birthDate.year;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _header('Prontuário Odontológico Completo', patient.fullName, subtitle: 'Documento compilado conforme LGPD'),
          pw.SizedBox(height: 8),
          pw.Text('CPF: ${patient.cpf}  |  Nascimento: ${_dateFmt.format(patient.birthDate)} ($age anos)  |  Sexo: ${patient.gender ?? "N/I"}', style: const pw.TextStyle(fontSize: 9)),
          if (patient.susNumber != null && patient.susNumber!.isNotEmpty)
            pw.Text('Cartão SUS: ${patient.susNumber}', style: const pw.TextStyle(fontSize: 9)),
          if (patient.phone != null && patient.phone!.isNotEmpty)
            pw.Text('Telefone: ${patient.phone}  |  E-mail: ${patient.email ?? "-"}', style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 12),

          pw.Text('1. ODONTOGRAMA (${odontogram?.teeth.length ?? 0} registros)', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          if (odontogram == null || odontogram.teeth.isEmpty)
            pw.Text('Nenhum registro no odontograma.', style: const pw.TextStyle(fontSize: 9))
          else
            ...odontogram.teeth.map((t) => pw.Text(
                  '• Dente ${t.toothNumber}: ${t.condition.name} (${t.surfaces.map((s) => s.name).join(", ")}) ${t.observation ?? ""}',
                  style: const pw.TextStyle(fontSize: 9),
                )),
          pw.SizedBox(height: 12),

          pw.Text('2. PLANO DE TRATAMENTO', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          if (plans.isEmpty)
            pw.Text('Nenhum plano de tratamento ativo.', style: const pw.TextStyle(fontSize: 9))
          else
            ...plans.first.items.map((item) => pw.Text(
                  '• ${item.procedureName}${item.toothNumber != null ? " (Dente ${item.toothNumber})" : ""} — ${item.status.name.toUpperCase()}',
                  style: const pw.TextStyle(fontSize: 9),
                )),
          pw.SizedBox(height: 12),

          pw.Text('3. EVOLUÇÕES CLÍNICAS (${evolutions.length})', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          if (evolutions.isEmpty)
            pw.Text('Nenhuma evolução registrada.', style: const pw.TextStyle(fontSize: 9))
          else
            ...evolutions.map((e) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${_dateTimeFmt.format(e.createdAt)} • ${e.clinicName ?? "Clínica"} • ${e.isSignedByProfessor ? "ASSINADO" : "PENDENTE"}',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(e.description, style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                )),
          pw.SizedBox(height: 12),

          pw.Text('4. RECEITAS (${prescriptions.length}) E ATESTADOS (${certificates.length})', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          ...prescriptions.map((r) => pw.Text(
                '• Receita (${_dateFmt.format(r.createdAt)}): ${r.items.map((i) => "${i.medicineName} ${i.dosage}").join("; ")}',
                style: const pw.TextStyle(fontSize: 9),
              )),
          ...certificates.map((c) => pw.Text(
                '• Atestado (${_dateFmt.format(c.createdAt)}): ${c.daysOfRest} dia(s)${c.cid != null && c.cid!.isNotEmpty ? " • CID ${c.cid}" : ""}',
                style: const pw.TextStyle(fontSize: 9),
              )),
          pw.SizedBox(height: 12),

          pw.Text('5. TCLE / CONSENTIMENTO LGPD', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.Text(
            tcle != null && tcle['accepted'] == true
                ? 'Termo assinado/aceito em ${tcle["acceptedAt"] ?? "data registrada"}.'
                : 'Termo pendente de assinatura.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
    return _saveDocument(doc, 'prontuario_completo', patient.fullName);
  }
}
