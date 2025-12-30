import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'core/di/injection.dart';

/// Main entry point - defaults to production
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize configuration for production
  AppConfig.init(Environment.production);

  // Initialize dependencies
  await configureDependencies();

  // Run the app
  runApp(const GonguraGrihaApp());
}
