import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'core/di/injection.dart';
import 'core/services/push_notification_service.dart';

/// Main entry point - uses development config in debug mode, production otherwise
void main() async {
  // Run everything in the same zone to avoid zone mismatch warnings
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Use development config in debug mode, production in release
    final environment = kDebugMode ? Environment.development : Environment.production;
    AppConfig.init(environment);

    // Register background message handler (must be before Firebase initialization)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize dependencies (includes Firebase and FCM)
    await configureDependencies();

    // Initialize Crashlytics
    await _initializeCrashlytics();

    // Seed initial data (only runs once per device)
    await seedInitialDataIfNeeded();
    await seedCouponsIfNeeded();

    // Run the app
    runApp(const GonguraGrihaApp());
  }, (error, stack) {
    // Log errors to Crashlytics (Firebase is now initialized)
    if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    debugPrint('Error: $error\n$stack');
  });
}

/// Initialize Firebase Crashlytics
Future<void> _initializeCrashlytics() async {
  // Disable Crashlytics in debug mode
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    debugPrint('Crashlytics disabled in debug mode');
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Pass all uncaught Flutter errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('Crashlytics initialized');
  }
}
