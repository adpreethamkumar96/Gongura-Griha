import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'core/di/injection.dart';

/// Development entry point
///
/// Run with: flutter run -t lib/main_development.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize configuration for development
  AppConfig.init(Environment.development);

  // Initialize dependencies
  await configureDependencies();

  // Run the app
  runApp(const GonguraGrihaApp());
}
