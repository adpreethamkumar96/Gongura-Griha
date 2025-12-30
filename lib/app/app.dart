import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme/app_theme.dart';

/// Main App Widget
///
/// The root widget of the Gongura-Griha application.
class GonguraGrihaApp extends StatelessWidget {
  const GonguraGrihaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(bloc): Wrap with MultiBlocProvider when BLoCs are implemented
    // return MultiBlocProvider(
    //   providers: [
    //     BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
    //     BlocProvider<CartBloc>(create: (_) => getIt<CartBloc>()),
    //   ],
    //   child: _buildMaterialApp(),
    // );
    return _buildMaterialApp();
  }

  Widget _buildMaterialApp() {
    return MaterialApp.router(
      title: 'Gongura-Griha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: createRouter(),
    );
  }
}
