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
  int _selectedSizeIndex = 0;
  bool _isWishlisted = false;
  bool _isAddingToCart = false;

  // Product data mapped by slug
  static final Map<String, Map<String, dynamic>> _productsData = {
    'traditional-gongura-pachadi': {
      'name': 'Traditional Gongura Pachadi',
      'description':
          'Authentic Andhra-style gongura pachadi made with fresh, hand-picked gongura leaves. This tangy and spicy pachadi is prepared using traditional recipes passed down through generations. Perfect accompaniment for hot rice and rotis.',
      'price': 199.0,
      'images': [
        'https://images.unsplash.com/photo-1601648764658-cf37e8c89b70?w=400',
        'https://images.unsplash.com/photo-1601648764658-cf37e8c89b70?w=400',
        'https://images.unsplash.com/photo-1601648764658-cf37e8c89b70?w=400',
      ],
      'isVeg': true,
      'inStock': true,
      'sizes': [
        {
          'weight': '250g',
          'price': 199.0,
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': 'Calories', 'value': '112 kcal'},
            {'icon': Icons.fitness_center, 'label': 'Protein', 'value': '2.5g'},
            {'icon': Icons.bakery_dining, 'label': 'Carbs', 'value': '12.5g'},
            {'icon': Icons.opacity, 'label': 'Fat', 'value': '6.3g'},
            {'icon': Icons.water_drop, 'label': 'Sodium', 'value': '1450mg'},
          ],
        },
        {
          'weight': '500g',
          'price': 379.0,
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': 'Calories', 'value': '225 kcal'},
            {'icon': Icons.fitness_center, 'label': 'Protein', 'value': '5g'},
            {'icon': Icons.bakery_dining, 'label': 'Carbs', 'value': '25g'},
            {'icon': Icons.opacity, 'label': 'Fat', 'value': '12.5g'},
            {'icon': Icons.water_drop, 'label': 'Sodium', 'value': '2900mg'},
          ],
        },
        {
          'weight': '1kg',
          'price': 699.0,
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': 'Calories', 'value': '450 kcal'},
            {'icon': Icons.fitness_center, 'label': 'Protein', 'value': '10g'},
            {'icon': Icons.bakery_dining, 'label': 'Carbs', 'value': '50g'},
            {'icon': Icons.opacity, 'label': 'Fat', 'value': '25g'},
            {'icon': Icons.water_drop, 'label': 'Sodium', 'value': '5800mg'},
          ],
        },
      ],
      'highlights': [
        {'icon': Icons.eco, 'text': 'Made with 100% natural ingredients'},
        {'icon': Icons.verified, 'text': 'No preservatives or artificial colors'},
        {'icon': Icons.menu_book, 'text': 'Traditional Andhra recipe'},
        {'icon': Icons.spa, 'text': 'Fresh gongura leaves from Andhra Pradesh'},
        {'icon': Icons.schedule, 'text': 'Shelf life: 6 months'},
      ],
      'ingredients': [
        {'icon': Icons.eco, 'name': 'Gongura Leaves'},
        {'icon': Icons.whatshot, 'name': 'Red Chillies'},
        {'icon': Icons.grain, 'name': 'Mustard Seeds'},
        {'icon': Icons.grass, 'name': 'Fenugreek Seeds'},
        {'icon': Icons.restaurant, 'name': 'Garlic'},
        {'icon': Icons.water_drop, 'name': 'Salt'},
        {'icon': Icons.opacity, 'name': 'Sesame Oil'},
      ],
    },
    'classic-gongura-chutney': {
      'name': 'Classic Gongura Chutney',
      'description':
          'A delicious gongura chutney with the perfect blend of tangy and spicy flavors. Made fresh with tender gongura leaves, this chutney adds a burst of authentic South Indian taste to any meal. Ideal for dosas, idlis, and rice.',
      'price': 149.0,
      'images': [
        'https://images.unsplash.com/photo-1546470427-227c7aa45214?w=400',
        'https://images.unsplash.com/photo-1546470427-227c7aa45214?w=400',
        'https://images.unsplash.com/photo-1546470427-227c7aa45214?w=400',
      ],
      'isVeg': true,
      'inStock': true,
      'sizes': [
        {
          'weight': '200g',
          'price': 149.0,
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': 'Calories', 'value': '76 kcal'},
            {'icon': Icons.fitness_center, 'label': 'Protein', 'value': '1.6g'},
            {'icon': Icons.bakery_dining, 'label': 'Carbs', 'value': '8g'},
            {'icon': Icons.opacity, 'label': 'Fat', 'value': '4g'},
            {'icon': Icons.water_drop, 'label': 'Sodium', 'value': '1040mg'},
          ],
        },
        {
          'weight': '400g',
          'price': 279.0,
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': 'Calories', 'value': '152 kcal'},
            {'icon': Icons.fitness_center, 'label': 'Protein', 'value': '3.2g'},
            {'icon': Icons.bakery_dining, 'label': 'Carbs', 'value': '16g'},
            {'icon': Icons.opacity, 'label': 'Fat', 'value': '8g'},
            {'icon': Icons.water_drop, 'label': 'Sodium', 'value': '2080mg'},
          ],
        },
        {
          'weight': '800g',
          'price': 529.0,
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': 'Calories', 'value': '304 kcal'},
            {'icon': Icons.fitness_center, 'label': 'Protein', 'value': '6.4g'},
            {'icon': Icons.bakery_dining, 'label': 'Carbs', 'value': '32g'},
            {'icon': Icons.opacity, 'label': 'Fat', 'value': '16g'},
            {'icon': Icons.water_drop, 'label': 'Sodium', 'value': '4160mg'},
          ],
        },
      ],
      'highlights': [
        {'icon': Icons.balance, 'text': 'Perfect tangy-spicy balance'},
        {'icon': Icons.verified, 'text': 'No artificial flavors or colors'},
        {'icon': Icons.grain, 'text': 'Freshly ground spices'},
        {'icon': Icons.back_hand, 'text': 'Handcrafted in small batches'},
        {'icon': Icons.schedule, 'text': 'Shelf life: 4 months'},
      ],
      'ingredients': [
        {'icon': Icons.eco, 'name': 'Gongura Leaves'},
        {'icon': Icons.local_fire_department, 'name': 'Green Chillies'},
        {'icon': Icons.nature, 'name': 'Tamarind'},
        {'icon': Icons.grain, 'name': 'Cumin Seeds'},
        {'icon': Icons.restaurant, 'name': 'Garlic'},
        {'icon': Icons.water_drop, 'name': 'Salt'},
        {'icon': Icons.opacity, 'name': 'Groundnut Oil'},
      ],
    },
    'spicy-gongura-podi': {
      'name': 'Spicy Gongura Podi',
      'description':
          'A flavorful dry powder made from sun-dried gongura leaves and aromatic spices. This versatile podi can be mixed with rice and ghee, sprinkled on dosas, or used as a seasoning. A must-have for gongura lovers!',
      'price': 139.0,
      'images': [
        'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400',
        'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400',
        'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400',
      ],
      'isVeg': true,
      'inStock': true,
      'sizes': [
        {
          'weight': '100g',
          'price': 139.0,
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': 'Calories', 'value': '52 kcal'},
            {'icon': Icons.fitness_center, 'label': 'Protein', 'value': '2g'},
            {'icon': Icons.bakery_dining, 'label': 'Carbs', 'value': '6g'},
            {'icon': Icons.opacity, 'label': 'Fat', 'value': '3g'},
            {'icon': Icons.water_drop, 'label': 'Sodium', 'value': '480mg'},
          ],
        },
        {
          'weight': '250g',
          'price': 319.0,
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': 'Calories', 'value': '130 kcal'},
            {'icon': Icons.fitness_center, 'label': 'Protein', 'value': '5g'},
            {'icon': Icons.bakery_dining, 'label': 'Carbs', 'value': '15g'},
            {'icon': Icons.opacity, 'label': 'Fat', 'value': '7.5g'},
            {'icon': Icons.water_drop, 'label': 'Sodium', 'value': '1200mg'},
          ],
        },
        {
          'weight': '500g',
          'price': 599.0,
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': 'Calories', 'value': '260 kcal'},
            {'icon': Icons.fitness_center, 'label': 'Protein', 'value': '10g'},
            {'icon': Icons.bakery_dining, 'label': 'Carbs', 'value': '30g'},
            {'icon': Icons.opacity, 'label': 'Fat', 'value': '15g'},
            {'icon': Icons.water_drop, 'label': 'Sodium', 'value': '2400mg'},
          ],
        },
      ],
      'highlights': [
        {'icon': Icons.wb_sunny, 'text': 'Sun-dried gongura leaves'},
        {'icon': Icons.grain, 'text': 'Coarsely ground for best texture'},
        {'icon': Icons.favorite, 'text': 'Rich in iron and vitamins'},
        {'icon': Icons.schedule, 'text': 'Long shelf life - 8 months'},
        {'icon': Icons.auto_awesome, 'text': 'Versatile usage'},
      ],
      'ingredients': [
        {'icon': Icons.eco, 'name': 'Dried Gongura Leaves'},
        {'icon': Icons.whatshot, 'name': 'Red Chillies'},
        {'icon': Icons.egg_alt, 'name': 'Urad Dal'},
        {'icon': Icons.circle, 'name': 'Chana Dal'},
        {'icon': Icons.grain, 'name': 'Cumin'},
        {'icon': Icons.restaurant, 'name': 'Garlic'},
        {'icon': Icons.water_drop, 'name': 'Salt'},
      ],
    },
  };

  Map<String, dynamic> get _product {
    return _productsData[widget.slug] ?? _productsData['traditional-gongura-pachadi']!;
  }

  int _currentImageIndex = 0;

  double get _currentPrice {
    final sizes = _product['sizes'] as List;
    return sizes[_selectedSizeIndex]['price'] as double;
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
                _buildHighlights(),
                const Divider(height: 1),
                _buildIngredients(),
                const Divider(height: 1),
                _buildNutritionInfo(),
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
          const SizedBox(height: 12),

          // Price
          Text(
            Formatters.formatCurrency(_currentPrice),
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
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

  Widget _buildHighlights() {
    final highlights = _product['highlights'] as List;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Highlights', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          ...highlights.map((highlight) {
            final highlightData = highlight as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      highlightData['icon'] as IconData,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      highlightData['text'] as String,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    final ingredients = _product['ingredients'] as List;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ingredients', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ingredients.map((ingredient) {
              final ingredientData = ingredient as Map<String, dynamic>;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ingredientData['icon'] as IconData,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ingredientData['name'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
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

  Widget _buildNutritionInfo() {
    final sizes = _product['sizes'] as List;
    final selectedSize = sizes[_selectedSizeIndex] as Map<String, dynamic>;
    final nutrition = selectedSize['nutritionInfo'] as List;
    final weight = selectedSize['weight'] as String;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutrition Info (per $weight)', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: nutrition.map((item) {
              final nutritionData = item as Map<String, dynamic>;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        nutritionData['icon'] as IconData,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nutritionData['value'] as String,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nutritionData['label'] as String,
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

  Widget _buildBottomBar() {
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
                    'Price',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(_currentPrice),
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
