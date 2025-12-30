/// Base Exception class
///
/// All custom exceptions extend from this class.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server Exception
///
/// Thrown when the server returns an error response.
class ServerException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ServerException({
    String message = 'Server error',
    String? code,
    this.statusCode,
    this.errors,
  }) : super(message, code: code);

  @override
  String toString() =>
      'ServerException: $message (statusCode: $statusCode, code: $code)';
}

/// Network Exception
///
/// Thrown when there's no internet connection.
class NetworkException extends AppException {
  const NetworkException()
      : super('No internet connection', code: 'NETWORK_ERROR');
}

/// Cache Exception
///
/// Thrown when there's an error with local cache.
class CacheException extends AppException {
  const CacheException([String message = 'Cache error'])
      : super(message, code: 'CACHE_ERROR');
}

/// Authentication Exception
///
/// Thrown when authentication fails.
class AuthException extends AppException {
  const AuthException([String message = 'Authentication failed'])
      : super(message, code: 'AUTH_ERROR');
}

/// Token Expired Exception
///
/// Thrown when the access token has expired.
class TokenExpiredException extends AppException {
  const TokenExpiredException()
      : super('Session expired. Please login again.', code: 'TOKEN_EXPIRED');
}

/// Validation Exception
///
/// Thrown when input validation fails.
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    String message, {
    this.fieldErrors,
  }) : super(message, code: 'VALIDATION_ERROR');
}

/// Not Found Exception
///
/// Thrown when a resource is not found.
class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found'])
      : super(message, code: 'NOT_FOUND');
}

/// Timeout Exception
///
/// Thrown when a request times out.
class TimeoutException extends AppException {
  const TimeoutException()
      : super('Request timed out. Please try again.', code: 'TIMEOUT');
}

/// Rate Limit Exception
///
/// Thrown when API rate limit is exceeded.
class RateLimitException extends AppException {
  final int? retryAfter;

  const RateLimitException({this.retryAfter})
      : super('Too many requests. Please try again later.', code: 'RATE_LIMIT');
}

/// Payment Exception
///
/// Thrown when payment processing fails.
class PaymentException extends AppException {
  final int? paymentErrorCode;

  const PaymentException({
    String message = 'Payment failed',
    this.paymentErrorCode,
  }) : super(message, code: 'PAYMENT_ERROR');
}

/// Permission Exception
///
/// Thrown when user doesn't have required permission.
class PermissionException extends AppException {
  const PermissionException([String message = 'Permission denied'])
      : super(message, code: 'PERMISSION_ERROR');
}
