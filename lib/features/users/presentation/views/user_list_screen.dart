import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/user_management_viewmodel.dart';
import '../../../auth/domain/entities/user.dart';

/// Tela de gestão de usuários do sistema.
/// Apenas acessível por Administradores e Coordenadores.
class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(userManagementViewModelProvider.notifier).search(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userManagementViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
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
              onChanged: _onSearchChanged,
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
                            child: Text(
                              user.name.trim().isNotEmpty
                                  ? user.name.trim().substring(0, 1).toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${user.email} • ${user.role.displayName}'),
                          trailing: Switch(
                            value: user.isActive,
                            onChanged: (val) => ref
                                .read(userManagementViewModelProvider.notifier)
                                .toggleStatus(user.id, val),
                          ),
                          onTap: () => _showEditRoleDialog(context, user),
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

  void _showEditRoleDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Alterar Perfil: ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            final isSelected = role == user.role;
            return ListTile(
              title: Text(role.displayName),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () async {
                Navigator.pop(dialogCtx);
                if (role == user.role) return;
                try {
                  await ref.read(userManagementViewModelProvider.notifier).updateRole(user.id, role);
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('Perfil de ${user.name} atualizado para ${role.displayName}.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao alterar perfil: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
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
