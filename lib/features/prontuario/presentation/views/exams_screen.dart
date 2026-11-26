import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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

  String _typeLabel(AttachmentType type) {
    return switch (type) {
      AttachmentType.xRay => 'Radiografia',
      AttachmentType.image => 'Foto Clínica',
      AttachmentType.document => 'Documento / Laudo',
      AttachmentType.video => 'Vídeo',
      AttachmentType.other => 'Outro',
    };
  }

  Widget _buildImage(Attachment attachment, {BoxFit fit = BoxFit.cover}) {
    final localPath = attachment.localPath;
    if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
      return Image.file(
        File(localPath),
        fit: fit,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
    final remoteUrl = attachment.remoteUrl;
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return Image.network(
        remoteUrl,
        fit: fit,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
    return const Center(child: Icon(Icons.insert_drive_file_outlined, size: 40, color: Colors.blueGrey));
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
          _isUploading ? 'Enviando...' : 'Anexar Exame',
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
      body: attachmentsAsync.when(
        data: (attachments) => attachments.isEmpty
            ? const Center(child: Text('Nenhuma radiografia ou foto disponível.'))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: attachments.length,
                itemBuilder: (context, index) => _buildAttachmentCard(attachments[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
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
                  _buildImage(attachment),
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
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tirar Foto Clínica'),
              onTap: () {
                Navigator.pop(context);
                _handleImageUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Selecionar Imagem / Radiografia'),
              onTap: () {
                Navigator.pop(context);
                _handleImageUpload(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImageUpload(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1920,
    );

    if (photo != null) {
      final type = await _selectAttachmentType();
      if (type != null && mounted) {
        setState(() => _isUploading = true);
        try {
          await ref
              .read(attachmentViewModelProvider(widget.patientId).notifier)
              .uploadFile(File(photo.path), type);
          ref.invalidate(prontuarioSummaryProvider(widget.patientId));
          ref.invalidate(clinicalTimelineProvider(widget.patientId));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Exame anexado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao anexar exame: $e'), backgroundColor: Colors.red),
            );
          }
        } finally {
          if (mounted) setState(() => _isUploading = false);
        }
      }
    }
  }

  Future<AttachmentType?> _selectAttachmentType() async {
    return showDialog<AttachmentType>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Categoria do Exame'),
        children: AttachmentType.values.map((type) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, type),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(_typeLabel(type)),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAttachmentFullScreen(Attachment attachment) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text('${attachment.name} • ${DateFormat('dd/MM/yyyy').format(attachment.date)}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  await ref
                      .read(attachmentViewModelProvider(widget.patientId).notifier)
                      .removeAttachment(attachment.id);
                  ref.invalidate(prontuarioSummaryProvider(widget.patientId));
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
          body: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            child: Center(child: _buildImage(attachment, fit: BoxFit.contain)),
          ),
        ),
      ),
    );
  }
}
