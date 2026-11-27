import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promt/core/network/api_client.dart';
import '../viewmodels/attachment_viewmodel.dart';
import '../viewmodels/prontuario_summary_provider.dart';
import '../../domain/entities/attachment.dart';

class ExamsScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const ExamsScreen({super.key, required this.patientId, required this.patientName});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String _filter = 'all'; // all, images, texts

  static const _allowedImageExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic',
  ];

  static const _allowedTextAndDocExtensions = [
    'txt', 'md', 'csv', 'json', 'xml', 'log', 'rtf', 'pdf', 'doc', 'docx',
  ];

  String _typeLabel(AttachmentType type) {
    return switch (type) {
      AttachmentType.xRay => 'Radiografia',
      AttachmentType.image => 'Foto Clínica',
      AttachmentType.document => 'Texto / Laudo',
      AttachmentType.video => 'Vídeo',
      AttachmentType.other => 'Outro',
    };
  }

  Widget _buildAuthenticatedRemoteImage(String remoteUrl, {required BoxFit fit, double errorIconSize = 32}) {
    final dio = ref.read(apiClientProvider).instance;
    return FutureBuilder<Response<List<int>>>(
      future: dio.get<List<int>>(remoteUrl, options: Options(responseType: ResponseType.bytes)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)));
        }
        final bytes = snapshot.data?.data;
        if (snapshot.hasError || bytes == null || bytes.isEmpty) {
          return Center(child: Icon(Icons.broken_image, color: Colors.grey, size: errorIconSize));
        }
        return Image.memory(
          Uint8List.fromList(bytes),
          fit: fit,
          errorBuilder: (_, __, ___) => Center(child: Icon(Icons.broken_image, color: Colors.grey, size: errorIconSize)),
        );
      },
    );
  }

  Widget _buildCardPreview(Attachment attachment) {
    if (attachment.isImageFile) {
      final localPath = attachment.localPath;
      if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
        return Image.file(
          File(localPath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        );
      }
      final remoteUrl = attachment.remoteUrl;
      if (remoteUrl != null && remoteUrl.isNotEmpty) {
        return _buildAuthenticatedRemoteImage(remoteUrl, fit: BoxFit.cover);
      }
    }

    final ext = attachment.fileExtension.isEmpty
        ? (attachment.isTextFile ? 'TXT' : 'DOC')
        : attachment.fileExtension.toUpperCase();
    final isText = attachment.isTextFile;
    final bgColor = isText ? Colors.blue.shade50 : Colors.amber.shade50;
    final fgColor = isText ? const Color(0xFF006494) : Colors.amber.shade900;
    final icon = isText ? Icons.description_outlined : Icons.picture_as_pdf_outlined;

    return Container(
      color: bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 42, color: fgColor),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: fgColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ext,
              style: TextStyle(color: fgColor, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullImage(Attachment attachment) {
    final localPath = attachment.localPath;
    if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
      return Image.file(
        File(localPath),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 64)),
      );
    }
    final remoteUrl = attachment.remoteUrl;
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return _buildAuthenticatedRemoteImage(remoteUrl, fit: BoxFit.contain, errorIconSize: 64);
    }
    return const Center(child: Icon(Icons.broken_image, size: 64));
  }

  Future<String> _loadTextContent(Attachment attachment) async {
    final localPath = attachment.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (await file.exists()) {
        return file.readAsString();
      }
    }
    final remoteUrl = attachment.remoteUrl;
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      final response = await ref.read(apiClientProvider).instance.get<String>(
        remoteUrl,
        options: Options(responseType: ResponseType.plain),
      );
      return response.data ?? '';
    }
    return 'Conteúdo do arquivo não disponível.';
  }

  Future<void> _openExternally(Attachment attachment) async {
    final target = (attachment.localPath != null &&
            attachment.localPath!.isNotEmpty &&
            File(attachment.localPath!).existsSync())
        ? attachment.localPath!
        : (attachment.remoteUrl ?? '');
    if (target.isEmpty) return;

    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', target]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [target]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [target]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o arquivo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachmentsAsync = ref.watch(attachmentViewModelProvider(widget.patientId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Exames & Fotos'),
            Text(widget.patientName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(attachmentViewModelProvider(widget.patientId)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF006494),
        onPressed: _isUploading ? null : _showUploadOptions,
        label: Text(
          _isUploading ? 'Enviando...' : 'Anexar Exame / Arquivo',
          style: const TextStyle(color: Colors.white),
        ),
        icon: _isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.upload_file, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _filter == 'all',
                  onSelected: (_) => setState(() => _filter = 'all'),
                ),
                ChoiceChip(
                  label: const Text('Imagens & Radiografias'),
                  selected: _filter == 'images',
                  onSelected: (_) => setState(() => _filter = 'images'),
                ),
                ChoiceChip(
                  label: const Text('Arquivos de Texto & Documentos'),
                  selected: _filter == 'texts',
                  onSelected: (_) => setState(() => _filter = 'texts'),
                ),
              ],
            ),
          ),
          Expanded(
            child: attachmentsAsync.when(
              data: (attachments) {
                final filtered = attachments.where((a) {
                  if (_filter == 'images') return a.isImageFile;
                  if (_filter == 'texts') return a.isTextFile || a.isDocumentFile || !a.isImageFile;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma imagem, radiografia ou arquivo de texto anexado.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildAttachmentCard(filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erro: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(Attachment attachment) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showAttachmentFullScreen(attachment),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCardPreview(attachment),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: attachment.isSynced ? Colors.green.shade700 : Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        attachment.isSynced ? 'Nuvem' : 'Local',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _typeLabel(attachment.type).toUpperCase(),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF006494)),
                  ),
                  Text(
                    attachment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(attachment.date),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF006494)),
              title: const Text('Selecionar Imagem / Radiografia'),
              subtitle: const Text('JPG, PNG, WEBP, BMP, GIF'),
              onTap: () {
                Navigator.pop(context);
                _handleFilePick(imagesOnly: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined, color: Color(0xFF006494)),
              title: const Text('Selecionar Arquivo de Texto / Laudo'),
              subtitle: const Text('TXT, MD, CSV, JSON, XML, PDF, DOC, DOCX'),
              onTap: () {
                Navigator.pop(context);
                _handleFilePick(imagesOnly: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined, color: Color(0xFF006494)),
              title: const Text('Escrever Laudo / Texto (.txt)'),
              subtitle: const Text('Criar e anexar um arquivo de texto diretamente no app'),
              onTap: () {
                Navigator.pop(context);
                _showCreateTextAttachmentDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.blueGrey),
              title: const Text('Tirar Foto Clínica (Câmera)'),
              onTap: () {
                Navigator.pop(context);
                _handleCameraUpload();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFilePick({required bool imagesOnly}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: imagesOnly ? _allowedImageExtensions : _allowedTextAndDocExtensions,
    );

    final path = result?.files.single.path;
    if (path == null || path.isEmpty) return;

    final file = File(path);
    final defaultType = imagesOnly ? AttachmentType.image : AttachmentType.document;
    final type = imagesOnly ? await _selectAttachmentType(initial: defaultType) : AttachmentType.document;
    if (type != null && mounted) {
      await _uploadFile(file, type, description: p.basename(path));
    }
  }

  Future<void> _handleCameraUpload() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1920,
    );
    if (photo == null) return;
    final type = await _selectAttachmentType(initial: AttachmentType.image);
    if (type != null && mounted) {
      await _uploadFile(File(photo.path), type, description: p.basename(photo.path));
    }
  }

  Future<void> _showCreateTextAttachmentDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Novo Arquivo de Texto / Laudo'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título do Arquivo',
                  hintText: 'Ex.: Laudo Radiográfico - Dente 16',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo do Texto / Laudo',
                  hintText: 'Digite aqui o laudo ou observações do exame...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final body = contentController.text.trim();
              if (body.isEmpty) return;

              final safeTitle = (title.isEmpty ? 'laudo_exame' : title)
                  .toLowerCase()
                  .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
                  .replaceAll(RegExp(r'^_+|_+$'), '');
              final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
              final dir = await getApplicationDocumentsDirectory();
              final textsDir = Directory(p.join(dir.path, 'OdontoClinica_Anexos'));
              if (!await textsDir.exists()) {
                await textsDir.create(recursive: true);
              }
              final fileName = '${safeTitle.isEmpty ? "laudo" : safeTitle}_$stamp.txt';
              final file = File(p.join(textsDir.path, fileName));
              await file.writeAsString(body);

              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (mounted) {
                await _uploadFile(
                  file,
                  AttachmentType.document,
                  description: title.isEmpty ? fileName : '$title.txt',
                );
              }
            },
            child: const Text('Salvar e Anexar'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFile(File file, AttachmentType type, {String? description}) async {
    setState(() => _isUploading = true);
    try {
      await ref
          .read(attachmentViewModelProvider(widget.patientId).notifier)
          .uploadFile(file, type, description: description);
      ref.invalidate(prontuarioSummaryProvider(widget.patientId));
      ref.invalidate(clinicalTimelineProvider(widget.patientId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arquivo anexado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao anexar arquivo: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<AttachmentType?> _selectAttachmentType({AttachmentType? initial}) async {
    return showDialog<AttachmentType>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Categoria do Anexo'),
        children: [
          AttachmentType.xRay,
          AttachmentType.image,
          AttachmentType.document,
          AttachmentType.other,
        ].map((type) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, type),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                _typeLabel(type),
                style: TextStyle(
                  fontWeight: type == initial ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAttachmentFullScreen(Attachment attachment) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text('${attachment.name} • ${DateFormat('dd/MM/yyyy').format(attachment.date)}'),
            actions: [
              if (!attachment.isImageFile)
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Abrir arquivo externamente',
                  onPressed: () => _openExternally(attachment),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  await ref
                      .read(attachmentViewModelProvider(widget.patientId).notifier)
                      .removeAttachment(attachment.id);
                  ref.invalidate(prontuarioSummaryProvider(widget.patientId));
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
          body: attachment.isImageFile
              ? InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: Center(child: _buildFullImage(attachment)),
                )
              : attachment.isTextFile
                  ? FutureBuilder<String>(
                      future: _loadTextContent(attachment),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Não foi possível ler o arquivo de texto: ${snapshot.error}'),
                          );
                        }
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: SelectableText(
                              snapshot.data ?? '',
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description_outlined, size: 72, color: Colors.amber.shade800),
                            const SizedBox(height: 16),
                            Text(
                              attachment.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Formato: ${attachment.fileExtension.toUpperCase()}',
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => _openExternally(attachment),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Abrir Documento'),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
