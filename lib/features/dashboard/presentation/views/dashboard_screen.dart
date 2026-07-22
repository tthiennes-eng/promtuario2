import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/theme/app_theme.dart';
import 'package:promt/features/auth/domain/entities/user.dart';
import 'package:promt/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:promt/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final dashboardAsync = ref.watch(dashboardViewModelProvider);
    final user = authState.user;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final menuItems = _getMenuItems(user?.role);

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              extended: true,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                final route = menuItems[index]['route'] as String?;
                if (route != null) {
                  context.push(route);
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              leading: _buildRailHeader(context),
              destinations: menuItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item['icon'] as IconData),
                  selectedIcon: Icon(item['selectedIcon'] as IconData),
                  label: Text(item['label'] as String),
                );
              }).toList(),
            ),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, user),
                Expanded(
                  child: dashboardAsync.when(
                    data: (stats) => _buildContent(stats, user),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => _buildErrorState(err.toString()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                final route = menuItems[index]['route'] as String?;
                if (route != null) {
                  context.push(route);
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              destinations: menuItems.take(4).map((item) {
                return NavigationDestination(
                  icon: Icon(item['icon'] as IconData),
                  label: item['label'] as String,
                );
              }).toList(),
            )
          : null,
    );
  }

  List<Map<String, dynamic>> _getMenuItems(UserRole? role) {
    final List<Map<String, dynamic>> items = [
      {
        'label': 'Início',
        'icon': Icons.dashboard_outlined,
        'selectedIcon': Icons.dashboard,
        'route': null,
      },
      {
        'label': 'Agenda',
        'icon': Icons.calendar_today_outlined,
        'selectedIcon': Icons.calendar_today,
        'route': '/dashboard/agenda',
      },
      {
        'label': 'Pacientes',
        'icon': Icons.people_outline,
        'selectedIcon': Icons.people,
        'route': '/dashboard/patients',
      },
    ];

    if (role == UserRole.admin || role == UserRole.coordenador) {
      items.add({
        'label': 'Relatórios',
        'icon': Icons.bar_chart_outlined,
        'selectedIcon': Icons.bar_chart,
        'route': '/dashboard/reports',
      });
      items.add({
        'label': 'Usuários',
        'icon': Icons.manage_accounts_outlined,
        'selectedIcon': Icons.manage_accounts,
        'route': '/dashboard/users',
      });
    }

    items.add({
      'label': 'Configurações',
      'icon': Icons.settings_outlined,
      'selectedIcon': Icons.settings,
      'route': '/dashboard/settings',
    });

    return items;
  }

  Widget _buildRailHeader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.medical_services, size: 40, color: Color(0xFF006494)),
        const SizedBox(height: 10),
        const Text('Odonto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Sistema de Gestão Clínica', 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => context.push('/dashboard/notifications')),
          const SizedBox(width: 8),
          _buildUserAvatar(context, user),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, User? user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U'),
        ),
        if (MediaQuery.of(context).size.width > 700) ...[
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.name ?? 'Usuário', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(user?.role.displayName ?? 'Perfil', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContent(dynamic stats, User? user) {
    final screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá, ${user?.name.split(' ').first ?? 'Bem-vindo'}!', 
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF006494))),
            const Text('Resumo das atividades do dia.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: screenWidth > 1200 ? 4 : (screenWidth > 800 ? 2 : 1),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: screenWidth > 800 ? 1.5 : 2.5,
              children: [
                _buildStatCard('Pacientes', stats.totalPatients.toString(), Icons.group, Colors.blue),
                _buildStatCard('Consultas', stats.appointmentsToday.toString(), Icons.event_note, Colors.green),
                _buildStatCard('Atendimentos', stats.proceduresThisMonth.toString(), Icons.medical_information, Colors.orange),
                _buildStatCard('Alertas', stats.pendingAlerts.toString(), Icons.warning_amber, Colors.red),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Acesso Rápido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildQuickAction('Novo Paciente', Icons.person_add, Colors.blue, () => context.push('/dashboard/patients/add')),
                _buildQuickAction('Lista de Pacientes', Icons.format_list_bulleted, Colors.indigo, () => context.push('/dashboard/patients')),
                _buildQuickAction('Nova Consulta', Icons.add_alarm, Colors.green, () => context.push('/dashboard/agenda/add')),
                if (user?.role == UserRole.admin)
                  _buildQuickAction('Auditoria', Icons.security, Colors.blueGrey, () => context.push('/dashboard/audit-logs')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          Text('Erro: $message'),
          TextButton(onPressed: () => ref.read(dashboardViewModelProvider.notifier).refresh(), child: const Text('Tentar Novamente')),
        ],
      ),
    );
  }
}
