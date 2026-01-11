import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/models/cart_item_model.dart';
import '../../../../core/data/models/coupon_model.dart';
import '../../../../core/data/repositories/cart_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
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
  CouponModel? _appliedCoupon;
  double _discountAmount = 0;
  List<CouponModel> _availableCoupons = [];
  bool _isLoadingCoupons = false;

  // Size configuration matching product details screen
  int _getMaxQuantity(int sizeIndex) {
    switch (sizeIndex) {
      case 0:
        return 2;
      case 1:
        return 4;
      case 2:
        return 5;
      default:
        return 2;
    }
  }

  IconData _getSizeIcon(String sizeCode) {
    switch (sizeCode) {
      case 'S':
        return Icons.eco;
      case 'M':
        return Icons.nature;
      case 'L':
        return Icons.forest;
      default:
        return Icons.eco;
    }
  }

  int _getSizeIndex(String sizeCode) {
    switch (sizeCode) {
      case 'S':
        return 0;
      case 'M':
        return 1;
      case 'L':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cartItems = cartRepository.getItems();
    final subtotal = cartRepository.subtotal;
    final isFreeDelivery = _appliedCoupon?.type == CouponType.freeDelivery;
    final deliveryCharge = isFreeDelivery ? 0.0 : cartRepository.calculateDeliveryCharge(subtotal);
    final total = subtotal - _discountAmount + deliveryCharge;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${l10n.myCart} (${cartItems.length})'),
      ),
      body: cartItems.isEmpty ? _buildEmptyCart(l10n) : _buildCartContent(l10n, cartItems, subtotal),
      bottomNavigationBar:
          cartItems.isEmpty ? null : _buildCheckoutBar(l10n, total),
    );
  }

  Widget _buildEmptyCart(AppLocalizations l10n) {
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
            l10n.cartEmpty,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addPicklesToCart,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: l10n.browseProducts,
            onPressed: () => context.push(AppRoutes.productList),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(AppLocalizations l10n, List<CartItemModel> cartItems, double subtotal) {
    final isFreeDelivery = _appliedCoupon?.type == CouponType.freeDelivery;
    final deliveryCharge = isFreeDelivery ? 0.0 : cartRepository.calculateDeliveryCharge(subtotal);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Free Delivery Banner
          if (subtotal < CartRepository.freeDeliveryThreshold)
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
                      l10n.addMoreForFreeDelivery((CartRepository.freeDeliveryThreshold - subtotal).toStringAsFixed(0)),
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
            itemCount: cartItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildCartItem(cartItems[index], l10n),
          ),

          const SizedBox(height: 16),

          // Coupon Section
          _buildCouponSection(l10n, subtotal),

          const SizedBox(height: 16),

          // Bill Details
          _buildBillDetails(l10n, subtotal, deliveryCharge, _discountAmount),

          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item, AppLocalizations l10n) {
    final sizeIndex = _getSizeIndex(item.sizeCode);
    final maxQuantity = _getMaxQuantity(sizeIndex);
    final sizeIcon = _getSizeIcon(item.sizeCode);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.backgroundSecondary,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Image.asset(
                      item.productImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.eco,
                          color: AppColors.primary.withAlpha(100),
                          size: 32,
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
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: item.isVeg ? AppColors.veg : AppColors.nonVeg,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: item.isVeg ? AppColors.veg : AppColors.nonVeg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      item.productName,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Size Badge with Icon
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            sizeIcon,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.weight,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Text(
                      Formatters.formatCurrency(item.price),
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Remove button
              GestureDetector(
                onTap: () => _removeItem(item),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          // Quantity Controls with Leaf Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Leaf quantity display
              Row(
                children: [
                  Text(
                    '${l10n.quantity}: ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  ...List.generate(
                    item.quantity,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.eco,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              // Quantity Control Buttons
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Minus button
                    GestureDetector(
                      onTap: () => _updateQuantity(item, item.quantity - 1, sizeIndex),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Leaf icons in the middle
                    Container(
                      constraints: const BoxConstraints(minWidth: 50),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          item.quantity,
                          (index) => Padding(
                            padding: EdgeInsets.only(left: index > 0 ? 2 : 0),
                            child: const Icon(
                              Icons.eco,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Plus button
                    GestureDetector(
                      onTap: item.quantity < maxQuantity
                          ? () => _updateQuantity(item, item.quantity + 1, sizeIndex)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.quantity < maxQuantity
                              ? Colors.white.withAlpha(51)
                              : Colors.white.withAlpha(20),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: item.quantity < maxQuantity
                              ? Colors.white
                              : Colors.white.withAlpha(100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Max quantity hint
          if (item.quantity >= maxQuantity) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.maxQuantityHint(maxQuantity),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponSection(AppLocalizations l10n, double subtotal) {
    String savingsText;
    if (_appliedCoupon?.type == CouponType.freeDelivery) {
      savingsText = 'Free Delivery Applied!';
    } else {
      savingsText = l10n.youSaved(_discountAmount.toStringAsFixed(0));
    }

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
              onTap: () => _showCouponBottomSheet(l10n, subtotal),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.applyCoupon,
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
                        _appliedCoupon!.code,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        savingsText,
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
                      _discountAmount = 0;
                    });
                  },
                  child: Text(l10n.remove),
                ),
              ],
            ),
    );
  }

  Widget _buildBillDetails(AppLocalizations l10n, double subtotal, double deliveryCharge, double discount) {
    final total = subtotal - discount + deliveryCharge;

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
          Text(l10n.billDetails, style: AppTextStyles.titleSmall),
          const SizedBox(height: 16),

          _buildBillRow(l10n.itemTotal, subtotal),
          if (discount > 0)
            _buildBillRow(l10n.couponDiscount, -discount, isDiscount: true),
          _buildBillRow(
            l10n.delivery,
            deliveryCharge,
            subtitle: deliveryCharge == 0 ? l10n.free : null,
          ),

          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.toPay, style: AppTextStyles.titleMedium),
              Text(
                Formatters.formatCurrency(total),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          if (discount > 0) ...[
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
                    l10n.savedWithCoupon(discount.toStringAsFixed(0)),
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

  Widget _buildCheckoutBar(AppLocalizations l10n, double total) {
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
                    Formatters.formatCurrency(total),
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Scroll to bill details
                    },
                    child: Text(
                      l10n.viewBillDetails,
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
                text: l10n.checkout,
                icon: Icons.arrow_forward,
                onPressed: () => context.push(AppRoutes.checkout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateQuantity(CartItemModel item, int newQuantity, int sizeIndex) async {
    if (newQuantity < 1) {
      _removeItem(item);
      return;
    }

    final maxQuantity = _getMaxQuantity(sizeIndex);
    if (newQuantity > maxQuantity) {
      return;
    }

    await cartRepository.updateQuantity(item.productSlug, item.sizeCode, newQuantity);
    setState(() {});
  }

  void _removeItem(CartItemModel item) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeItem),
        content: Text(l10n.removeItemConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await cartRepository.removeItem(item.productSlug, item.sizeCode);
              setState(() {});
            },
            child: Text(
              l10n.remove,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showCouponBottomSheet(AppLocalizations l10n, double subtotal) {
    final couponController = TextEditingController();
    String? errorMessage;
    bool isValidating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (builderContext, setSheetState) {
          Future<void> applyCouponCode(String code) async {
            if (code.isEmpty) return;

            setSheetState(() {
              isValidating = true;
              errorMessage = null;
            });

            final result = await couponService.validateCoupon(
              code: code,
              orderAmount: subtotal,
            );

            if (!builderContext.mounted) return;

            setSheetState(() {
              isValidating = false;
            });

            if (result.isValid && result.coupon != null) {
              Navigator.pop(builderContext);
              setState(() {
                _appliedCoupon = result.coupon;
                _discountAmount = result.discountAmount;
              });
            } else {
              setSheetState(() {
                errorMessage = result.errorMessage ?? 'Invalid coupon';
              });
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(builderContext).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.applyCoupon, style: AppTextStyles.headlineSmall),
                const SizedBox(height: 16),

                // Coupon input
                TextField(
                  controller: couponController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: l10n.enterCouponCode,
                    errorText: errorMessage,
                    suffixIcon: isValidating
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : TextButton(
                            onPressed: () => applyCouponCode(couponController.text),
                            child: Text(l10n.apply),
                          ),
                  ),
                  onSubmitted: applyCouponCode,
                ),
                const SizedBox(height: 24),

                Text(l10n.availableCoupons, style: AppTextStyles.titleSmall),
                const SizedBox(height: 12),

                // Available Coupons from Firestore
                FutureBuilder<List<CouponModel>>(
                  future: couponService.getActiveCoupons(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final coupons = snapshot.data ?? [];

                    if (coupons.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No coupons available',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: coupons.map((coupon) => _buildCouponCard(
                        coupon,
                        l10n,
                        subtotal,
                        onApply: () async {
                          await applyCouponCode(coupon.code);
                        },
                      )).toList(),
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCouponCard(
    CouponModel coupon,
    AppLocalizations l10n,
    double subtotal, {
    required VoidCallback onApply,
  }) {
    final isApplicable = subtotal >= coupon.minOrderAmount;

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
                    coupon.code,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  coupon.description,
                  style: AppTextStyles.bodySmall,
                ),
                if (!isApplicable)
                  Text(
                    l10n.addMoreToApply((coupon.minOrderAmount - subtotal).toStringAsFixed(0)),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
          if (isApplicable)
            TextButton(
              onPressed: onApply,
              child: Text(l10n.apply),
            ),
        ],
      ),
    );
  }
}
