import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/models/cart_item_model.dart';
import '../../../../core/data/models/order_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';

/// Orders Screen
///
/// Displays list of user's orders with status and details.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  StreamSubscription? _ordersSubscription;

  List<OrderModel> get _activeOrders => _orders
      .where((o) =>
          o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled)
      .toList();

  List<OrderModel> get _pastOrders => _orders
      .where((o) =>
          o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled)
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ordersSubscription?.cancel();
    super.dispose();
  }

  void _loadOrders() {
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    _ordersSubscription =
        orderService.getUserOrdersStream(userId).listen((orders) {
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orderStages = [
      l10n.orderPlaced,
      l10n.orderConfirmed,
      l10n.orderPreparing,
      l10n.orderShipped,
      l10n.orderDelivered,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.myOrders),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '${l10n.active} (${_activeOrders.length})'),
            Tab(text: '${l10n.pastOrders} (${_pastOrders.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(_activeOrders,
                    isActive: true, l10n: l10n, orderStages: orderStages),
                _buildOrdersList(_pastOrders,
                    isActive: false, l10n: l10n, orderStages: orderStages),
              ],
            ),
    );
  }

  Widget _buildOrdersList(
    List<OrderModel> orders, {
    required bool isActive,
    required AppLocalizations l10n,
    required List<String> orderStages,
  }) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.shopping_bag_outlined : Icons.history,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? l10n.noActiveOrders : l10n.noPastOrders,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? l10n.activeOrdersAppearHere
                  : l10n.orderHistoryAppearHere,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Start Shopping'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index], l10n, orderStages);
      },
    );
  }

  Widget _buildOrderCard(
    OrderModel order,
    AppLocalizations l10n,
    List<String> orderStages,
  ) {
    final isDelivered = order.status == OrderStatus.delivered;
    final isCancelled = order.status == OrderStatus.cancelled;
    final currentStage = _getOrderStage(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.getOrderDetailRoute(order.orderNumber));
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withAlpha(20),
                    AppColors.primary.withAlpha(5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            '#${order.orderNumber}',
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatRelativeTime(order.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
            ),

            // Progress Bar (only for active orders)
            if (!isDelivered && !isCancelled && currentStage >= 0) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildProgressBar(currentStage, orderStages),
              ),
            ],

            // Cancelled message
            if (isCancelled) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, size: 18, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.cancellationReason ?? 'Order was cancelled',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Items Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.items,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.take(2).map((item) => _buildItemRow(item, l10n)),
                  if (order.items.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            l10n.moreItems(order.items.length - 2),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Divider
            Divider(height: 1, color: AppColors.divider),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isDelivered ? Icons.check_circle : Icons.schedule,
                            size: 14,
                            color: isDelivered
                                ? AppColors.success
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isDelivered ? l10n.deliveredOn : l10n.expectedBy,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDelivered && order.deliveredAt != null
                            ? Formatters.formatDate(order.deliveredAt!)
                            : 'Tomorrow, 10 AM - 2 PM',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      Formatters.formatCurrency(order.total),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons for delivered orders
            if (isDelivered) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleReorder(order),
                        icon: const Icon(Icons.replay, size: 18),
                        label: Text(l10n.reorder),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Rate order - could navigate to a rating screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Rating feature coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.star_outline, size: 18),
                        label: Text(l10n.rate),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Cancel button for cancellable orders
            if (order.canBeCancelled) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(order),
                  icon: Icon(Icons.cancel_outlined,
                      size: 18, color: AppColors.error),
                  label: Text('Cancel Order',
                      style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.error.withAlpha(100)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleReorder(OrderModel order) async {
    // Add all items from the order to the cart
    int addedCount = 0;
    for (final item in order.items) {
      // Get max quantity from inventory service, default to 10 if not found
      final maxQty = inventoryService.getMaxQuantity(item.productSlug, item.sizeCode);
      final inventory = inventoryService.getProductInventory(item.productSlug);

      final cartItem = CartItemModel(
        productSlug: item.productSlug,
        productName: item.productName,
        productImage: item.productImage,
        sizeCode: item.sizeCode,
        sizeName: item.sizeName,
        weight: item.weight,
        price: item.price,
        quantity: item.quantity,
        maxQuantity: maxQty > 0 ? maxQty : 10,
        category: inventory?.category ?? 'General',
        isVeg: inventory?.isVeg ?? true,
      );
      await cartRepository.addItem(cartItem);
      addedCount++;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$addedCount items added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => context.push(AppRoutes.cart),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showCancelDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
            'Are you sure you want to cancel order #${order.orderNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await orderService.cancelOrder(
                order.id,
                reason: 'Cancelled by user',
              );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled successfully')),
                );
              }
            },
            child: Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int currentStage, List<String> orderStages) {
    return Row(
      children: List.generate(orderStages.length * 2 - 1, (index) {
        if (index.isEven) {
          final stageIndex = index ~/ 2;
          final stage = orderStages[stageIndex];
          final isCompleted = stageIndex <= currentStage;
          final isCurrent = stageIndex == currentStage;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : AppColors.divider,
                  border: isCurrent
                      ? Border.all(
                          color: AppColors.primary.withAlpha(100), width: 2)
                      : null,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 6,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: isCompleted
                    ? Icon(
                        stageIndex < currentStage ? Icons.check : Icons.eco,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                stage,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 9,
                  color: isCurrent
                      ? AppColors.primary
                      : isCompleted
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        } else {
          final beforeStageIndex = index ~/ 2;
          final isCompleted = beforeStageIndex < currentStage;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildItemRow(OrderItem item, AppLocalizations l10n) {
    IconData sizeIcon;
    switch (item.sizeCode) {
      case 'S':
        sizeIcon = Icons.eco;
        break;
      case 'M':
        sizeIcon = Icons.nature;
        break;
      case 'L':
        sizeIcon = Icons.forest;
        break;
      default:
        sizeIcon = Icons.eco;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.backgroundSecondary,
            ),
            clipBehavior: Clip.antiAlias,
            child: item.productImage.startsWith('assets/')
                ? Image.asset(
                    item.productImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.eco,
                      color: AppColors.primary.withAlpha(100),
                      size: 28,
                    ),
                  )
                : Icon(
                    Icons.eco,
                    color: AppColors.primary.withAlpha(100),
                    size: 28,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(sizeIcon, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            item.weight,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${l10n.quantity}: ',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        ...List.generate(
                          item.quantity > 3 ? 3 : item.quantity,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              Icons.eco,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (item.quantity > 3)
                          Text(
                            '+${item.quantity - 3}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        icon = Icons.hourglass_empty;
        text = 'Pending';
        break;
      case OrderStatus.confirmed:
        color = AppColors.info;
        icon = Icons.check_circle_outline;
        text = 'Confirmed';
        break;
      case OrderStatus.processing:
        color = AppColors.warning;
        icon = Icons.access_time;
        text = 'Processing';
        break;
      case OrderStatus.shipped:
        color = AppColors.info;
        icon = Icons.local_shipping;
        text = 'Shipped';
        break;
      case OrderStatus.outForDelivery:
        color = AppColors.info;
        icon = Icons.delivery_dining;
        text = 'Out for Delivery';
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        icon = Icons.check_circle;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        icon = Icons.cancel;
        text = 'Cancelled';
        break;
      case OrderStatus.refunded:
        color = AppColors.textSecondary;
        icon = Icons.money_off;
        text = 'Refunded';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
