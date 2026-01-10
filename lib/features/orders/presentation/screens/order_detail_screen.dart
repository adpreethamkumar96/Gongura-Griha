import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';

/// Order Detail Screen
///
/// Displays detailed information about a specific order with tracking.
class OrderDetailScreen extends StatelessWidget {
  final String orderNumber;

  const OrderDetailScreen({
    super.key,
    required this.orderNumber,
  });

  // Get order data based on order number
  Map<String, dynamic>? _getOrderData(AppLocalizations l10n) {
    final allOrders = _getAllOrders(l10n);
    try {
      return allOrders.firstWhere((o) => o['orderNumber'] == orderNumber);
    } catch (_) {
      return null;
    }
  }

  // All orders data matching orders_screen.dart
  List<Map<String, dynamic>> _getAllOrders(AppLocalizations l10n) => [
    {
      'orderNumber': 'GG78945612',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'processing',
      'statusText': l10n.statusOrderConfirmed,
      'currentStage': 1,
      'items': [
        {
          'name': l10n.traditionalGonguraPachadi,
          'quantity': 2,
          'size': '500g',
          'price': 349.0,
          'image': 'assets/images/GonguraPickle.png',
        },
        {
          'name': l10n.spicyGonguraPodi,
          'quantity': 1,
          'size': '250g',
          'price': 179.0,
          'image': 'assets/images/GonguraPowder.png',
        },
      ],
      'subtotal': 877.0,
      'discount': 50.0,
      'deliveryCharge': 0.0,
      'total': 827.0,
      'estimatedDelivery': l10n.tomorrowDelivery,
      'address': {
        'name': 'Ramesh Kumar',
        'phone': '+91 98765 43210',
        'address': '123, Green Valley Apartments, Near City Mall',
        'city': 'Hyderabad - 500001',
      },
      'payment': {
        'method': 'UPI',
        'status': l10n.paid,
        'transactionId': 'TXN123456789',
      },
    },
    {
      'orderNumber': 'GG78912345',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'shipped',
      'statusText': l10n.statusOutForDelivery,
      'currentStage': 3,
      'items': [
        {
          'name': l10n.classicGonguraChutney,
          'quantity': 2,
          'size': '250g',
          'price': 199.0,
          'image': 'assets/images/GonguraChutney.png',
        },
      ],
      'subtotal': 398.0,
      'discount': 0.0,
      'deliveryCharge': 0.0,
      'total': 398.0,
      'estimatedDelivery': l10n.todayDelivery,
      'address': {
        'name': 'Ramesh Kumar',
        'phone': '+91 98765 43210',
        'address': '123, Green Valley Apartments, Near City Mall',
        'city': 'Hyderabad - 500001',
      },
      'payment': {
        'method': 'UPI',
        'status': l10n.paid,
        'transactionId': 'TXN987654321',
      },
    },
    {
      'orderNumber': 'GG78901234',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'delivered',
      'statusText': l10n.orderDelivered,
      'currentStage': 4,
      'items': [
        {
          'name': l10n.traditionalGonguraPachadi,
          'quantity': 1,
          'size': '1kg',
          'price': 599.0,
          'image': 'assets/images/GonguraPickle.png',
        },
        {
          'name': l10n.spicyGonguraPodi,
          'quantity': 1,
          'size': '500g',
          'price': 299.0,
          'image': 'assets/images/GonguraPowder.png',
        },
      ],
      'subtotal': 898.0,
      'discount': 100.0,
      'deliveryCharge': 0.0,
      'total': 798.0,
      'deliveredOn': DateTime.now().subtract(const Duration(days: 5)),
      'address': {
        'name': 'Ramesh Kumar',
        'phone': '+91 98765 43210',
        'address': '123, Green Valley Apartments, Near City Mall',
        'city': 'Hyderabad - 500001',
      },
      'payment': {
        'method': 'COD',
        'status': l10n.paid,
        'transactionId': 'COD-78901234',
      },
    },
    {
      'orderNumber': 'GG78891234',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'status': 'delivered',
      'statusText': l10n.orderDelivered,
      'currentStage': 4,
      'items': [
        {
          'name': l10n.classicGonguraChutney,
          'quantity': 2,
          'size': '250g',
          'price': 199.0,
          'image': 'assets/images/GonguraChutney.png',
        },
      ],
      'subtotal': 398.0,
      'discount': 0.0,
      'deliveryCharge': 40.0,
      'total': 438.0,
      'deliveredOn': DateTime.now().subtract(const Duration(days: 27)),
      'address': {
        'name': 'Ramesh Kumar',
        'phone': '+91 98765 43210',
        'address': '456, Sunshine Colony, Madhapur',
        'city': 'Hyderabad - 500081',
      },
      'payment': {
        'method': 'UPI',
        'status': l10n.paid,
        'transactionId': 'TXN456789012',
      },
    },
  ];

