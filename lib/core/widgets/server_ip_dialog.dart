import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';

/// Diálogo reutilizável para configurar o IP do servidor.
void showServerIpDialog(BuildContext context, WidgetRef ref) {
  final currentIp = ref.read(serverIpProvider);
  final controller = TextEditingController(text: currentIp);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.dns_outlined, color: Color(0xFF006494)),
          SizedBox(width: 12),
          Text('Configurar Servidor'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informe o endereço IP do computador que está rodando o servidor na sua rede.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'IP ou Host do Servidor',
              hintText: 'ex: 192.168.0.3',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.computer),
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final newIp = controller.text.trim();
            if (newIp.isNotEmpty) {
              ref.read(serverIpProvider.notifier).updateIp(newIp);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Servidor configurado para: $newIp'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006494),
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar Configuração'),
        ),
      ],
    ),
  );
}
