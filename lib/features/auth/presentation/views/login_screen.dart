import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/security/storage_service.dart';
import '../../../../core/widgets/server_ip_dialog.dart';

/// Tela de Login profissional com Material 3.
/// Implementa validações rigorosas e integração completa com o backend.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true; // Opção de manter login salvo

  @override
  void initState() {
    super.initState();
    _loadSavedLoginPreferences();
  }

  Future<void> _loadSavedLoginPreferences() async {
    try {
      final storage = ref.read(storageServiceProvider);
      final remember = await storage.getRememberMe();
      final savedEmail = await storage.getSavedEmail();
      final savedPassword = await storage.getSavedPassword();
      if (!mounted) return;
      setState(() {
        _rememberMe = remember;
        if (remember) {
          if (savedEmail != null && savedEmail.isNotEmpty) {
            _emailController.text = savedEmail;
          }
          if (savedPassword != null && savedPassword.isNotEmpty) {
            _passwordController.text = savedPassword;
          }
        }
      });
    } catch (e) {
      debugPrint('Erro ao carregar credenciais salvas: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authViewModelProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
            rememberMe: _rememberMe,
          );

      if (!mounted) return;

      final state = ref.read(authViewModelProvider);
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => showServerIpDialog(context, ref),
        tooltip: 'Configurar Servidor',
        child: const Icon(Icons.dns_outlined),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagem de fundo em tela cheia (fachada Odontologia)
          Image.asset(
            'assets/images/login_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF006494),
            ),
          ),

          // Sobreposição suave para melhorar o contraste mantendo a imagem visível
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.18),
                  Colors.black.withOpacity(0.32),
                  Colors.black.withOpacity(0.50),
                ],
              ),
            ),
          ),

          // Conteúdo principal sobre a imagem
          SafeArea(
            child: Row(
              children: [
                if (isWide)
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.22),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.health_and_safety,
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'OdontoClinica',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const Text(
                                    'Gestão Clínica Universitária',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: isWide ? 5 : 1,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.all(32.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.22),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Icon(
                                      Icons.medical_services_outlined,
                                      size: 56,
                                      color: Color(0xFF006494),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Bem-vindo de volta',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Acesse sua conta para gerenciar atendimentos e prontuários.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    const SizedBox(height: 32),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      enabled: !authState.isLoading,
                                      decoration: const InputDecoration(
                                        labelText: 'E-mail Institucional',
                                        prefixIcon: Icon(Icons.email_outlined),
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      validator: (v) =>
                                          (v == null || !v.contains('@'))
                                              ? 'E-mail institucional inválido'
                                              : null,
                                    ),
                                    const SizedBox(height: 18),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      enabled: !authState.isLoading,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) {
                                        if (!authState.isLoading) {
                                          _handleLogin();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Senha',
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                        border: const OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.white,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                      ),
                                      validator: (v) =>
                                          (v == null || v.length < 6)
                                              ? 'Senha obrigatória (mín. 6 caracteres)'
                                              : null,
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        InkWell(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          onTap: authState.isLoading
                                              ? null
                                              : () => setState(
                                                    () => _rememberMe =
                                                        !_rememberMe,
                                                  ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: Checkbox(
                                                  value: _rememberMe,
                                                  onChanged: authState.isLoading
                                                      ? null
                                                      : (val) => setState(
                                                            () => _rememberMe =
                                                                val ?? true,
                                                          ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Manter login salvo',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: authState.isLoading
                                              ? null
                                              : () {},
                                          child:
                                              const Text('Esqueceu a senha?'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    FilledButton(
                                      onPressed: authState.isLoading
                                          ? null
                                          : _handleLogin,
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        backgroundColor:
                                            const Color(0xFF006494),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: authState.isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Entrar no Sistema',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Divider(),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Acesso restrito a alunos, professores e funcionários autorizados pela universidade.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
