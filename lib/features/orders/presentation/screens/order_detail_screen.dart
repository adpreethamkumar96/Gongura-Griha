import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/models/order_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';

/// Order Detail Screen
///
/// Displays detailed information about a specific order with tracking.
class OrderDetailScreen extends StatefulWidget {
  final String orderNumber;

  const OrderDetailScreen({
    super.key,
    required this.orderNumber,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? _order;
  bool _isLoading = true;
  StreamSubscription? _orderSubscription;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final order = await orderService.getOrderByNumber(widget.orderNumber, userId: userId);
    if (order != null && mounted) {
      setState(() {
        _order = order;
        _isLoading = false;
      });

      // Subscribe to real-time updates
      _orderSubscription =
          orderService.getOrderStream(order.id).listen((updatedOrder) {
        if (mounted && updatedOrder != null) {
          setState(() => _order = updatedOrder);
        }
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  int _getOrderStage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.processing:
        return 2;
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return -1;
    }
  }

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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('${l10n.orders} #${widget.orderNumber}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: Text('${l10n.orders} #${widget.orderNumber}')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              Text(l10n.noResults, style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Text('Order not found', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      );
    }

    final order = _order!;
    final currentStage = _getOrderStage(order.status);
    final isDelivered = order.status == OrderStatus.delivered;
    final isCancelled = order.status == OrderStatus.cancelled;
    final tracking = _getTrackingData(
      l10n,
      currentStage,
      order.createdAt,
      order.deliveredAt,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${l10n.orders} #${order.orderNumber}'),
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
            _buildStatusCard(context, order, l10n, isDelivered, isCancelled),

            const SizedBox(height: 8),

            // Cancelled message
            if (isCancelled) _buildCancelledSection(order, l10n),

            // Tracking Timeline (only for non-cancelled orders)
            if (!isCancelled && currentStage >= 0)
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
            if (!isDelivered && !isCancelled) _buildHelpSection(context, order, l10n),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    OrderModel order,
    AppLocalizations l10n,
    bool isDelivered,
    bool isCancelled,
  ) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.pending:
        statusIcon = Icons.hourglass_empty;
        statusColor = AppColors.warning;
        statusText = 'Pending';
        break;
      case OrderStatus.confirmed:
        statusIcon = Icons.check_circle_outline;
        statusColor = AppColors.info;
        statusText = l10n.statusOrderConfirmed;
        break;
      case OrderStatus.processing:
        statusIcon = Icons.inventory_2_outlined;
        statusColor = AppColors.accent;
        statusText = 'Processing';
        break;
      case OrderStatus.shipped:
        statusIcon = Icons.local_shipping;
        statusColor = AppColors.info;
        statusText = 'Shipped';
        break;
      case OrderStatus.outForDelivery:
        statusIcon = Icons.delivery_dining;
        statusColor = AppColors.info;
        statusText = l10n.statusOutForDelivery;
        break;
      case OrderStatus.delivered:
        statusIcon = Icons.check_circle;
        statusColor = AppColors.success;
        statusText = l10n.orderDelivered;
        break;
      case OrderStatus.cancelled:
        statusIcon = Icons.cancel;
        statusColor = AppColors.error;
        statusText = 'Cancelled';
        break;
      case OrderStatus.refunded:
        statusIcon = Icons.money_off;
        statusColor = AppColors.textSecondary;
        statusText = 'Refunded';
        break;
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
                  isDelivered && order.deliveredAt != null
                      ? '${l10n.deliveredOn} ${Formatters.formatDate(order.deliveredAt!)}'
                      : isCancelled
                          ? 'Cancelled on ${Formatters.formatDate(order.updatedAt ?? order.createdAt)}'
                          : '${l10n.expectedBy} Tomorrow, 10 AM - 2 PM',
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

  Widget _buildCancelledSection(OrderModel order, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                order.cancellationReason ?? 'This order has been cancelled.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
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
    OrderModel order,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${l10n.items} (${order.items.length})',
                  style: AppTextStyles.titleSmall),
              TextButton(
                onPressed: () {},
                child: Text(l10n.viewInvoice),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: AppColors.primary.withAlpha(20),
                        child: item.productImage.startsWith('assets/')
                            ? Image.asset(
                                item.productImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.eco,
                                  color: AppColors.primary.withAlpha(100),
                                ),
                              )
                            : Icon(
                                Icons.eco,
                                color: AppColors.primary.withAlpha(100),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            '${item.weight} x ${item.quantity}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(item.totalPrice),
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
    OrderModel order,
    AppLocalizations l10n,
  ) {
    final address = order.deliveryAddress;

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
                      address.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.landmark.isNotEmpty
                          ? '${address.address}, ${address.landmark}'
                          : address.address,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${address.city} - ${address.pincode}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.phone,
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
    OrderModel order,
    AppLocalizations l10n,
  ) {
    final isCOD = order.paymentMethod == PaymentMethod.cod;
    final isDelivered = order.status == OrderStatus.delivered;
    // For COD, payment is only complete after delivery
    final isPaid = isCOD ? isDelivered : true;

    // Payment icon based on method
    IconData paymentIcon;
    Color iconColor;
    switch (order.paymentMethod) {
      case PaymentMethod.upi:
        paymentIcon = Icons.account_balance;
        iconColor = AppColors.upi;
        break;
      case PaymentMethod.card:
        paymentIcon = Icons.credit_card;
        iconColor = AppColors.info;
        break;
      case PaymentMethod.cod:
        paymentIcon = Icons.payments_outlined;
        iconColor = AppColors.warning;
        break;
      case PaymentMethod.netBanking:
        paymentIcon = Icons.language;
        iconColor = AppColors.info;
        break;
    }

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
              Icon(paymentIcon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(order.paymentMethod.displayName,
                  style: AppTextStyles.bodyMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.success.withAlpha(26)
                      : AppColors.warning.withAlpha(26),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPaid ? l10n.paid : 'Pay on Delivery',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isPaid ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          // Only show transaction ID for online payments
          if (!isCOD) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.transactionId}: ${order.id.substring(0, 12).toUpperCase()}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
          // Show COD info message
          if (isCOD && !isDelivered) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please keep exact change ready at the time of delivery',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillSection(
    BuildContext context,
    OrderModel order,
    AppLocalizations l10n,
  ) {
    final isCOD = order.paymentMethod == PaymentMethod.cod;
    final isDelivered = order.status == OrderStatus.delivered;
    // For COD, show "Amount Due" until delivered, then "Total Paid"
    final totalLabel = (isCOD && !isDelivered) ? 'Amount Due' : l10n.totalPaid;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.billDetails, style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          _buildBillRow(l10n.itemTotal, order.subtotal),
          if (order.discount > 0)
            _buildBillRow(l10n.couponDiscount, -order.discount, isDiscount: true),
          _buildBillRow(
            l10n.delivery,
            order.deliveryCharge,
            subtitle: order.deliveryCharge == 0 ? l10n.free : null,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(totalLabel, style: AppTextStyles.titleMedium),
              Text(
                Formatters.formatCurrency(order.total),
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

  Widget _buildHelpSection(
      BuildContext context, OrderModel order, AppLocalizations l10n) {
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
          if (order.canBeCancelled)
            _buildHelpOption(
              icon: Icons.cancel_outlined,
              title: l10n.cancelOrder,
              onTap: () => _showCancelDialog(context, order, l10n),
              isDestructive: true,
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, OrderModel order, AppLocalizations l10n) {
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
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await orderService.cancelOrder(
                order.id,
                reason: 'Cancelled by user',
              );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled successfully')),
                );
                context.go(AppRoutes.orders);
              }
            },
            child: Text(
              l10n.yesCancelOrder,
              style: TextStyle(color: AppColors.error),
            ),
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
