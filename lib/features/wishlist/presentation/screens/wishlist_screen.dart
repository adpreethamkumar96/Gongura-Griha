import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

/// Wishlist Screen
///
/// Displays user's saved/wishlisted products.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // Mock wishlist data
  final List<Map<String, dynamic>> _wishlistItems = [
    {
      'id': '1',
      'name': 'Classic Gongura Pickle',
      'price': 299.0,
      'originalPrice': 399.0,
      'image': 'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Gongura',
      'isVeg': true,
      'inStock': true,
      'slug': 'classic-gongura-pickle',
    },
    {
      'id': '2',
      'name': 'Spicy Gongura Mutton',
      'price': 549.0,
      'originalPrice': 649.0,
      'image': 'https://via.placeholder.com/150x150/FF5722/FFFFFF?text=Mutton',
      'isVeg': false,
      'inStock': true,
      'slug': 'spicy-gongura-mutton',
    },
    {
      'id': '3',
      'name': 'Gongura Prawns Pickle',
      'price': 599.0,
      'originalPrice': null,
      'image': 'https://via.placeholder.com/150x150/2196F3/FFFFFF?text=Prawns',
      'isVeg': false,
      'inStock': false,
      'slug': 'gongura-prawns-pickle',
    },
    {
      'id': '4',
      'name': 'Sweet Gongura Chutney',
      'price': 199.0,
      'originalPrice': 249.0,
      'image': 'https://via.placeholder.com/150x150/9C27B0/FFFFFF?text=Sweet',
      'isVeg': true,
      'inStock': true,
      'slug': 'sweet-gongura-chutney',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Wishlist (${_wishlistItems.length})'),
      ),
      body: _wishlistItems.isEmpty ? _buildEmptyState() : _buildWishlistGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save your favorite pickles here',
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

  Widget _buildWishlistGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _wishlistItems.length,
      itemBuilder: (context, index) {
        return _buildWishlistCard(_wishlistItems[index]);
      },
    );
  }

  Widget _buildWishlistCard(Map<String, dynamic> item) {
    final inStock = item['inStock'] as bool;

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.getProductDetailRoute(item['slug'] as String));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with remove button
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: ColorFiltered(
                      colorFilter: inStock
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                          : ColorFilter.mode(
                              Colors.grey.shade400,
                              BlendMode.saturation,
                            ),
                      child: Image.network(
                        item['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.backgroundSecondary,
                          child: Icon(
                            Icons.image,
                            color: AppColors.textTertiary,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Out of stock overlay
                if (!inStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(102),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Out of Stock',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Remove button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeFromWishlist(item['id'] as String),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // Veg indicator
                Positioned(
                  top: 8,
                  left: 8,
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
                      color: item['isVeg'] as bool
                          ? AppColors.veg
                          : AppColors.nonVeg,
                    ),
                  ),
                ),

                // Discount badge
                if (item['originalPrice'] != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.discount,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${Formatters.calculateDiscountPercentage(item['originalPrice'] as double, item['price'] as double)}% OFF',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            ),

            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        item['name'] as String,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                  Row(
                    children: [
                      Text(
                        Formatters.formatCurrency(item['price'] as double),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      if (item['originalPrice'] != null) ...[
                        const SizedBox(width: 4),
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
                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      child: inStock
                          ? OutlinedButton(
                              onPressed: () => _addToCart(item),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                              ),
                              child: const Text('Add to Cart'),
                            )
                          : OutlinedButton(
                              onPressed: null,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                              ),
                              child: const Text('Notify Me'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeFromWishlist(String itemId) {
    setState(() {
      _wishlistItems.removeWhere((item) => item['id'] == itemId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from wishlist'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Undo remove
          },
        ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to cart'),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () => context.push(AppRoutes.cart),
        ),
      ),
    );
  }
}
