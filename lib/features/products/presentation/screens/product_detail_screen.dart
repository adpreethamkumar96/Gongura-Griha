import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';

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

  // Separate quantity for each size: [S, M, L]
  final List<int> _quantities = [0, 0, 0];

  // Get current size's quantity
  int get _quantity => _quantities[_selectedSizeIndex];

  // Max quantity limits based on size index
  // Size 0 (S): max 2, Size 1 (M): max 4, Size 2 (L): max 5
  int get _maxQuantity {
    switch (_selectedSizeIndex) {
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

  // Product data mapped by slug with localized strings
  Map<String, Map<String, dynamic>> _getProductsData(AppLocalizations l10n) => {
    'traditional-gongura-pachadi': {
      'name': l10n.traditionalGonguraPachadi,
      'description': l10n.pachadiDescription,
      'price': 199.0,
      'images': [
        'assets/images/GonguraPickle.png',
      ],
      'isAsset': true,
      'isVeg': true,
      'inStock': true,
      'sizes': [
        {
          'weight': '250g',
          'price': 199.0,
          'icon': Icons.eco,
          'sizeLabel': 'S',
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': l10n.calories, 'value': '112 kcal'},
            {'icon': Icons.fitness_center, 'label': l10n.protein, 'value': '2.5g'},
            {'icon': Icons.bakery_dining, 'label': l10n.carbs, 'value': '12.5g'},
            {'icon': Icons.opacity, 'label': l10n.fat, 'value': '6.3g'},
            {'icon': Icons.water_drop, 'label': l10n.sodium, 'value': '1450mg'},
          ],
        },
        {
          'weight': '500g',
          'price': 379.0,
          'icon': Icons.nature,
          'sizeLabel': 'M',
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': l10n.calories, 'value': '225 kcal'},
            {'icon': Icons.fitness_center, 'label': l10n.protein, 'value': '5g'},
            {'icon': Icons.bakery_dining, 'label': l10n.carbs, 'value': '25g'},
            {'icon': Icons.opacity, 'label': l10n.fat, 'value': '12.5g'},
            {'icon': Icons.water_drop, 'label': l10n.sodium, 'value': '2900mg'},
          ],
        },
        {
          'weight': '1kg',
          'price': 699.0,
          'icon': Icons.forest,
          'sizeLabel': 'L',
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': l10n.calories, 'value': '450 kcal'},
            {'icon': Icons.fitness_center, 'label': l10n.protein, 'value': '10g'},
            {'icon': Icons.bakery_dining, 'label': l10n.carbs, 'value': '50g'},
            {'icon': Icons.opacity, 'label': l10n.fat, 'value': '25g'},
            {'icon': Icons.water_drop, 'label': l10n.sodium, 'value': '5800mg'},
          ],
        },
      ],
      'highlights': [
        {'icon': Icons.eco, 'text': l10n.highlight100Natural},
        {'icon': Icons.verified, 'text': l10n.highlightNoPreservatives},
        {'icon': Icons.menu_book, 'text': l10n.highlightTraditionalRecipe},
        {'icon': Icons.spa, 'text': l10n.highlightFreshGongura},
        {'icon': Icons.schedule, 'text': l10n.highlightShelfLife6Months},
      ],
      'ingredients': [
        {'icon': Icons.eco, 'name': l10n.gonguraLeaves},
        {'icon': Icons.whatshot, 'name': l10n.redChillies},
        {'icon': Icons.grain, 'name': l10n.mustardSeeds},
        {'icon': Icons.grass, 'name': l10n.fenugreekSeeds},
        {'icon': Icons.restaurant, 'name': l10n.garlic},
        {'icon': Icons.water_drop, 'name': l10n.salt},
        {'icon': Icons.opacity, 'name': l10n.sesameOil},
      ],
    },
    'classic-gongura-chutney': {
      'name': l10n.classicGonguraChutney,
      'description': l10n.chutneyDescription,
      'price': 149.0,
      'images': [
        'assets/images/GonguraChutney.png',
      ],
      'isAsset': true,
      'isVeg': true,
      'inStock': true,
      'sizes': [
        {
          'weight': '200g',
          'price': 149.0,
          'icon': Icons.eco,
          'sizeLabel': 'S',
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': l10n.calories, 'value': '76 kcal'},
            {'icon': Icons.fitness_center, 'label': l10n.protein, 'value': '1.6g'},
            {'icon': Icons.bakery_dining, 'label': l10n.carbs, 'value': '8g'},
            {'icon': Icons.opacity, 'label': l10n.fat, 'value': '4g'},
            {'icon': Icons.water_drop, 'label': l10n.sodium, 'value': '1040mg'},
          ],
        },
        {
          'weight': '400g',
          'price': 279.0,
          'icon': Icons.nature,
          'sizeLabel': 'M',
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': l10n.calories, 'value': '152 kcal'},
            {'icon': Icons.fitness_center, 'label': l10n.protein, 'value': '3.2g'},
            {'icon': Icons.bakery_dining, 'label': l10n.carbs, 'value': '16g'},
            {'icon': Icons.opacity, 'label': l10n.fat, 'value': '8g'},
            {'icon': Icons.water_drop, 'label': l10n.sodium, 'value': '2080mg'},
          ],
        },
        {
          'weight': '800g',
          'price': 529.0,
          'icon': Icons.forest,
          'sizeLabel': 'L',
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': l10n.calories, 'value': '304 kcal'},
            {'icon': Icons.fitness_center, 'label': l10n.protein, 'value': '6.4g'},
            {'icon': Icons.bakery_dining, 'label': l10n.carbs, 'value': '32g'},
            {'icon': Icons.opacity, 'label': l10n.fat, 'value': '16g'},
            {'icon': Icons.water_drop, 'label': l10n.sodium, 'value': '4160mg'},
          ],
        },
      ],
      'highlights': [
        {'icon': Icons.balance, 'text': l10n.highlightTangySpicy},
        {'icon': Icons.verified, 'text': l10n.highlightNoArtificial},
        {'icon': Icons.grain, 'text': l10n.highlightFreshSpices},
        {'icon': Icons.back_hand, 'text': l10n.highlightHandcrafted},
        {'icon': Icons.schedule, 'text': l10n.highlightShelfLife4Months},
      ],
      'ingredients': [
        {'icon': Icons.eco, 'name': l10n.gonguraLeaves},
        {'icon': Icons.local_fire_department, 'name': l10n.greenChillies},
        {'icon': Icons.nature, 'name': l10n.tamarind},
        {'icon': Icons.grain, 'name': l10n.cuminSeeds},
        {'icon': Icons.restaurant, 'name': l10n.garlic},
        {'icon': Icons.water_drop, 'name': l10n.salt},
        {'icon': Icons.opacity, 'name': l10n.groundnutOil},
      ],
    },
    'spicy-gongura-podi': {
      'name': l10n.spicyGonguraPodi,
      'description': l10n.podiDescription,
      'price': 139.0,
      'images': [
        'assets/images/GonguraPowder.png',
      ],
      'isAsset': true,
      'isVeg': true,
      'inStock': true,
      'sizes': [
        {
          'weight': '100g',
          'price': 139.0,
          'icon': Icons.eco,
          'sizeLabel': 'S',
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': l10n.calories, 'value': '52 kcal'},
            {'icon': Icons.fitness_center, 'label': l10n.protein, 'value': '2g'},
            {'icon': Icons.bakery_dining, 'label': l10n.carbs, 'value': '6g'},
            {'icon': Icons.opacity, 'label': l10n.fat, 'value': '3g'},
            {'icon': Icons.water_drop, 'label': l10n.sodium, 'value': '480mg'},
          ],
        },
        {
          'weight': '250g',
          'price': 319.0,
          'icon': Icons.nature,
          'sizeLabel': 'M',
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': l10n.calories, 'value': '130 kcal'},
            {'icon': Icons.fitness_center, 'label': l10n.protein, 'value': '5g'},
            {'icon': Icons.bakery_dining, 'label': l10n.carbs, 'value': '15g'},
            {'icon': Icons.opacity, 'label': l10n.fat, 'value': '7.5g'},
            {'icon': Icons.water_drop, 'label': l10n.sodium, 'value': '1200mg'},
          ],
        },
        {
          'weight': '500g',
          'price': 599.0,
          'icon': Icons.forest,
          'sizeLabel': 'L',
          'nutritionInfo': [
            {'icon': Icons.local_fire_department, 'label': l10n.calories, 'value': '260 kcal'},
            {'icon': Icons.fitness_center, 'label': l10n.protein, 'value': '10g'},
            {'icon': Icons.bakery_dining, 'label': l10n.carbs, 'value': '30g'},
            {'icon': Icons.opacity, 'label': l10n.fat, 'value': '15g'},
            {'icon': Icons.water_drop, 'label': l10n.sodium, 'value': '2400mg'},
          ],
        },
      ],
      'highlights': [
        {'icon': Icons.wb_sunny, 'text': l10n.highlightSunDried},
        {'icon': Icons.grain, 'text': l10n.highlightCoarseGround},
        {'icon': Icons.favorite, 'text': l10n.highlightRichInIron},
        {'icon': Icons.schedule, 'text': l10n.highlightShelfLife8Months},
        {'icon': Icons.auto_awesome, 'text': l10n.highlightVersatile},
      ],
      'ingredients': [
        {'icon': Icons.eco, 'name': l10n.driedGonguraLeaves},
        {'icon': Icons.whatshot, 'name': l10n.redChillies},
        {'icon': Icons.egg_alt, 'name': l10n.uradDal},
        {'icon': Icons.circle, 'name': l10n.chanaDal},
        {'icon': Icons.grain, 'name': l10n.cumin},
        {'icon': Icons.restaurant, 'name': l10n.garlic},
        {'icon': Icons.water_drop, 'name': l10n.salt},
      ],
    },
  };

  Map<String, dynamic> _getProduct(AppLocalizations l10n) {
    final productsData = _getProductsData(l10n);
    return productsData[widget.slug] ?? productsData['traditional-gongura-pachadi']!;
  }

  int _currentImageIndex = 0;

  double _getCurrentPrice(AppLocalizations l10n) {
    final product = _getProduct(l10n);
    final sizes = product['sizes'] as List;
    return sizes[_selectedSizeIndex]['price'] as double;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final product = _getProduct(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          _buildSliverAppBar(product),

          // Product Details
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(product, l10n),
                const Divider(height: 1),
                _buildSizeSelector(product, l10n),
                const Divider(height: 1),
                _buildHighlights(product, l10n),
                const Divider(height: 1),
                _buildIngredients(product, l10n),
                const Divider(height: 1),
                _buildNutritionInfo(product, l10n),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(l10n),
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic> product) {
    final images = product['images'] as List;

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
                final isAsset = product['isAsset'] as bool? ?? false;
                return Container(
                  color: AppColors.backgroundSecondary,
                  child: isAsset
                      ? Image.asset(
                          images[index] as String,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                        )
                      : Image.network(
                          images[index] as String,
                          width: double.infinity,
                          height: double.infinity,
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
                    color: product['isVeg'] as bool
                        ? AppColors.veg
                        : AppColors.nonVeg,
                  ),
                ),
                child: Icon(
                  Icons.circle,
                  size: 12,
                  color: product['isVeg'] as bool
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

  Widget _buildProductInfo(Map<String, dynamic> product, AppLocalizations l10n) {
    final currentPrice = _getCurrentPrice(l10n);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            product['name'] as String,
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 12),

          // Price
          Text(
            Formatters.formatCurrency(currentPrice),
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            product['description'] as String,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelector(Map<String, dynamic> product, AppLocalizations l10n) {
    final sizes = product['sizes'] as List;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.selectSize, style: AppTextStyles.titleSmall),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              sizes.length,
              (index) {
                final size = sizes[index] as Map<String, dynamic>;
                final isSelected = index == _selectedSizeIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedSizeIndex = index);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withAlpha(40)
                              : AppColors.primary.withAlpha(20),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withAlpha(50),
                            width: isSelected ? 3 : 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            size['icon'] as IconData,
                            size: isSelected ? 32 : 28,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withAlpha(180),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        size['weight'] as String,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.formatCurrency(size['price'] as double),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights(Map<String, dynamic> product, AppLocalizations l10n) {
    final highlights = product['highlights'] as List;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.highlights, style: AppTextStyles.titleSmall),
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

  Widget _buildIngredients(Map<String, dynamic> product, AppLocalizations l10n) {
    final ingredients = product['ingredients'] as List;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.ingredients, style: AppTextStyles.titleSmall),
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

  Widget _buildNutritionInfo(Map<String, dynamic> product, AppLocalizations l10n) {
    final sizes = product['sizes'] as List;
    final selectedSize = sizes[_selectedSizeIndex] as Map<String, dynamic>;
    final nutrition = selectedSize['nutritionInfo'] as List;
    final weight = selectedSize['weight'] as String;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.nutritionInfoPer(weight), style: AppTextStyles.titleSmall),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: nutrition.map((item) {
              final nutritionData = item as Map<String, dynamic>;
              return Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
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
                        nutritionData['icon'] as IconData,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nutritionData['value'] as String,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nutritionData['label'] as String,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    final currentPrice = _getCurrentPrice(l10n);
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
                    l10n.price,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(currentPrice),
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _quantity == 0
                ? _buildAddButton()
                : _buildQuantitySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _handleAddFirstItem,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF4A7C59),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco,
              size: 22,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Icon(
              Icons.add,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4A7C59),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button
          GestureDetector(
            onTap: _handleDecrement,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.remove,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),

          // Leaves display
          Container(
            constraints: const BoxConstraints(minWidth: 50),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _quantity,
                (index) => Padding(
                  padding: EdgeInsets.only(left: index > 0 ? 2 : 0),
                  child: const Icon(
                    Icons.eco,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Plus button
          GestureDetector(
            onTap: _quantity < _maxQuantity ? _handleIncrement : null,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _quantity < _maxQuantity
                    ? Colors.white.withAlpha(51)
                    : Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.add,
                size: 20,
                color: _quantity < _maxQuantity
                    ? Colors.white
                    : Colors.white.withAlpha(100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddFirstItem() {
    setState(() => _quantities[_selectedSizeIndex] = 1);
  }

  void _handleIncrement() {
    if (_quantity < _maxQuantity) {
      setState(() => _quantities[_selectedSizeIndex]++);
    }
  }

  void _handleDecrement() {
    if (_quantity > 0) {
      setState(() => _quantities[_selectedSizeIndex]--);
    }
  }
}
