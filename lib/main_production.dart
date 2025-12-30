import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'core/di/injection.dart';

/// Production entry point
///
/// Run with: flutter run -t lib/main_production.dart --release
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for production
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize configuration for production
  AppConfig.init(Environment.production);

  // Initialize dependencies
  await configureDependencies();

  // Run the app
  runApp(const GonguraGrihaApp());
}
