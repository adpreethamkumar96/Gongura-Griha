import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_config.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';

/// Global service locator instance
final getIt = GetIt.instance;

/// Initialize all dependencies
///
/// This must be called before running the app.
Future<void> configureDependencies() async {
  // ============ External Dependencies ============

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Connectivity
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // ============ Core Dependencies ============

  // Network Info
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );

  // API Client
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: AppConfig.apiBaseUrl),
  );

  // ============ Repositories ============

  // TODO: Register repositories here
  // Example:
  // getIt.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     remoteDataSource: getIt(),
  //     localDataSource: getIt(),
  //     networkInfo: getIt(),
  //   ),
  // );

  // ============ Use Cases ============

  // TODO: Register use cases here
  // Example:
  // getIt.registerLazySingleton(() => LoginUseCase(getIt()));

  // ============ BLoCs ============

  // TODO: Register BLoCs here
  // Example:
  // getIt.registerFactory(() => AuthBloc(
  //   loginUseCase: getIt(),
  //   logoutUseCase: getIt(),
  // ));
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
