import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/cards/category_card.dart';
import '../../../../shared/widgets/cards/product_card.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

/// Home Screen
///
/// Main screen showing categories, banners, and products.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBannerIndex = 0;

  // Demo data - Replace with actual data from API
  final List<Map<String, String>> _categories = [
    {'name': 'Pachadi', 'image': 'https://images.unsplash.com/photo-1601648764658-cf37e8c89b70?w=200'},
    {'name': 'Chutney', 'image': 'https://images.unsplash.com/photo-1546470427-227c7aa45214?w=200'},
    {'name': 'Powder', 'image': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=200'},
  ];

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Pure Gongura Delights',
      'subtitle': 'Authentic Andhra Gongura Flavors',
      'color': AppColors.primaryLight,
    },
    {
      'title': '100% Vegetarian',
      'subtitle': 'Fresh Gongura Leaf Products',
      'color': AppColors.accentLight,
    },
    {
      'title': 'Gongura Special',
      'subtitle': 'Free delivery on orders above ₹499',
      'color': const Color(0xFFE8F5E9),
    },
  ];

  final List<Map<String, dynamic>> _featuredProducts = [
    {
      'name': 'Pure Gongura Pickle',
      'image': 'https://images.unsplash.com/photo-1601648764658-cf37e8c89b70?w=400',
      'price': 199.0,
      'originalPrice': 249.0,
      'rating': 4.8,
      'reviews': 256,
      'isVeg': true,
    },
    {
      'name': 'Gongura Pachadi',
      'image': 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',
      'price': 179.0,
      'originalPrice': 229.0,
      'rating': 4.6,
      'reviews': 189,
      'isVeg': true,
    },
    {
      'name': 'Gongura Chutney',
      'image': 'https://images.unsplash.com/photo-1546470427-227c7aa45214?w=400',
      'price': 149.0,
      'originalPrice': 199.0,
      'rating': 4.5,
      'reviews': 142,
      'isVeg': true,
    },
    {
      'name': 'Gongura Powder',
      'image': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400',
      'price': 129.0,
      'originalPrice': 169.0,
      'rating': 4.7,
      'reviews': 98,
      'isVeg': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            // Search Bar
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),
            // Banner Carousel
            SliverToBoxAdapter(
              child: _buildBannerCarousel(),
            ),
            // Categories
            SliverToBoxAdapter(
              child: _buildCategoriesSection(),
            ),
            // Featured Products
            SliverToBoxAdapter(
              child: _buildSectionTitle('Featured Products', onViewAll: () {
                context.push(AppRoutes.productList);
              }),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: _buildProductsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deliver to',
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
                      'Hyderabad, 500001',
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
              label: const Text('2'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SearchTextField(
        hint: 'Search pickles...',
        readOnly: true,
        onTap: () => context.push(AppRoutes.search),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _banners.length,
          itemBuilder: (context, index, realIndex) {
            final banner = _banners[index];
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
                            'Shop Now',
                            style: AppTypography.buttonSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('🫙', style: TextStyle(fontSize: 60)),
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
            _banners.length,
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

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Categories'),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CategoryCard(
                  name: category['name']!,
                  imageUrl: category['image']!,
                  onTap: () {
                    context.push(
                      '${AppRoutes.productList}?category=${category['name']}',
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onViewAll}) {
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
                'View All',
                style: AppTypography.buttonSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = _featuredProducts[index % _featuredProducts.length];
          return ProductCard(
            name: product['name'] as String,
            imageUrl: product['image'] as String,
            price: product['price'] as double,
            originalPrice: product['originalPrice'] as double?,
            rating: product['rating'] as double?,
            reviewCount: product['reviews'] as int?,
            isVeg: product['isVeg'] as bool,
            onTap: () {
              context.push(AppRoutes.getProductDetailRoute('sample-product'));
            },
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to cart!'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            onWishlistToggle: () {
              // TODO: Implement wishlist toggle
            },
          );
        },
        childCount: 4,
      ),
    );
  }
}
