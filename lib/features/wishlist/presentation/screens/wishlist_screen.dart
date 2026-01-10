import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
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
  // Track which items are in wishlist by their slugs
  final Set<String> _wishlistItemSlugs = {
    'traditional-gongura-pachadi',
    'classic-gongura-chutney',
    'spicy-gongura-podi',
  };

  // Generate localized wishlist items with asset images
  List<Map<String, dynamic>> _getWishlistItems(AppLocalizations l10n) {
    final allProducts = [
      {
        'id': '1',
        'name': l10n.traditionalGonguraPachadi,
        'price': 199.0,
        'image': 'assets/images/GonguraPickle.png',
        'isVeg': true,
        'inStock': true,
        'slug': 'traditional-gongura-pachadi',
        'category': l10n.pachadi,
      },
      {
        'id': '2',
        'name': l10n.classicGonguraChutney,
        'price': 149.0,
        'image': 'assets/images/GonguraChutney.png',
        'isVeg': true,
        'inStock': true,
        'slug': 'classic-gongura-chutney',
        'category': l10n.chutney,
      },
      {
        'id': '3',
        'name': l10n.spicyGonguraPodi,
        'price': 129.0,
        'image': 'assets/images/GonguraPowder.png',
        'isVeg': true,
        'inStock': true,
        'slug': 'spicy-gongura-podi',
        'category': l10n.powder,
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlistItems.length,
      itemBuilder: (context, index) {
        final item = wishlistItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildWishlistCard(item, l10n),
        );
      },
    );
  }

  Widget _buildWishlistCard(Map<String, dynamic> item, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.getProductDetailRoute(item['slug'] as String));
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withAlpha(15),
                          AppColors.primary.withAlpha(8),
                        ],
                      ),
                    ),
                    child: Image.asset(
                      item['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.eco,
                          size: 48,
                          color: AppColors.primary.withAlpha(60),
                        ),
                      ),
                    ),
                  ),
                ),
                // Wishlist Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      final slug = item['slug'] as String;
                      setState(() {
                        _wishlistItemSlugs.remove(slug);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item['name']} ${l10n.removedFromWishlist}'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        size: 22,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                // Category Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco,
                          size: 14,
                          color: AppColors.veg,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['category'] as String,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B5E20),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              Formatters.formatCurrency(item['price'] as double),
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'onwards',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add to Cart Button - navigates to product details
                  GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.getProductDetailRoute(item['slug'] as String));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.add,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