  // Generate tracking data based on current stage
  List<Map<String, dynamic>> _getTrackingData(
    AppLocalizations l10n,
    int currentStage,
    DateTime orderDate,
    DateTime? deliveredOn,
  ) {
    final stages = [
      l10n.orderPlaced,
      l10n.orderConfirmed,
      l10n.orderPreparing,
      l10n.outForDelivery,
      l10n.orderDelivered,
    ];

    return List.generate(stages.length, (index) {
      DateTime? time;
      if (index <= currentStage) {
        if (index == 4 && deliveredOn != null) {
          time = deliveredOn;
        } else if (index <= currentStage) {
          // Calculate approximate times based on order date
          switch (index) {
            case 0:
              time = orderDate;
              break;
            case 1:
              time = orderDate.add(const Duration(minutes: 15));
              break;
            case 2:
              time = orderDate.add(const Duration(hours: 1));
              break;
            case 3:
              time = orderDate.add(const Duration(hours: 4));
              break;
            case 4:
              time = deliveredOn ?? orderDate.add(const Duration(hours: 6));
              break;
          }
        }
      }

      return {
        'status': stages[index],
        'time': index <= currentStage ? time : null,
        'completed': index <= currentStage,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final order = _getOrderData(l10n);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: Text('${l10n.orders} #$orderNumber')),
        body: Center(
          child: Text(l10n.noResults),
        ),
      );
    }

    final currentStage = order['currentStage'] as int;
    final isDelivered = order['status'] == 'delivered';
    final tracking = _getTrackingData(
      l10n,
      currentStage,
      order['date'] as DateTime,
      order['deliveredOn'] as DateTime?,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${l10n.orders} #$orderNumber'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(context, order, l10n, isDelivered),

            const SizedBox(height: 8),

            // Tracking Timeline
            _buildTrackingSection(context, tracking, l10n),

            const SizedBox(height: 8),

            // Items
            _buildItemsSection(context, order, l10n),

            const SizedBox(height: 8),

            // Delivery Address
            _buildAddressSection(context, order, l10n),

            const SizedBox(height: 8),

            // Payment Details
            _buildPaymentSection(context, order, l10n),

            const SizedBox(height: 8),

            // Bill Details
            _buildBillSection(context, order, l10n),

            const SizedBox(height: 16),

            // Help Section
            if (!isDelivered) _buildHelpSection(context, l10n),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    Map<String, dynamic> order,
    AppLocalizations l10n,
    bool isDelivered,
  ) {
    final statusText = order['statusText'] as String;
    final status = order['status'] as String;

    // Determine icon and color based on status
    IconData statusIcon;
    Color statusColor;

    switch (status) {
      case 'processing':
        statusIcon = Icons.inventory_2_outlined;
        statusColor = AppColors.accent;
        break;
      case 'shipped':
        statusIcon = Icons.local_shipping;
        statusColor = AppColors.info;
        break;
      case 'delivered':
        statusIcon = Icons.check_circle;
        statusColor = AppColors.success;
        break;
      default:
        statusIcon = Icons.receipt_long;
        statusColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDelivered
                      ? '${l10n.deliveredOn} ${Formatters.formatDate(order['deliveredOn'] as DateTime)}'
                      : '${l10n.expectedBy} ${order['estimatedDelivery']}',
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
    BuildContext context,
    List<Map<String, dynamic>> tracking,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.orderStatus, style: AppTextStyles.titleSmall),
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

  Widget _buildItemsSection(
    BuildContext context,
    Map<String, dynamic> order,
    AppLocalizations l10n,
  ) {
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
              Text('${l10n.items} (${items.length})', style: AppTextStyles.titleSmall),
              TextButton(
                onPressed: () {},
                child: Text(l10n.viewInvoice),
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
                      child: Container(
                        width: 60,
                        height: 60,
                        color: AppColors.primary.withAlpha(20),
                        child: Image.asset(
                          item['image'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.eco,
                            color: AppColors.primary.withAlpha(100),
                          ),
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
    BuildContext context,
    Map<String, dynamic> order,
    AppLocalizations l10n,
  ) {
    final address = order['address'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.deliveryAddress, style: AppTextStyles.titleSmall),
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
    BuildContext context,
    Map<String, dynamic> order,
    AppLocalizations l10n,
  ) {
    final payment = order['payment'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.paymentDetails, style: AppTextStyles.titleSmall),
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
            '${l10n.transactionId}: ${payment['transactionId']}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSection(
    BuildContext context,
    Map<String, dynamic> order,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.billDetails, style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          _buildBillRow(l10n.itemTotal, order['subtotal'] as double),
          if ((order['discount'] as double) > 0)
            _buildBillRow(l10n.couponDiscount, -(order['discount'] as double),
                isDiscount: true),
          _buildBillRow(
            l10n.delivery,
            order['deliveryCharge'] as double,
            subtitle: (order['deliveryCharge'] as double) == 0 ? l10n.free : null,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.totalPaid, style: AppTextStyles.titleMedium),
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

  Widget _buildHelpSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.needHelp, style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          _buildHelpOption(
            icon: Icons.chat_outlined,
            title: l10n.chatWithUs,
            onTap: () {},
          ),
          _buildHelpOption(
            icon: Icons.phone_outlined,
            title: l10n.callSupport,
            onTap: () {},
          ),
          _buildHelpOption(
            icon: Icons.cancel_outlined,
            title: l10n.cancelOrder,
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.cancelOrder),
                  content: Text(l10n.cancelOrderConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(l10n.no),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.go(AppRoutes.orders);
                      },
                      child: Text(
                        l10n.yesCancelOrder,
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
