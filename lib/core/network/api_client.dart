import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'api_interceptors.dart';

/// API Client
///
/// Wrapper around Dio for making HTTP requests.
/// Handles all network communication with the backend.
class ApiClient {
  late final Dio _dio;
  final String baseUrl;

  ApiClient({required this.baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Multipart POST request (for file uploads)
  Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Handle Dio exceptions and convert to app exceptions
  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);

      case DioExceptionType.cancel:
        return const ServerException(message: 'Request cancelled');

      default:
        return ServerException(
          message: e.message ?? 'An error occurred',
        );
    }
  }

  /// Handle bad response from server
  AppException _handleBadResponse(Response<dynamic>? response) {
    if (response == null) {
      return const ServerException();
    }

    final statusCode = response.statusCode;
    final data = response.data;

    String message = 'Server error';
    String? code;
    Map<String, dynamic>? errors;

    if (data is Map<String, dynamic>) {
      message = (data['message'] as String?) ?? message;
      code = data['error']?['code'] as String?;
      errors = data['error']?['details'] as Map<String, dynamic>?;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message, fieldErrors: _parseFieldErrors(errors));
      case 401:
        if (code == 'TOKEN_EXPIRED') {
          return const TokenExpiredException();
        }
        return AuthException(message);
      case 403:
        return PermissionException(message);
      case 404:
        return NotFoundException(message);
      case 429:
        return const RateLimitException();
      case 500:
      case 502:
      case 503:
        return ServerException(message: message, statusCode: statusCode);
      default:
        return ServerException(message: message, statusCode: statusCode);
    }
  }

  /// Parse field errors from response
  Map<String, String>? _parseFieldErrors(dynamic errors) {
    if (errors == null) return null;

    if (errors is List) {
      final Map<String, String> fieldErrors = {};
      for (final error in errors) {
        if (error is Map<String, dynamic>) {
          final field = error['field'] as String?;
          final message = error['message'] as String?;
          if (field != null && message != null) {
            fieldErrors[field] = message;
          }
        }
      }
      return fieldErrors.isEmpty ? null : fieldErrors;
    }

    return null;
  }
}
