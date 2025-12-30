import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'core/di/injection.dart';

/// Staging entry point
///
/// Run with: flutter run -t lib/main_staging.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize configuration for staging
  AppConfig.init(Environment.staging);

  // Initialize dependencies
  await configureDependencies();

  // Run the app
  runApp(const GonguraGrihaApp());
}
