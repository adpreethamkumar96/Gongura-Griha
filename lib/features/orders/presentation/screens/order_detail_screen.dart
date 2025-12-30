import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

/// Order Detail Screen
///
/// Displays detailed information about a specific order with tracking.
class OrderDetailScreen extends StatelessWidget {
  final String orderNumber;

  const OrderDetailScreen({
    super.key,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Mock order data
    final order = {
      'orderNumber': orderNumber,
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'shipped',
      'statusText': 'Out for Delivery',
      'items': [
        {
          'name': 'Classic Gongura Pickle',
          'quantity': 2,
          'size': '500g',
          'price': 549.0,
          'image':
              'https://via.placeholder.com/80x80/4CAF50/FFFFFF?text=Gongura',
        },
        {
          'name': 'Spicy Gongura Mutton',
          'quantity': 1,
          'size': '250g',
          'price': 549.0,
          'image':
              'https://via.placeholder.com/80x80/FF5722/FFFFFF?text=Mutton',
        },
      ],
      'subtotal': 1647.0,
      'discount': 100.0,
      'deliveryCharge': 0.0,
      'total': 1547.0,
      'address': {
        'name': 'Ramesh Kumar',
        'phone': '+91 98765 43210',
        'address': '123, Green Valley Apartments, Near City Mall',
        'city': 'Hyderabad - 500001',
      },
      'payment': {
        'method': 'UPI',
        'status': 'Paid',
        'transactionId': 'TXN123456789',
      },
      'tracking': [
        {
          'status': 'Order Placed',
          'time': DateTime.now().subtract(const Duration(hours: 2)),
          'completed': true,
        },
        {
          'status': 'Order Confirmed',
          'time': DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          'completed': true,
        },
        {
          'status': 'Preparing',
          'time': DateTime.now().subtract(const Duration(hours: 1)),
          'completed': true,
        },
        {
          'status': 'Out for Delivery',
          'time': DateTime.now().subtract(const Duration(minutes: 30)),
          'completed': true,
        },
        {
          'status': 'Delivered',
          'time': null,
          'completed': false,
        },
      ],
      'estimatedDelivery': 'Today, 4 PM - 8 PM',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order #$orderNumber'),
        actions: [
          IconButton(
            onPressed: () {
              // Help
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(context, order),

            const SizedBox(height: 8),

            // Tracking Timeline
            _buildTrackingSection(context, order),

            const SizedBox(height: 8),

            // Items
            _buildItemsSection(context, order),

            const SizedBox(height: 8),

            // Delivery Address
            _buildAddressSection(context, order),

            const SizedBox(height: 8),

            // Payment Details
            _buildPaymentSection(context, order),

            const SizedBox(height: 8),

            // Bill Details
            _buildBillSection(context, order),

            const SizedBox(height: 16),

            // Help Section
            _buildHelpSection(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_shipping,
              color: AppColors.info,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['statusText'] as String,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expected by ${order['estimatedDelivery']}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingSection(
      BuildContext context, Map<String, dynamic> order) {
    final tracking = order['tracking'] as List;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Status', style: AppTextStyles.titleSmall),
          const SizedBox(height: 16),
          ...tracking.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == tracking.length - 1;

            return _buildTrackingStep(
              status: step['status'] as String,
              time: step['time'] as DateTime?,
              completed: step['completed'] as bool,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrackingStep({
    required String status,
    required DateTime? time,
    required bool completed,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? AppColors.primary : AppColors.divider,
              ),
              child: completed
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: completed ? AppColors.primary : AppColors.divider,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
                    color: completed
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                if (time != null)
                  Text(
                    Formatters.formatDateTime(time),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(BuildContext context, Map<String, dynamic> order) {
    final items = order['items'] as List;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Items (${items.length})', style: AppTextStyles.titleSmall),
              TextButton(
                onPressed: () {
                  // View invoice
                },
                child: const Text('View Invoice'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image'] as String,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.backgroundSecondary,
                          child: Icon(Icons.image, color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            '${item['size']} x ${item['quantity']}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(
                        (item['price'] as double) * (item['quantity'] as int),
                      ),
                      style: AppTextStyles.titleSmall,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAddressSection(
      BuildContext context, Map<String, dynamic> order) {
    final address = order['address'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Address', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address['name'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address['address'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      address['city'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address['phone'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(
      BuildContext context, Map<String, dynamic> order) {
    final payment = order['payment'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Details', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.upi, size: 20),
              const SizedBox(width: 8),
              Text(payment['method'] as String, style: AppTextStyles.bodyMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(26),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  payment['status'] as String,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Transaction ID: ${payment['transactionId']}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSection(BuildContext context, Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bill Details', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          _buildBillRow('Item Total', order['subtotal'] as double),
          _buildBillRow('Discount', -(order['discount'] as double),
              isDiscount: true),
          _buildBillRow(
            'Delivery',
            order['deliveryCharge'] as double,
            subtitle:
                (order['deliveryCharge'] as double) == 0 ? 'FREE' : null,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Paid', style: AppTextStyles.titleMedium),
              Text(
                Formatters.formatCurrency(order['total'] as double),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, double amount,
      {bool isDiscount = false, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          subtitle != null
              ? Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Text(
                  isDiscount
                      ? '-${Formatters.formatCurrency(amount.abs())}'
                      : Formatters.formatCurrency(amount),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDiscount ? AppColors.success : null,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Need Help?', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          _buildHelpOption(
            icon: Icons.chat_outlined,
            title: 'Chat with us',
            onTap: () {},
          ),
          _buildHelpOption(
            icon: Icons.phone_outlined,
            title: 'Call support',
            onTap: () {},
          ),
          _buildHelpOption(
            icon: Icons.cancel_outlined,
            title: 'Cancel order',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cancel Order'),
                  content: const Text(
                      'Are you sure you want to cancel this order?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go(AppRoutes.orders);
                      },
                      child: Text(
                        'Yes, Cancel',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDestructive ? AppColors.error : null,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
