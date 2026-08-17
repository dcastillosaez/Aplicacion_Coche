import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/mantenimiento_providers.dart';
import 'providers/recalculo_al_reanudar.dart';
import 'ui/shell/app_shell.dart';
import 'ui/theme/app_theme.dart';

class CarCareApp extends ConsumerWidget {
  const CarCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ajustes = ref.watch(ajustesProvider);

    return MaterialApp(
      title: 'Mis Vehículos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(),
      darkTheme: AppTheme.oscuro(),
      themeMode: AppTheme.modoDesdeTema(ajustes.valueOrNull?.tema),
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RecalculoAlReanudar(child: AppShell()),
    );
  }
}
