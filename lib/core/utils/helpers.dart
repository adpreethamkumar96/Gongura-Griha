import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

/// Helper Functions
///
/// Contains utility functions used across the app.
class Helpers {
  Helpers._();

  /// Open URL in browser
  static Future<bool> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Open phone dialer
  static Future<bool> callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// Open email client
  static Future<bool> sendEmail(String email, {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// Open WhatsApp
  static Future<bool> openWhatsApp(String phone, {String? message}) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final url = message != null
        ? 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}'
        : 'https://wa.me/$cleanPhone';
    return await openUrl(url);
  }

  /// Calculate cart totals
  static Map<String, double> calculateCartTotals({
    required double subtotal,
    double discount = 0,
    bool isCOD = false,
  }) {
    // Calculate delivery charge
    double deliveryCharge = 0;
    final subtotalAfterDiscount = subtotal - discount;

    if (subtotalAfterDiscount < AppConstants.freeDeliveryThreshold) {
      deliveryCharge = AppConstants.standardDeliveryCharge;
    }

    // Add COD charge
    if (isCOD) {
      deliveryCharge += AppConstants.codExtraCharge;
    }

    // Calculate tax
    final tax = subtotalAfterDiscount * (AppConstants.gstPercentage / 100);

    // Calculate total
    final total = subtotalAfterDiscount + deliveryCharge + tax;

    return {
      'subtotal': subtotal,
      'discount': discount,
      'deliveryCharge': deliveryCharge,
      'tax': tax,
      'total': total,
    };
  }

  /// Check if delivery is free
  static bool isFreeDelivery(double subtotal) {
    return subtotal >= AppConstants.freeDeliveryThreshold;
  }

  /// Get amount remaining for free delivery
  static double amountForFreeDelivery(double subtotal) {
    if (isFreeDelivery(subtotal)) return 0;
    return AppConstants.freeDeliveryThreshold - subtotal;
  }

  /// Debounce function
  static void Function() debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    bool isReady = true;

    return () {
      if (!isReady) return;

      isReady = false;
      callback();

      Future.delayed(duration, () {
        isReady = true;
      });
    };
  }

  /// Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: isError ? Colors.red : null,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Get status color
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.blue;
      case 'packed':
        return Colors.indigo;
      case 'shipped':
        return Colors.purple;
      case 'out_for_delivery':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'returned':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Get status display text
  static String getOrderStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'packed':
        return 'Packed';
      case 'shipped':
        return 'Shipped';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'returned':
        return 'Returned';
      default:
        return status;
    }
  }

  /// Get spice level emoji
  static String getSpiceLevelEmoji(String level) {
    switch (level.toLowerCase()) {
      case 'mild':
        return '🌶️';
      case 'medium':
        return '🌶️🌶️';
      case 'hot':
        return '🌶️🌶️🌶️';
      case 'extra_hot':
        return '🌶️🌶️🌶️🌶️';
      default:
        return '';
    }
  }

  /// Get spice level display text
  static String getSpiceLevelText(String level) {
    switch (level.toLowerCase()) {
      case 'mild':
        return 'Mild';
      case 'medium':
        return 'Medium';
      case 'hot':
        return 'Hot';
      case 'extra_hot':
        return 'Extra Hot';
      default:
        return level;
    }
  }
}
