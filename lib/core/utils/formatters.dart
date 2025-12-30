import 'package:intl/intl.dart';

/// Formatters
///
/// Contains formatting functions for dates, currency, phone numbers, etc.
class Formatters {
  Formatters._();

  /// Currency formatter for INR
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Currency formatter with decimals
  static final _currencyFormatWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format price as currency
  static String formatPrice(double price, {bool showDecimals = false}) {
    if (showDecimals) {
      return _currencyFormatWithDecimals.format(price);
    }
    return _currencyFormat.format(price);
  }

  /// Format currency (alias for formatPrice)
  static String formatCurrency(double amount) => formatPrice(amount);

  /// Format price with strike-through for discounted price
  static String formatOriginalPrice(double price) {
    return '₹${price.toStringAsFixed(0)}';
  }

  /// Calculate discount percentage
  static int calculateDiscountPercentage(double originalPrice, double salePrice) {
    if (originalPrice <= 0 || salePrice >= originalPrice) return 0;
    return ((originalPrice - salePrice) / originalPrice * 100).round();
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    // +919876543210 -> +91 98765 43210
    if (phone.startsWith('+91') && phone.length == 13) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 8)} ${phone.substring(8)}';
    }
    // 9876543210 -> 98765 43210
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  /// Mask phone number for privacy
  static String maskPhoneNumber(String phone) {
    // +919876543210 -> +91****543210
    if (phone.startsWith('+91') && phone.length == 13) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    // 9876543210 -> ****543210
    if (phone.length == 10) {
      return '****${phone.substring(4)}';
    }
    return phone;
  }

  /// Mask email for privacy
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length <= 2) {
      return '$localPart***@$domain';
    }

    return '${localPart.substring(0, 2)}***@$domain';
  }

  /// Format date for display
  static String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  /// Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format order number
  static String formatOrderNumber(String orderNumber) {
    return '#$orderNumber';
  }

  /// Format quantity
  static String formatQuantity(int quantity) {
    return 'x$quantity';
  }

  /// Format weight/size
  static String formatWeight(int grams) {
    if (grams >= 1000) {
      final kg = grams / 1000;
      return '${kg.toStringAsFixed(kg.truncateToDouble() == kg ? 0 : 1)} kg';
    }
    return '${grams}g';
  }

  /// Format rating
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  /// Format review count
  static String formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  /// Format delivery date range
  static String formatDeliveryDateRange(DateTime start, DateTime end) {
    final startFormat = DateFormat('MMM d');
    final endFormat = DateFormat('d, yyyy');

    if (start.month == end.month) {
      return '${startFormat.format(start)}-${endFormat.format(end)}';
    }

    return '${startFormat.format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Title case
  static String titleCase(String text) {
    return text.split(' ').map(capitalize).join(' ');
  }
}
