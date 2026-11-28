import 'dart:math' as math;
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

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => showServerIpDialog(context, ref),
        tooltip: 'Configurar Servidor',
        child: const Icon(Icons.dns_outlined),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final isLandscape = width >= height;

          // Dimensões reais dos assets recortados com o letreiro ODONTOLOGIA centralizado em x=50%:
          // Wide (1600x911):     faixa vermelha com ODONTOLOGIA termina em 24,7% da altura.
          // Portrait (900x1483): faixa vermelha com ODONTOLOGIA termina em 26,7% da altura.
          final imgW = isLandscape ? 1600.0 : 900.0;
          final imgH = isLandscape ? 911.0 : 1483.0;
          final fasciaBottomRatio = isLandscape ? 0.247 : 0.267;

          final coverScale = math.max(width / imgW, height / imgH);
          final renderedImgH = imgH * coverScale;
          final signBottomY = renderedImgH * fasciaBottomRatio;
          final safeTop = MediaQuery.of(context).padding.top;
          final cardTopOffset = math.max(12.0, signBottomY - safeTop + 14.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Imagem ao fundo ancorada no topo central para manter "ODONTOLOGIA" visível acima do login
              Image.asset(
                isLandscape
                    ? 'assets/images/login_background_wide.jpg'
                    : 'assets/images/login_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF006494),
                ),
              ),

              // 2. Gradiente leve no topo (para preservar o letreiro) e mais suave/escuro na base
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.30, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.16),
                      Colors.black.withValues(alpha: 0.42),
                    ],
                  ),
                ),
              ),

              // 3. Card de login posicionado logo abaixo do letreiro "ODONTOLOGIA" da fachada
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, cardTopOffset, 24, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 22,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.90),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.24),
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
                                    size: 36,
                                    color: Color(0xFF006494),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'OdontoClinica',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: const Color(0xFF006494),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.4,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Bem-vindo de volta',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Acesse sua conta para gerenciar atendimentos e prontuários.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
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
                                      isDense: true,
                                    ),
                                    validator: (v) =>
                                        (v == null || !v.contains('@'))
                                            ? 'E-mail institucional inválido'
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
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
                                      isDense: true,
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
                                    validator: (v) => (v == null || v.length < 6)
                                        ? 'Senha obrigatória (mín. 6 caracteres)'
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      InkWell(
                                        borderRadius: BorderRadius.circular(4),
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
                                              style: TextStyle(fontSize: 13.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: authState.isLoading
                                            ? null
                                            : _showForgotPasswordDialog,
                                        style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        child: const Text('Esqueceu a senha?'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  FilledButton(
                                    onPressed: authState.isLoading
                                        ? null
                                        : _handleLogin,
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
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
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
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
          );
        },
      ),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    bool sending = false;
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Recuperar Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informe seu e-mail institucional para registrar a solicitação de redefinição junto à coordenação.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail institucional',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: sending ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: sending
                  ? null
                  : () async {
                      final email = emailCtrl.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Informe um e-mail válido.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setDialogState(() => sending = true);
                      try {
                        final msg = await ref
                            .read(authViewModelProvider.notifier)
                            .requestPasswordReset(email);
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => sending = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Não foi possível enviar solicitação: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Solicitar'),
            ),
          ],
        ),
      ),
    );
    emailCtrl.dispose();
  }
}
