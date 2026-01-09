import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
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
  // Track which items are in wishlist by their slugs
  final Set<String> _wishlistItemSlugs = {
    'traditional-gongura-pachadi',
    'classic-gongura-chutney',
    'spicy-gongura-podi',
  };

  // Generate localized wishlist items
  List<Map<String, dynamic>> _getWishlistItems(AppLocalizations l10n) {
    final allProducts = [
      {
        'id': '1',
        'name': l10n.traditionalGonguraPachadi,
        'price': 199.0,
        'image': 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',
        'isVeg': true,
        'inStock': true,
        'slug': 'traditional-gongura-pachadi',
      },
      {
        'id': '2',
        'name': l10n.classicGonguraChutney,
        'price': 149.0,
        'image': 'https://images.unsplash.com/photo-1606471191009-63994c53433b?w=400',
        'isVeg': true,
        'inStock': true,
        'slug': 'classic-gongura-chutney',
      },
      {
        'id': '3',
        'name': l10n.spicyGonguraPodi,
        'price': 139.0,
        'image': 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=400',
        'isVeg': true,
        'inStock': true,
        'slug': 'spicy-gongura-podi',
      },
    ];
    return allProducts.where((p) => _wishlistItemSlugs.contains(p['slug'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wishlistItems = _getWishlistItems(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${l10n.wishlist} (${wishlistItems.length})'),
      ),
      body: wishlistItems.isEmpty
          ? _buildEmptyState(l10n)
          : _buildWishlistGrid(wishlistItems, l10n),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
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
            l10n.wishlistEmpty,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.saveItemsForLater,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: l10n.discoverProducts,
            onPressed: () => context.push(AppRoutes.productList),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistGrid(List<Map<String, dynamic>> wishlistItems, AppLocalizations l10n) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: wishlistItems.length,
      itemBuilder: (context, index) {
        final item = wishlistItems[index];
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
                content: Text('${item['name']} ${l10n.addedToCart}'),
                backgroundColor: const Color(0xFF4A7C59),
                action: SnackBarAction(
                  label: l10n.viewCart,
                  textColor: Colors.white,
                  onPressed: () => context.push(AppRoutes.cart),
                ),
              ),
            );
          },
          onWishlistToggle: () {
            final slug = item['slug'] as String;
            setState(() {
              _wishlistItemSlugs.remove(slug);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item['name']} ${l10n.removedFromWishlist}'),
                backgroundColor: const Color(0xFF4A7C59),
              ),
            );
          },
        );
      },
    );
  }
}
