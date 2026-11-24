import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:promt/core/router/app_router.dart';
import 'package:promt/core/theme/app_theme.dart';
import 'package:promt/core/theme/theme_viewmodel.dart';
import 'package:promt/core/network/sync_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });

    // Inicializa localização e define como padrão
    await initializeDateFormatting('pt_BR', null);
    Intl.defaultLocale = 'pt_BR';

    final container = ProviderContainer();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        container.read(syncServiceProvider).startAutoSync();
      } catch (e) {
        debugPrint('Erro ao iniciar SyncService: $e');
      }
    });

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const OdontoClinicaApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('Erro fatal na inicialização: $e');
    debugPrint(stack.toString());
  }
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
