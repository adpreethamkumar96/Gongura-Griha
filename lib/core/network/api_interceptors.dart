import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../di/injection.dart';
import 'network_info.dart';

/// Auth Interceptor
///
/// Adds authentication token to requests and handles token refresh.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from secure storage
    // final token = await getIt<SecureStorageService>().getAccessToken();
    //
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }

    // Add device info headers
    options.headers['X-App-Version'] = '1.0.0';
    options.headers['X-Platform'] = defaultTargetPlatform.name.toLowerCase();

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 - Token expired
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      // final refreshed = await _refreshToken();
      // if (refreshed) {
      //   // Retry the request
      //   final response = await _retry(err.requestOptions);
      //   return handler.resolve(response);
      // }
    }

    handler.next(err);
  }
}

/// Logging Interceptor
///
/// Logs all HTTP requests and responses in debug mode.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────────────');
      debugPrint('│ REQUEST: ${options.method} ${options.uri}');
      debugPrint('│ Headers: ${options.headers}');
      if (options.data != null) {
        debugPrint('│ Data: ${options.data}');
      }
      debugPrint('└─────────────────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────────────');
      debugPrint('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('│ Data: ${response.data}');
      debugPrint('└─────────────────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────────────');
      debugPrint('│ ERROR: ${err.type} ${err.requestOptions.uri}');
      debugPrint('│ Message: ${err.message}');
      if (err.response != null) {
        debugPrint('│ Status: ${err.response?.statusCode}');
        debugPrint('│ Data: ${err.response?.data}');
      }
      debugPrint('└─────────────────────────────────────────────────────────');
    }
    handler.next(err);
  }
}

/// Error Interceptor
///
/// Handles network connectivity errors.
class ErrorInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check network connectivity before making request
    final networkInfo = getIt<NetworkInfo>();
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        ),
      );
    }

    handler.next(options);
  }
}

/// Retry Interceptor
///
/// Retries failed requests with exponential backoff.
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;

    // Only retry on specific errors
    final shouldRetry = _shouldRetry(err) && retryCount < maxRetries;

    if (shouldRetry) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      // Exponential backoff
      final delay = retryDelay * (retryCount + 1);
      await Future<void>.delayed(delay);

      try {
        final dio = Dio();
        final response = await dio.fetch<dynamic>(err.requestOptions);
        return handler.resolve(response);
      } on DioException {
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}
