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
        {'weight': '250g', 'price': 199.0},
        {'weight': '500g', 'price': 379.0},
        {'weight': '1kg', 'price': 699.0},
      ],
      'highlights': [
        {'icon': Icons.eco, 'text': 'Made with 100% natural ingredients'},
        {'icon': Icons.verified, 'text': 'No preservatives or artificial colors'},
        {'icon': Icons.menu_book, 'text': 'Traditional Andhra recipe'},
        {'icon': Icons.spa, 'text': 'Fresh gongura leaves from Andhra Pradesh'},
        {'icon': Icons.schedule, 'text': 'Shelf life: 6 months'},
      ],
      'ingredients': 'Gongura leaves, Red chillies, Mustard seeds, Fenugreek seeds, Garlic, Salt, Sesame oil',
      'nutritionInfo': {
        'calories': '45 kcal',
        'protein': '1g',
        'carbs': '5g',
        'fat': '2.5g',
        'sodium': '580mg',
      },
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
        {'weight': '200g', 'price': 149.0},
        {'weight': '400g', 'price': 279.0},
        {'weight': '800g', 'price': 529.0},
      ],
      'highlights': [
        {'icon': Icons.balance, 'text': 'Perfect tangy-spicy balance'},
        {'icon': Icons.verified, 'text': 'No artificial flavors or colors'},
        {'icon': Icons.grain, 'text': 'Freshly ground spices'},
        {'icon': Icons.back_hand, 'text': 'Handcrafted in small batches'},
        {'icon': Icons.schedule, 'text': 'Shelf life: 4 months'},
      ],
      'ingredients': 'Gongura leaves, Green chillies, Tamarind, Cumin seeds, Garlic, Salt, Groundnut oil',
      'nutritionInfo': {
        'calories': '38 kcal',
        'protein': '0.8g',
        'carbs': '4g',
        'fat': '2g',
        'sodium': '520mg',
      },
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
        {'weight': '100g', 'price': 139.0},
        {'weight': '250g', 'price': 319.0},
        {'weight': '500g', 'price': 599.0},
      ],
      'highlights': [
        {'icon': Icons.wb_sunny, 'text': 'Sun-dried gongura leaves'},
        {'icon': Icons.grain, 'text': 'Coarsely ground for best texture'},
        {'icon': Icons.favorite, 'text': 'Rich in iron and vitamins'},
        {'icon': Icons.schedule, 'text': 'Long shelf life - 8 months'},
        {'icon': Icons.auto_awesome, 'text': 'Versatile usage'},
      ],
      'ingredients': 'Dried gongura leaves, Red chillies, Urad dal, Chana dal, Cumin, Garlic, Salt',
      'nutritionInfo': {
        'calories': '52 kcal',
        'protein': '2g',
        'carbs': '6g',
        'fat': '3g',
        'sodium': '480mg',
      },
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
                _buildQuantitySelector(),
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
