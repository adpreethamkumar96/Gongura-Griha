import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
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

  // Order status stages for progress bar
  List<String> _getOrderStages(AppLocalizations l10n) => [
    l10n.orderPlaced,
    l10n.orderConfirmed,
    l10n.orderPreparing,
    l10n.orderShipped,
    l10n.orderDelivered,
  ];

  // Mock orders data with localized names
  List<Map<String, dynamic>> _getOrders(AppLocalizations l10n) => [
    {
      'orderNumber': 'GG78945612',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'processing',
      'statusText': l10n.statusOrderConfirmed,
      'currentStage': 1, // 0-indexed stage
      'items': [
        {
          'name': l10n.traditionalGonguraPachadi,
          'quantity': 2,
          'size': '500g',
          'sizeIndex': 1,
          'image': 'assets/images/GonguraPickle.png',
        },
        {
          'name': l10n.spicyGonguraPodi,
          'quantity': 1,
          'size': '250g',
          'sizeIndex': 0,
          'image': 'assets/images/GonguraPowder.png',
        },
      ],
      'total': 1647.0,
      'estimatedDelivery': l10n.tomorrowDelivery,
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
          'sizeIndex': 0,
          'image': 'assets/images/GonguraChutney.png',
        },
      ],
      'total': 398.0,
      'estimatedDelivery': l10n.todayDelivery,
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
          'sizeIndex': 2,
          'image': 'assets/images/GonguraPickle.png',
        },
        {
          'name': l10n.spicyGonguraPodi,
          'quantity': 1,
          'size': '500g',
          'sizeIndex': 1,
          'image': 'assets/images/GonguraPowder.png',
        },
      ],
      'total': 1348.0,
      'deliveredOn': DateTime.now().subtract(const Duration(days: 5)),
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
          'sizeIndex': 0,
          'image': 'assets/images/GonguraChutney.png',
        },
      ],
      'total': 998.0,
      'deliveredOn': DateTime.now().subtract(const Duration(days: 27)),
    },
  ];

  List<Map<String, dynamic>> _getActiveOrders(List<Map<String, dynamic>> orders) =>
      orders.where((o) => o['status'] != 'delivered').toList();

  List<Map<String, dynamic>> _getPastOrders(List<Map<String, dynamic>> orders) =>
      orders.where((o) => o['status'] == 'delivered').toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orders = _getOrders(l10n);
    final activeOrders = _getActiveOrders(orders);
    final pastOrders = _getPastOrders(orders);
    final orderStages = _getOrderStages(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.myOrders),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '${l10n.active} (${activeOrders.length})'),
            Tab(text: '${l10n.pastOrders} (${pastOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(activeOrders, isActive: true, l10n: l10n, orderStages: orderStages),
          _buildOrdersList(pastOrders, isActive: false, l10n: l10n, orderStages: orderStages),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders,
      {required bool isActive, required AppLocalizations l10n, required List<String> orderStages}) {
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

  Widget _buildOrderCard(Map<String, dynamic> order, AppLocalizations l10n, List<String> orderStages) {
    final items = order['items'] as List;
    final isDelivered = order['status'] == 'delivered';
    final currentStage = order['currentStage'] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push(
            AppRoutes.getOrderDetailRoute(order['orderNumber'] as String),
          );
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            '#${order['orderNumber']}',
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatRelativeTime(order['date'] as DateTime),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(
                    order['status'] as String,
                    order['statusText'] as String,
                  ),
                ],
              ),
            ),

            // Progress Bar (only for active orders)
            if (!isDelivered) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildProgressBar(currentStage, orderStages),
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
                  ...items.take(2).map((item) => _buildItemRow(item as Map<String, dynamic>, l10n)),
                  if (items.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline,
                            size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            l10n.moreItems(items.length - 2),
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
                            color: isDelivered ? AppColors.success : AppColors.textTertiary,
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
                        isDelivered
                            ? Formatters.formatDate(order['deliveredOn'] as DateTime)
                            : order['estimatedDelivery'] as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      Formatters.formatCurrency(order['total'] as double),
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
                        onPressed: () {
                          // Reorder
                        },
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
                          // Rate order
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
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int currentStage, List<String> orderStages) {
    return Column(
      children: [
        // Progress dots and lines
        Row(
          children: List.generate(orderStages.length * 2 - 1, (index) {
            if (index.isEven) {
              // Dot
              final stageIndex = index ~/ 2;
              final isCompleted = stageIndex <= currentStage;
              final isCurrent = stageIndex == currentStage;

              return Container(
                width: isCurrent ? 28 : 20,
                height: isCurrent ? 28 : 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : AppColors.divider,
                  border: isCurrent
                      ? Border.all(color: AppColors.primary.withAlpha(100), width: 3)
                      : null,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: isCompleted
                    ? Icon(
                        stageIndex < currentStage ? Icons.check : Icons.eco,
                        size: isCurrent ? 16 : 12,
                        color: Colors.white,
                      )
                    : null,
              );
            } else {
              // Line
              final beforeStageIndex = index ~/ 2;
              final isCompleted = beforeStageIndex < currentStage;

              return Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 8),
        // Stage labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: orderStages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final isCompleted = index <= currentStage;
            final isCurrent = index == currentStage;

            return SizedBox(
              width: 50,
              child: Text(
                stage,
                textAlign: TextAlign.center,
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
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item, AppLocalizations l10n) {
    final sizeIndex = item['sizeIndex'] as int? ?? 0;
    final quantity = item['quantity'] as int;

    // Size icons: S = eco (small), M = nature, L = forest
    IconData sizeIcon;
    switch (sizeIndex) {
      case 0:
        sizeIcon = Icons.eco;
        break;
      case 1:
        sizeIcon = Icons.nature;
        break;
      case 2:
        sizeIcon = Icons.forest;
        break;
      default:
        sizeIcon = Icons.eco;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.backgroundSecondary,
            ),
            clipBehavior: Clip.antiAlias,
            child: item['image'] != null
                ? Image.asset(
                    item['image'] as String,
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
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Size badge with icon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            item['size'] as String,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Quantity with leaf icons
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
                          quantity > 3 ? 3 : quantity,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              Icons.eco,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (quantity > 3)
                          Text(
                            '+${quantity - 3}',
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

  Widget _buildStatusBadge(String status, String text) {
    Color color;
    IconData icon;

    switch (status) {
      case 'processing':
        color = AppColors.warning;
        icon = Icons.access_time;
        break;
      case 'shipped':
        color = AppColors.info;
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = AppColors.error;
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.info;
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
