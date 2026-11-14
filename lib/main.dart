import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:promt/core/router/app_router.dart';
import 'package:promt/core/theme/app_theme.dart';
import 'package:promt/core/theme/theme_viewmodel.dart';
import 'package:promt/core/network/sync_service.dart';

/// Ponto de entrada principal do sistema OdontoClinica Universitária.
void main() async {
  // 1. Garante que binding do Flutter esteja inicializado.
  // Essencial para o carregamento estável de bibliotecas nativas (FFI/SQLite).
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configurações globais de Logs para depuração.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  // 3. Inicializa a formatação de datas.
  await initializeDateFormatting('pt_BR', null);

  // 4. Cria o container global do Riverpod.
  final container = ProviderContainer();
  
  // 5. INICIALIZAÇÃO SEGURA (Correção para crash de FFI/InvalidType):
  // O crash 'InvalidType' ocorre quando o compilador tenta resolver a ponte FFI
  // do SQLite prematuramente. Adiar o início da sincronização para o primeiro frame
  // permite que o ambiente de execução nativo e o isolate principal estejam estáveis.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    container.read(syncServiceProvider).startAutoSync();
  });

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
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeViewModelProvider);

    return MaterialApp.router(
      title: 'OdontoClinica Universitária',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
