import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

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

  // Mock orders data
  final List<Map<String, dynamic>> _orders = [
    {
      'orderNumber': 'GG78945612',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'processing',
      'statusText': 'Order Confirmed',
      'items': [
        {'name': 'Classic Gongura Pickle', 'quantity': 2, 'size': '500g'},
        {'name': 'Spicy Gongura Mutton', 'quantity': 1, 'size': '250g'},
      ],
      'total': 1647.0,
      'estimatedDelivery': 'Tomorrow, 10 AM - 2 PM',
    },
    {
      'orderNumber': 'GG78912345',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'shipped',
      'statusText': 'Out for Delivery',
      'items': [
        {'name': 'Sweet Gongura Chutney', 'quantity': 2, 'size': '250g'},
      ],
      'total': 398.0,
      'estimatedDelivery': 'Today, 4 PM - 8 PM',
    },
    {
      'orderNumber': 'GG78901234',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'delivered',
      'statusText': 'Delivered',
      'items': [
        {'name': 'Classic Gongura Pickle', 'quantity': 1, 'size': '1kg'},
        {'name': 'Extra Spicy Gongura', 'quantity': 1, 'size': '500g'},
      ],
      'total': 1348.0,
      'deliveredOn': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'orderNumber': 'GG78891234',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'status': 'delivered',
      'statusText': 'Delivered',
      'items': [
        {'name': 'Gongura Chicken Pickle', 'quantity': 2, 'size': '250g'},
      ],
      'total': 998.0,
      'deliveredOn': DateTime.now().subtract(const Duration(days: 27)),
    },
  ];

  List<Map<String, dynamic>> get _activeOrders =>
      _orders.where((o) => o['status'] != 'delivered').toList();

  List<Map<String, dynamic>> get _pastOrders =>
      _orders.where((o) => o['status'] == 'delivered').toList();

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active (${_activeOrders.length})'),
            Tab(text: 'Past Orders (${_pastOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(_activeOrders, isActive: true),
          _buildOrdersList(_pastOrders, isActive: false),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders,
      {required bool isActive}) {
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
              isActive ? 'No active orders' : 'No past orders',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'Your active orders will appear here'
                  : 'Your order history will appear here',
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
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = order['items'] as List;
    final isDelivered = order['status'] == 'delivered';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push(
            AppRoutes.getOrderDetailRoute(order['orderNumber'] as String),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order['orderNumber']}',
                        style: AppTextStyles.titleSmall,
                      ),
                      Text(
                        Formatters.formatRelativeTime(
                            order['date'] as DateTime),
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

              const Divider(height: 24),

              // Items
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: AppColors.textTertiary,
                            size: 20,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                      ],
                    ),
                  )),

              if (items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${items.length - 2} more items',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),

              const Divider(height: 24),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDelivered ? 'Delivered on' : 'Estimated Delivery',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        isDelivered
                            ? Formatters.formatDate(
                                order['deliveredOn'] as DateTime)
                            : order['estimatedDelivery'] as String,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    Formatters.formatCurrency(order['total'] as double),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Action buttons for delivered orders
              if (isDelivered) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Reorder
                        },
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Reorder'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Rate order
                        },
                        icon: const Icon(Icons.star_outline, size: 18),
                        label: const Text('Rate'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
