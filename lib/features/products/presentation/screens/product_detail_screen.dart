import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

/// Product Detail Screen
///
/// Displays detailed information about a product.
class ProductDetailScreen extends StatefulWidget {
  final String slug;

  const ProductDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedQuantity = 1;
  int _selectedSizeIndex = 0;
  bool _isWishlisted = false;
  bool _isAddingToCart = false;

  // Mock product data (would come from API based on slug)
  final Map<String, dynamic> _product = {
    'name': 'Classic Gongura Pickle',
    'description':
        'Our signature gongura pickle made with fresh, hand-picked gongura leaves from Andhra Pradesh. This tangy and spicy pickle is prepared using traditional recipes passed down through generations. Perfect with hot rice, rotis, or as a side dish.',
    'price': 299.0,
    'originalPrice': 399.0,
    'images': [
      'https://via.placeholder.com/400x400/4CAF50/FFFFFF?text=Gongura+1',
      'https://via.placeholder.com/400x400/66BB6A/FFFFFF?text=Gongura+2',
      'https://via.placeholder.com/400x400/81C784/FFFFFF?text=Gongura+3',
    ],
    'isVeg': true,
    'rating': 4.5,
    'reviews': 128,
    'inStock': true,
    'sizes': [
      {'weight': '250g', 'price': 299.0, 'originalPrice': 399.0},
      {'weight': '500g', 'price': 549.0, 'originalPrice': 699.0},
      {'weight': '1kg', 'price': 999.0, 'originalPrice': 1299.0},
    ],
    'highlights': [
      'Made with 100% natural ingredients',
      'No preservatives or artificial colors',
      'Traditional Andhra recipe',
      'Fresh gongura leaves',
      'Shelf life: 6 months',
    ],
    'ingredients': 'Gongura leaves, Red chillies, Mustard seeds, Fenugreek seeds, Garlic, Salt, Sesame oil',
    'nutritionInfo': {
      'calories': '45 kcal',
      'protein': '1g',
      'carbs': '5g',
      'fat': '2.5g',
      'sodium': '580mg',
    },
  };

  int _currentImageIndex = 0;

  double get _currentPrice {
    final sizes = _product['sizes'] as List;
    return sizes[_selectedSizeIndex]['price'] as double;
  }

  double? get _currentOriginalPrice {
    final sizes = _product['sizes'] as List;
    return sizes[_selectedSizeIndex]['originalPrice'] as double?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          _buildSliverAppBar(),

          // Product Details
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(),
                const Divider(height: 1),
                _buildSizeSelector(),
                const Divider(height: 1),
                _buildQuantitySelector(),
                const Divider(height: 1),
                _buildHighlights(),
                const Divider(height: 1),
                _buildIngredients(),
                const Divider(height: 1),
                _buildNutritionInfo(),
                const Divider(height: 1),
                _buildReviews(),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    final images = _product['images'] as List;

    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(230),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Share product
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withAlpha(230),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() => _isWishlisted = !_isWishlisted);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withAlpha(230),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: _isWishlisted ? AppColors.error : null,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Image PageView
            PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemBuilder: (context, index) {
                return Container(
                  color: AppColors.backgroundSecondary,
                  child: Image.network(
                    images[index] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              },
            ),

            // Page Indicator
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),

            // Veg/Non-Veg Badge
            Positioned(
              top: 100,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _product['isVeg'] as bool
                        ? AppColors.veg
                        : AppColors.nonVeg,
                  ),
                ),
                child: Icon(
                  Icons.circle,
                  size: 12,
                  color: _product['isVeg'] as bool
                      ? AppColors.veg
                      : AppColors.nonVeg,
                ),
              ),
            ),

            // Discount Badge
            if (_currentOriginalPrice != null)
              Positioned(
                top: 100,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.discount,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${Formatters.calculateDiscountPercentage(_currentOriginalPrice!, _currentPrice)}% OFF',
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
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            _product['name'] as String,
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 8),

          // Rating
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_product['rating']}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 14, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_product['reviews']} reviews',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatCurrency(_currentPrice),
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentOriginalPrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  Formatters.formatCurrency(_currentOriginalPrice!),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textTertiary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            _product['description'] as String,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelector() {
    final sizes = _product['sizes'] as List;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Size', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              sizes.length,
              (index) {
                final size = sizes[index] as Map<String, dynamic>;
                final isSelected = index == _selectedSizeIndex;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedSizeIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withAlpha(26)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            size['weight'] as String,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCurrency(size['price'] as double),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text('Quantity', style: AppTextStyles.titleSmall),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _selectedQuantity > 1
                      ? () => setState(() => _selectedQuantity--)
                      : null,
                  icon: const Icon(Icons.remove),
                  iconSize: 20,
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '$_selectedQuantity',
                    style: AppTextStyles.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: _selectedQuantity < 10
                      ? () => setState(() => _selectedQuantity++)
                      : null,
                  icon: const Icon(Icons.add),
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights() {
    final highlights = _product['highlights'] as List;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Highlights', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          ...highlights.map((highlight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        highlight as String,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ingredients', style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
          Text(
            _product['ingredients'] as String,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo() {
    final nutrition = _product['nutritionInfo'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutrition Info (per serving)', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: nutrition.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      entry.value as String,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      entry.key.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customer Reviews', style: AppTextStyles.titleSmall),
              TextButton(
                onPressed: () {
                  // View all reviews
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Sample review
          _buildReviewCard(
            name: 'Ramesh K.',
            rating: 5,
            date: '2 weeks ago',
            review:
                'Amazing taste! Reminds me of my grandmother\'s pickle. Will definitely order again.',
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            name: 'Priya S.',
            rating: 4,
            date: '1 month ago',
            review:
                'Very good quality and authentic taste. A bit too spicy for my kids though.',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required int rating,
    required String date,
    required String review,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  name[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.labelMedium),
                    Text(
                      date,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: AppColors.rating,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final totalPrice = _currentPrice * _selectedQuantity;

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
                    'Total Price',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(totalPrice),
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PrimaryButton(
                text: 'Add to Cart',
                isLoading: _isAddingToCart,
                onPressed: _handleAddToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddToCart() async {
    setState(() => _isAddingToCart = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isAddingToCart = false);

    if (mounted) {
      final router = GoRouter.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_product['name']} added to cart'),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () => router.push(AppRoutes.cart),
          ),
        ),
      );
    }
  }
}
