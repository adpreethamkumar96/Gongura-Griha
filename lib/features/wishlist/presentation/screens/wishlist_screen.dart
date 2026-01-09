import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/product_card.dart';

/// Wishlist Screen
///
/// Displays user's saved/wishlisted products.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // Mock wishlist data - matching gongura products
  final List<Map<String, dynamic>> _wishlistItems = [
    {
      'id': '1',
      'name': 'Traditional Gongura Pachadi',
      'price': 199.0,
      'image': 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',
      'isVeg': true,
      'inStock': true,
      'slug': 'traditional-gongura-pachadi',
    },
    {
      'id': '2',
      'name': 'Classic Gongura Chutney',
      'price': 149.0,
      'image': 'https://images.unsplash.com/photo-1606471191009-63994c53433b?w=400',
      'isVeg': true,
      'inStock': true,
      'slug': 'classic-gongura-chutney',
    },
    {
      'id': '3',
      'name': 'Spicy Gongura Podi',
      'price': 139.0,
      'image': 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=400',
      'isVeg': true,
      'inStock': true,
      'slug': 'spicy-gongura-podi',
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
        crossAxisCount: 1,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: _wishlistItems.length,
      itemBuilder: (context, index) {
        final item = _wishlistItems[index];
        return ProductCard(
          name: item['name'] as String,
          price: item['price'] as double,
          imageUrl: item['image'] as String,
          isVeg: item['isVeg'] as bool,
          isOutOfStock: !(item['inStock'] as bool),
          isWishlisted: true,
          onTap: () {
            context.push(AppRoutes.getProductDetailRoute(item['slug'] as String));
          },
          onAddToCart: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item['name']} added to cart'),
                backgroundColor: const Color(0xFF4A7C59),
                action: SnackBarAction(
                  label: 'VIEW CART',
                  textColor: Colors.white,
                  onPressed: () => context.push(AppRoutes.cart),
                ),
              ),
            );
          },
          onWishlistToggle: () {
            setState(() {
              _wishlistItems.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Removed from wishlist'),
                backgroundColor: Color(0xFF4A7C59),
              ),
            );
          },
        );
      },
    );
  }
}
