import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';

import '../core/di/injection.dart';
import '../core/providers/locale_provider.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

/// Global locale provider instance
final localeProvider = LocaleProvider();

/// Main App Widget
///
/// The root widget of the Gongura-Griha application.
class GonguraGrihaApp extends StatefulWidget {
  const GonguraGrihaApp({super.key});

  @override
  State<GonguraGrihaApp> createState() => _GonguraGrihaAppState();
}

class _GonguraGrihaAppState extends State<GonguraGrihaApp> {
  StreamSubscription<User?>? _authSubscription;
  late final _router = createRouter();

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Listen to auth state changes for wishlist cloud sync
    _authSubscription = authService.authStateChanges.listen((user) {
      if (user != null) {
        // User logged in - start cloud sync
        wishlistRepository.startCloudSync(user.uid);
      } else {
        // User logged out - stop cloud sync
        wishlistRepository.stopCloudSync();
      }
    });

    // Check if user is already logged in
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      wishlistRepository.startCloudSync(currentUser.uid);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

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
      routerConfig: _router,

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
