import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/user_management_viewmodel.dart';
import '../../../auth/domain/entities/user.dart';

/// Tela de gestão de usuários do sistema.
/// Apenas acessível por Administradores e Coordenadores.
class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userManagementViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Buscar por nome ou e-mail...',
              leading: const Icon(Icons.search),
              onChanged: (value) => ref.read(userManagementViewModelProvider.notifier).search(value),
            ),
          ),
          Expanded(
            child: usersAsync.when(
              data: (users) => users.isEmpty
                  ? const Center(child: Text('Nenhum usuário encontrado.'))
                  : ListView.separated(
                      itemCount: users.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(user.name.substring(0, 1).toUpperCase()),
                          ),
                          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${user.email} • ${user.role.displayName}'),
                          trailing: Switch(
                            value: user.isActive,
                            onChanged: (val) => ref
                                .read(userManagementViewModelProvider.notifier)
                                .toggleStatus(user.id, val),
                          ),
                          onTap: () {
                            // Editar usuário
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/dashboard/users/add'),
        label: const Text('Novo Usuário'),
        icon: const Icon(Icons.person_add_alt_1),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return ListTile(
              title: Text(role.displayName),
              onTap: () {
                ref.read(userManagementViewModelProvider.notifier).filterByRole(role);
                Navigator.pop(context);
              },
            );
          }).toList()
            ..insert(
                0,
                ListTile(
                  title: const Text('Todos'),
                  onTap: () {
                    ref.read(userManagementViewModelProvider.notifier).filterByRole(null);
                    Navigator.pop(context);
                  },
                )),
        ),
      ),
    );
  }
}
