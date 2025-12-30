import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

/// Cart Screen
///
/// Displays cart items with quantity controls and checkout option.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Mock cart data
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'name': 'Classic Gongura Pickle',
      'size': '500g',
      'price': 549.0,
      'originalPrice': 699.0,
      'quantity': 2,
      'image': 'https://via.placeholder.com/100x100/4CAF50/FFFFFF?text=Gongura',
      'isVeg': true,
    },
    {
      'id': '2',
      'name': 'Spicy Gongura Mutton',
      'size': '250g',
      'price': 549.0,
      'originalPrice': 649.0,
      'quantity': 1,
      'image': 'https://via.placeholder.com/100x100/FF5722/FFFFFF?text=Mutton',
      'isVeg': false,
    },
    {
      'id': '3',
      'name': 'Sweet Gongura Chutney',
      'size': '250g',
      'price': 199.0,
      'originalPrice': 249.0,
      'quantity': 1,
      'image': 'https://via.placeholder.com/100x100/9C27B0/FFFFFF?text=Sweet',
      'isVeg': true,
    },
  ];

  String? _appliedCoupon;
  double _couponDiscount = 0;

  double get _subtotal => _cartItems.fold(
        0,
        (sum, item) =>
            sum + (item['price'] as double) * (item['quantity'] as int),
      );

  double get _totalSavings => _cartItems.fold(
        0,
        (sum, item) {
          final original = item['originalPrice'] as double?;
          if (original == null) return sum;
          return sum +
              (original - (item['price'] as double)) *
                  (item['quantity'] as int);
        },
      );

  double get _deliveryCharge => _subtotal >= 500 ? 0 : 40;

  double get _total => _subtotal + _deliveryCharge - _couponDiscount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Cart (${_cartItems.length})'),
      ),
      body: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar:
          _cartItems.isEmpty ? null : _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious pickles to your cart',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Browse Products',
            onPressed: () => context.push(AppRoutes.productList),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Free Delivery Banner
          if (_subtotal < 500)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withAlpha(77)),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add \u20B9${(500 - _subtotal).toStringAsFixed(0)} more for FREE delivery',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Cart Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _cartItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildCartItem(_cartItems[index]),
          ),

          const SizedBox(height: 16),

          // Coupon Section
          _buildCouponSection(),

          const SizedBox(height: 16),

          // Bill Details
          _buildBillDetails(),

          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['image'] as String,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.backgroundSecondary,
                    child: Icon(
                      Icons.image,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              // Veg indicator
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: item['isVeg'] as bool
                          ? AppColors.veg
                          : AppColors.nonVeg,
                    ),
                  ),
                  child: Icon(
                    Icons.circle,
                    size: 8,
                    color:
                        item['isVeg'] as bool ? AppColors.veg : AppColors.nonVeg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: AppTextStyles.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['size'] as String,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      Formatters.formatCurrency(item['price'] as double),
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    if (item['originalPrice'] != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        Formatters.formatCurrency(
                            item['originalPrice'] as double),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Quantity Controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Remove button
              IconButton(
                onPressed: () => _removeItem(item['id'] as String),
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 12),

              // Quantity
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _updateQuantity(
                        item['id'] as String,
                        (item['quantity'] as int) - 1,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item['quantity']}',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _updateQuantity(
                        item['id'] as String,
                        (item['quantity'] as int) + 1,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
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

  Widget _buildCouponSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: _appliedCoupon == null
          ? InkWell(
              onTap: _showCouponBottomSheet,
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Apply Coupon',
                      style: AppTextStyles.titleSmall,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            )
          : Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _appliedCoupon!,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'You saved \u20B9${_couponDiscount.toStringAsFixed(0)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _appliedCoupon = null;
                      _couponDiscount = 0;
                    });
                  },
                  child: const Text('Remove'),
                ),
              ],
            ),
    );
  }

  Widget _buildBillDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bill Details', style: AppTextStyles.titleSmall),
          const SizedBox(height: 16),

          _buildBillRow('Item Total', _subtotal),
          if (_totalSavings > 0)
            _buildBillRow('Product Discount', -_totalSavings, isDiscount: true),
          if (_couponDiscount > 0)
            _buildBillRow('Coupon Discount', -_couponDiscount, isDiscount: true),
          _buildBillRow(
            'Delivery',
            _deliveryCharge,
            subtitle: _deliveryCharge == 0 ? 'FREE' : null,
          ),

          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('To Pay', style: AppTextStyles.titleMedium),
              Text(
                Formatters.formatCurrency(_total),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          if (_totalSavings + _couponDiscount > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(26),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.celebration, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'You\'re saving \u20B9${(_totalSavings + _couponDiscount).toStringAsFixed(0)} on this order!',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.success,
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
                      ? '-\u20B9${amount.abs().toStringAsFixed(0)}'
                      : '\u20B9${amount.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDiscount ? AppColors.success : null,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.formatCurrency(_total),
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Scroll to bill details
                    },
                    child: Text(
                      'View Bill Details',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PrimaryButton(
                text: 'Checkout',
                icon: Icons.arrow_forward,
                onPressed: () => context.push(AppRoutes.checkout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(String itemId, int newQuantity) {
    if (newQuantity < 1) {
      _removeItem(itemId);
      return;
    }

    setState(() {
      final index = _cartItems.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        _cartItems[index]['quantity'] = newQuantity;
      }
    });
  }

  void _removeItem(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Are you sure you want to remove this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cartItems.removeWhere((item) => item['id'] == itemId);
              });
            },
            child: Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showCouponBottomSheet() {
    final coupons = [
      {
        'code': 'FIRST50',
        'description': '50% off on first order',
        'discount': 50.0,
        'minOrder': 299.0,
      },
      {
        'code': 'GONGURA20',
        'description': '\u20B920 off on orders above \u20B9500',
        'discount': 20.0,
        'minOrder': 500.0,
      },
      {
        'code': 'PICKLE100',
        'description': '\u20B9100 off on orders above \u20B91000',
        'discount': 100.0,
        'minOrder': 1000.0,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apply Coupon', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),

            // Coupon input
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter coupon code',
                suffixIcon: TextButton(
                  onPressed: () {
                    // Apply entered coupon
                  },
                  child: const Text('Apply'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Available Coupons', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),

            ...coupons.map((coupon) => _buildCouponCard(coupon)),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    final isApplicable = _subtotal >= (coupon['minOrder'] as double);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isApplicable ? AppColors.primary : AppColors.divider,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isApplicable ? AppColors.primary.withAlpha(13) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    coupon['code'] as String,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  coupon['description'] as String,
                  style: AppTextStyles.bodySmall,
                ),
                if (!isApplicable)
                  Text(
                    'Add \u20B9${((coupon['minOrder'] as double) - _subtotal).toStringAsFixed(0)} more to apply',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
          if (isApplicable)
            TextButton(
              onPressed: () {
                setState(() {
                  _appliedCoupon = coupon['code'] as String;
                  _couponDiscount = coupon['discount'] as double;
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
        ],
      ),
    );
  }
}
