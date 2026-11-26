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
    final size = MediaQuery.of(context).size;
    final isWide = size.width > size.height;

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => showServerIpDialog(context, ref),
        tooltip: 'Configurar Servidor',
        child: const Icon(Icons.dns_outlined),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camada ambiente desfocada preenchendo toda a tela (evita barras laterais)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Transform.scale(
              scale: 1.08,
              child: Image.asset(
                'assets/images/login_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF006494),
                ),
              ),
            ),
          ),

          // 2. Imagem original ao fundo na proporção exata (764x1024, sem esticar nem distorcer)
          if (isWide)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 764,
                  height: 1024,
                  child: ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.white,
                        Colors.white,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.08, 0.92, 1.0],
                    ).createShader(rect),
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      'assets/images/login_background.png',
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            )
          else
            Image.asset(
              'assets/images/login_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),

          // 3. Gradiente suave para melhorar a leitura do formulário sobre a imagem
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.24),
                  Colors.black.withOpacity(0.42),
                ],
              ),
            ),
          ),

          // 4. Formulário de login centralizado sobre a imagem de fundo
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(30.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.65),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.24),
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(
                                Icons.medical_services_outlined,
                                size: 52,
                                color: Color(0xFF006494),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'OdontoClinica',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: const Color(0xFF006494),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.4,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bem-vindo de volta',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Acesse sua conta para gerenciar atendimentos e prontuários.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 28),
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
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                enabled: !authState.isLoading,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  if (!authState.isLoading) _handleLogin();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  prefixIcon: const Icon(Icons.lock_outline),
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
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Senha obrigatória (mín. 6 caracteres)'
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: authState.isLoading
                                        ? null
                                        : () => setState(
                                              () => _rememberMe = !_rememberMe,
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
                                    onPressed:
                                        authState.isLoading ? null : () {},
                                    child: const Text('Esqueceu a senha?'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              FilledButton(
                                onPressed:
                                    authState.isLoading ? null : _handleLogin,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: const Color(0xFF006494),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 10),
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
    );
  }
}
