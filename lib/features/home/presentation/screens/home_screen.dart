import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/data/models/product_inventory_model.dart';
import '../../../../core/data/models/wishlist_item_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cards/product_card.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

/// Home Screen
///
/// Main screen showing categories, banners, and products from Firestore.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBannerIndex = 0;
  List<ProductInventoryModel> _featuredProducts = [];
  bool _isLoading = true;
  StreamSubscription? _inventorySubscription;
  StreamSubscription<BoxEvent>? _cartSubscription;
  int _cartItemCount = 0;
  String? _defaultAddressDisplay;

  List<Map<String, dynamic>> _getCategories(AppLocalizations l10n) => [
    {'name': l10n.pachadi, 'icon': Icons.rice_bowl, 'key': 'Pachadi'},
    {'name': l10n.chutney, 'icon': Icons.blender, 'key': 'Chutney'},
    {'name': l10n.powder, 'icon': Icons.grain, 'key': 'Powder'},
  ];

  List<Map<String, dynamic>> _getBanners(AppLocalizations l10n) => [
    {
      'title': l10n.bannerTitle1,
      'subtitle': l10n.bannerSubtitle1,
      'color': AppColors.primaryLight,
      'icon': Icons.eco,
    },
    {
      'title': l10n.bannerTitle2,
      'subtitle': l10n.bannerSubtitle2,
      'color': AppColors.accentLight,
      'icon': Icons.spa,
    },
    {
      'title': l10n.bannerTitle3,
      'subtitle': l10n.bannerSubtitle3,
      'color': const Color(0xFFE8F5E9),
      'icon': Icons.local_shipping,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _listenToCart();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final userId = authService.currentUser?.uid;
    if (userId == null) return;

    try {
      final defaultAddress = await addressService.getDefaultAddress(userId);
      if (mounted && defaultAddress != null) {
        setState(() {
          _defaultAddressDisplay = '${defaultAddress.city}, ${defaultAddress.pincode}';
        });
      }
    } catch (e) {
      // Silently fail - will show default placeholder
    }
  }

  @override
  void dispose() {
    _inventorySubscription?.cancel();
    _cartSubscription?.cancel();
    super.dispose();
  }

  void _loadProducts() {
    // First, check if we already have cached inventory data
    final cachedProducts = inventoryService.cachedInventory;
    if (cachedProducts.isNotEmpty) {
      _featuredProducts = cachedProducts.values
          .where((p) => p.isActive && p.isInStock)
          .take(6)
          .toList();
      _isLoading = false;
    }

    // Listen to inventory stream for real-time updates
    _inventorySubscription = inventoryService.inventoryStream.listen(
      (productsMap) {
        if (mounted) {
          setState(() {
            // Get featured products (active, in stock, limit to 6)
            _featuredProducts = productsMap.values
                .where((p) => p.isActive && p.isInStock)
                .take(6)
                .toList();
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  void _listenToCart() {
    // Update cart badge count
    _cartItemCount = cartRepository.itemCount;
    _cartSubscription = cartRepository.watch().listen((_) {
      if (mounted) {
        setState(() {
          _cartItemCount = cartRepository.itemCount;
        });
      }
    });
  }

  void _toggleWishlist(ProductInventoryModel product) async {
    final item = WishlistItemModel(
      productSlug: product.productSlug,
      productName: product.productName,
      productImage: product.productImage,
      basePrice: product.basePrice,
      category: product.category,
      isVeg: product.isVeg,
      addedAt: DateTime.now(),
    );

    final added = await wishlistRepository.toggleItem(item);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${product.productName} added to wishlist'
              : '${product.productName} removed from wishlist',
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: _buildHeader(l10n),
            ),
            // Search Bar
            SliverToBoxAdapter(
              child: _buildSearchBar(l10n),
            ),
            // Banner Carousel
            SliverToBoxAdapter(
              child: _buildBannerCarousel(l10n),
            ),
            // Categories
            SliverToBoxAdapter(
              child: _buildCategoriesSection(l10n),
            ),
            // Featured Products
            SliverToBoxAdapter(
              child: _buildSectionTitle(l10n.featuredProducts, onViewAll: () {
                context.push(AppRoutes.productList);
              }, l10n: l10n),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: _buildProductsGrid(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.deliverTo,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _defaultAddressDisplay ?? 'Add Address',
                      style: AppTypography.labelLarge,
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notifications
          IconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: Badge(
              smallSize: 8,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          // Cart
          IconButton(
            onPressed: () => context.push(AppRoutes.cart),
            icon: Badge(
              isLabelVisible: _cartItemCount > 0,
              label: Text('$_cartItemCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SearchTextField(
        hint: l10n.searchPickles,
        readOnly: true,
        onTap: () => context.push(AppRoutes.search),
      ),
    );
  }

  Widget _buildBannerCarousel(AppLocalizations l10n) {
    final banners = _getBanners(l10n);
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: banners.length,
          itemBuilder: (context, index, realIndex) {
            final banner = banners[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: banner['color'] as Color,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner['title'] as String,
                          style: AppTypography.h3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner['subtitle'] as String,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.shopNow,
                            style: AppTypography.buttonSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        banner['icon'] as IconData,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            height: 160,
            viewportFraction: 0.92,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, reason) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: index == _currentBannerIndex ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: index == _currentBannerIndex
                    ? AppColors.primary
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(AppLocalizations l10n) {
    final categories = _getCategories(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.categories, l10n: l10n),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    context.push(
                      '${AppRoutes.productList}?category=${category['key']}',
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(26),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withAlpha(50),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            category['icon'] as IconData,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onViewAll, required AppLocalizations l10n}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.sectionTitle),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text(
                l10n.viewAll,
                style: AppTypography.buttonSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(AppLocalizations l10n) {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_featuredProducts.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No products available',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = _featuredProducts[index];
          final isWishlisted = wishlistRepository.isInWishlist(product.productSlug);
          final isNetworkImage = product.productImage.startsWith('http');

          return ProductCard(
            name: product.productName,
            imageUrl: product.productImage,
            price: product.basePrice,
            isVeg: product.isVeg,
            isAsset: !isNetworkImage,
            isWishlisted: isWishlisted,
            onTap: () {
              context.push(AppRoutes.getProductDetailRoute(product.productSlug));
            },
            onAddToCart: () {
              context.push(AppRoutes.getProductDetailRoute(product.productSlug));
            },
            onWishlistToggle: () => _toggleWishlist(product),
          );
        },
        childCount: _featuredProducts.length,
      ),
    );
  }
}
