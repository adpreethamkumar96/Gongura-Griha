import 'package:equatable/equatable.dart';

/// Base Failure class
///
/// All failure types extend from this class.
/// Used for error handling in the domain layer.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server Failure
///
/// Returned when there's an error from the API server.
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred', String? code])
      : super(message, code: code);
}

/// Network Failure
///
/// Returned when there's no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure([
    String message = 'No internet connection. Please check your network.',
  ]) : super(message, code: 'NETWORK_ERROR');
}

/// Cache Failure
///
/// Returned when there's an error reading/writing to cache.
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred'])
      : super(message, code: 'CACHE_ERROR');
}

/// Authentication Failure
///
/// Returned when there's an authentication error.
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed'])
      : super(message, code: 'AUTH_ERROR');
}

/// Validation Failure
///
/// Returned when input validation fails.
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(
    String message, {
    this.fieldErrors,
  }) : super(message, code: 'VALIDATION_ERROR');

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Not Found Failure
///
/// Returned when a resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found'])
      : super(message, code: 'NOT_FOUND');
}

/// Payment Failure
///
/// Returned when payment processing fails.
class PaymentFailure extends Failure {
  const PaymentFailure([String message = 'Payment failed'])
      : super(message, code: 'PAYMENT_ERROR');
}

/// Permission Failure
///
/// Returned when user doesn't have permission.
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission denied'])
      : super(message, code: 'PERMISSION_ERROR');
}

/// Rate Limit Failure
///
/// Returned when API rate limit is exceeded.
class RateLimitFailure extends Failure {
  const RateLimitFailure([
    String message = 'Too many requests. Please try again later.',
  ]) : super(message, code: 'RATE_LIMIT');
}

/// Unknown Failure
///
/// Returned for any other unknown errors.
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unexpected error occurred'])
      : super(message, code: 'UNKNOWN_ERROR');
}
