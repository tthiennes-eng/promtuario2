import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/network/realtime_service.dart';

/// Ponto de entrada principal do sistema OdontoClinica Universitária.
/// Inicializa as configurações globais, injeção de dependência e roteamento.
void main() async {
  // Garante que o binding do Flutter esteja inicializado antes de qualquer operação assíncrona.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a formatação de datas para Português do Brasil.
  await initializeDateFormatting('pt_BR', null);

  // Tratamento global de erros para produção (Segurança e Estabilidade)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Em produção, integrado com Sentry ou Crashlytics.
  };

  // Cria o container do Riverpod para inicializações pré-runApp
  final container = ProviderContainer();
  
  // Tenta inicializar a conexão em tempo real (SignalR)
  // Essencial para o requisito de Odontograma Interativo em tempo real.
  try {
    await container.read(realtimeServiceProvider).init();
  } catch (e) {
    debugPrint('Erro ao conectar ao Realtime Service: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const OdontoClinicaApp(),
    ),
  );
}

class OdontoClinicaApp extends ConsumerWidget {
  const OdontoClinicaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta as mudanças no roteador (GoRouter) configurado no core.
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'OdontoClinica Universitária',
      debugShowCheckedModeBanner: false,
      
      // Configuração de Localização padrão (PT-BR)
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],

      // Design System Material 3
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Injeção da configuração de roteamento.
      routerConfig: router,
    );
  }
}
