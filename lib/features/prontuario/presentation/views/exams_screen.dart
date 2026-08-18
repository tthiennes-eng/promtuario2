import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../viewmodels/attachment_viewmodel.dart';
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

  @override
  Widget build(BuildContext context) {
    final attachmentsAsync = ref.watch(attachmentViewModelProvider(widget.patientId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Exames & Fotos"),
            Text(widget.patientName, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadOptions(),
        label: const Text('Anexar Exame'),
        icon: const Icon(Icons.upload_file),
      ),
      body: attachmentsAsync.when(
        data: (attachments) => attachments.isEmpty
            ? const Center(child: Text('Nenhuma radiografia ou foto disponível.'))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: attachments.length,
                itemBuilder: (context, index) {
                  final attachment = attachments[index];
                  return _buildAttachmentCard(attachment);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
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
              child: Image.network(
                attachment.url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.type.name.toUpperCase(),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  Text(
                    DateFormat('dd/MM/yy').format(attachment.date),
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
              title: const Text('Carregar da Galeria'),
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
      imageQuality: 70,
      maxWidth: 1920,
    );

    if (photo != null) {
      final type = await _selectAttachmentType();
      if (type != null && mounted) {
        await ref.read(attachmentViewModelProvider(widget.patientId).notifier)
            .uploadFile(File(photo.path), type);
      }
    }
  }

  Future<AttachmentType?> _selectAttachmentType() async {
    return showDialog<AttachmentType>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Tipo de Anexo'),
        children: AttachmentType.values.map((type) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, type),
            child: Text(type.name.toUpperCase()),
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
            title: Text('${attachment.name} - ${DateFormat('dd/MM/yyyy').format(attachment.date)}'),
            actions: [
              IconButton(icon: const Icon(Icons.download), onPressed: () {}),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  ref.read(attachmentViewModelProvider(widget.patientId).notifier).removeAttachment(attachment.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: InteractiveViewer(
            child: Center(
              child: Image.network(
                attachment.url,
                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 64)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
