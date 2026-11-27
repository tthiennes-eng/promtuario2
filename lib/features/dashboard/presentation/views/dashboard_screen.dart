import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/auth/domain/entities/user.dart';
import 'package:promt/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:promt/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:promt/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/dashboard/presentation/viewmodels/statistical_studies_viewmodel.dart';
import 'package:promt/features/dashboard/presentation/widgets/statistical_panel_widget.dart';

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
    final dashboardAsync = ref.watch(dashboardSummaryProvider);
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
                    loading: () => const Center(
                      child: SizedBox.square(
                        dimension: 28,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    ),
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
        const Text(
          'Odonto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notificações',
            onPressed: () => context.push('/dashboard/notifications'),
          ),
          const SizedBox(width: 8),
          _buildUserAvatar(context, user),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Sair / Trocar usuário',
            onPressed: () => ref.read(authViewModelProvider.notifier).logout(),
          ),
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
          child: Text(
            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
          ),
        ),
        if (MediaQuery.of(context).size.width > 700) ...[
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? 'Usuário',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                user?.role.displayName ?? 'Perfil',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContent(DashboardSummary stats, User? user) {
    final screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dashboardSummaryProvider);
        ref.invalidate(statisticalStudiesProvider);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.name.isNotEmpty == true
                  ? 'Olá, ${user!.name.split(' ').first}!'
                  : 'Olá!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006494),
              ),
            ),
            const Text(
              'Resumo das atividades do dia.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: screenWidth > 800 ? 3 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: screenWidth > 800 ? 1.5 : 2.0,
              children: [
                _buildStatCard(
                  'Pacientes',
                  stats.totalPacientes.toString(),
                  Icons.group,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Agendamentos hoje',
                  stats.agendamentosHoje.toString(),
                  Icons.event_note,
                  Colors.green,
                  onTap: () => _showAppointmentsToday(context),
                ),
                _buildStatCard(
                  'Atendimentos',
                  stats.atendimentos.toString(),
                  Icons.medical_information,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Acesso Rápido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildQuickAction(
                  'Agenda Clínica',
                  Icons.calendar_month,
                  Colors.blue,
                  () => context.push('/dashboard/agenda'),
                ),
                _buildQuickAction(
                  'Visão Institucional',
                  Icons.grid_view,
                  Colors.purple,
                  () => context.push('/dashboard/agenda/institutional'),
                ),
                _buildQuickAction(
                  'Lista de Pacientes',
                  Icons.format_list_bulleted,
                  Colors.indigo,
                  () => context.push('/dashboard/patients'),
                ),
                if (user?.role == UserRole.admin)
                  _buildQuickAction(
                    'Auditoria',
                    Icons.security,
                    Colors.blueGrey,
                    () => context.push('/dashboard/audit-logs'),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            const StatisticalPanelWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentsToday(BuildContext context) {
    final appointmentsFuture = ref.read(allAppointmentsProvider.future);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Agendamentos de hoje'),
        content: SizedBox(
          width: 520,
          child: FutureBuilder<List<Appointment>>(
            future: appointmentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Text(
                  'Não foi possível carregar os agendamentos: ${snapshot.error}',
                );
              }

              final now = DateTime.now();
              final startOfDay = DateTime(now.year, now.month, now.day);
              final endOfDay = startOfDay.add(const Duration(days: 1));
              
              final todayAppointments = (snapshot.data ?? []).where((appointment) {
                // Garante que a comparação seja feita no fuso horário LOCAL
                final startTime = appointment.startTime.isUtc 
                    ? appointment.startTime.toLocal() 
                    : appointment.startTime;
                    
                final isToday = !startTime.isBefore(startOfDay) && startTime.isBefore(endOfDay);
                
                final status = appointment.status;
                final isCancelled = status == AppointmentStatus.cancelled ||
                    status == AppointmentStatus.noShow ||
                    status == AppointmentStatus.missed;
                    
                return isToday && !isCancelled;
              }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

              if (todayAppointments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('Não há agendamentos para hoje.'),
                );
              }

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: todayAppointments.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final appointment = todayAppointments[index];
                    final responsible = appointment.studentName?.trim().isNotEmpty == true
                        ? appointment.studentName!
                        : appointment.doctorName;
                    final procedure = appointment.procedureName?.trim();

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.12),
                        child: const Icon(Icons.person_outline, color: Colors.green),
                      ),
                      title: Text(
                        appointment.patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${DateFormat('HH:mm').format(appointment.startTime.toLocal())}'
                          '${procedure != null && procedure.isNotEmpty ? ' • $procedure' : ''}'
                          '\nResponsável: $responsible'
                          '\nStatus: ${appointment.status.displayName}',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
            ),
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
          TextButton(
            onPressed: () => ref.invalidate(dashboardSummaryProvider),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}
