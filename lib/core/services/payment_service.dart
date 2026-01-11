import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../app/app_config.dart';

/// Payment Result Types
enum PaymentResultType { success, failure, externalWallet }

/// Payment Result Model
class PaymentResult {
  final PaymentResultType type;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorCode;
  final String? errorMessage;
  final String? walletName;

  PaymentResult({
    required this.type,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorCode,
    this.errorMessage,
    this.walletName,
  });

  bool get isSuccess => type == PaymentResultType.success;
  bool get isFailure => type == PaymentResultType.failure;
  bool get isExternalWallet => type == PaymentResultType.externalWallet;
}

/// Payment Service
///
/// Handles payment processing using Razorpay.
class PaymentService {
  Razorpay? _razorpay;
  Function(PaymentResult)? _onPaymentComplete;

  /// Initialize Razorpay
  void init() {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Dispose Razorpay
  void dispose() {
    _razorpay?.clear();
  }

  /// Open Razorpay checkout
  ///
  /// [amount] - Amount in rupees (will be converted to paise)
  /// [orderId] - Your internal order ID
  /// [customerName] - Customer name
  /// [customerPhone] - Customer phone number
  /// [customerEmail] - Customer email (optional)
  /// [description] - Order description
  /// [onComplete] - Callback when payment completes (success, failure, or external wallet)
  void openCheckout({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String description = 'Gongura Griha Order',
    required Function(PaymentResult) onComplete,
  }) {
    if (_razorpay == null) {
      init();
    }

    _onPaymentComplete = onComplete;

    // Convert amount to paise (Razorpay expects amount in smallest currency unit)
    final amountInPaise = (amount * 100).round();

    final options = {
      'key': AppConfig.razorpayKey,
      'amount': amountInPaise,
      'name': 'Gongura Griha',
      'description': description,
      // NOTE: order_id requires server-side creation via Razorpay Orders API
      // For testing without backend, we skip order_id to use Razorpay test mode
      // 'order_id': razorpayOrderId,
      'prefill': {
        'contact': customerPhone,
        'email': customerEmail ?? '',
        'name': customerName,
      },
      'theme': {
        'color': '#2E7D32', // Primary green color
      },
      'notes': {
        'internal_order_id': orderId,
      },
      // Enable retry on failure
      'retry': {
        'enabled': true,
        'max_count': 3,
      },
      // Remember customer for faster checkout
      'remember_customer': true,
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
      _onPaymentComplete?.call(PaymentResult(
        type: PaymentResultType.failure,
        errorCode: 'CHECKOUT_ERROR',
        errorMessage: 'Failed to open payment gateway',
      ));
    }
  }

  /// Open checkout for Cash on Delivery (no payment needed)
  ///
  /// This is a convenience method for COD orders
  PaymentResult processCOD({
    required String orderId,
  }) {
    return PaymentResult(
      type: PaymentResultType.success,
      paymentId: 'COD_$orderId',
      orderId: orderId,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    _onPaymentComplete?.call(PaymentResult(
      type: PaymentResultType.success,
      paymentId: response.paymentId,
      orderId: response.orderId,
      signature: response.signature,
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Failed: ${response.code} - ${response.message}');
    _onPaymentComplete?.call(PaymentResult(
      type: PaymentResultType.failure,
      errorCode: response.code.toString(),
      errorMessage: _getErrorMessage(response.code),
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    _onPaymentComplete?.call(PaymentResult(
      type: PaymentResultType.externalWallet,
      walletName: response.walletName,
    ));
  }

  /// Get user-friendly error message
  String _getErrorMessage(int? code) {
    switch (code) {
      case Razorpay.NETWORK_ERROR:
        return 'Network error. Please check your connection and try again.';
      case Razorpay.INVALID_OPTIONS:
        return 'Invalid payment configuration. Please contact support.';
      case Razorpay.PAYMENT_CANCELLED:
        return 'Payment was cancelled.';
      case Razorpay.TLS_ERROR:
        return 'Security error. Please update your app and try again.';
      case Razorpay.INCOMPATIBLE_PLUGIN:
        return 'Payment gateway error. Please try again later.';
      default:
        return 'Payment failed. Please try again.';
    }
  }

  /// Verify payment signature via Cloud Function
  ///
  /// SECURITY: Payment signature verification is done server-side.
  /// The Razorpay secret key is stored securely in Cloud Functions environment.
  ///
  /// [orderId] - Razorpay order ID
  /// [paymentId] - Razorpay payment ID
  /// [signature] - Razorpay signature to verify
  /// [internalOrderId] - Your internal order ID (optional, for updating order status)
  ///
  /// Returns true if signature is valid, false otherwise.
  /// Throws exception on network/server errors.
  Future<bool> verifyPaymentSignature({
    required String orderId,
    required String paymentId,
    required String signature,
    String? internalOrderId,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'verifyPayment',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );

      final result = await callable.call<Map<String, dynamic>>({
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
        'internalOrderId': internalOrderId,
      });

      final data = result.data;
      final isVerified = data['verified'] == true;

      if (isVerified) {
        debugPrint('Payment verified successfully: $paymentId');
      } else {
        debugPrint('Payment verification failed: $paymentId');
      }

      return isVerified;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Payment verification error: ${e.code} - ${e.message}');

      // Re-throw with user-friendly message based on error code
      switch (e.code) {
        case 'unauthenticated':
          throw Exception('Please login to verify payment');
        case 'invalid-argument':
          throw Exception('Invalid payment data');
        case 'permission-denied':
          throw Exception('Payment signature verification failed');
        case 'failed-precondition':
          throw Exception('Payment verification not configured');
        default:
          throw Exception('Payment verification failed. Please contact support.');
      }
    } catch (e) {
      debugPrint('Unexpected payment verification error: $e');
      throw Exception('Unable to verify payment. Please try again.');
    }
  }
}

