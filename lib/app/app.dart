import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';

import '../core/providers/locale_provider.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

/// Global locale provider instance
final localeProvider = LocaleProvider();

/// Main App Widget
///
/// The root widget of the Gongura-Griha application.
class GonguraGrihaApp extends StatelessWidget {
  const GonguraGrihaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeProvider,
      builder: (context, child) {
        return _buildMaterialApp();
      },
    );
  }

  Widget _buildMaterialApp() {
    return MaterialApp.router(
      title: 'Gongura-Griha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: createRouter(),

      // Localization
      locale: localeProvider.locale,
      supportedLocales: LocaleProvider.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
