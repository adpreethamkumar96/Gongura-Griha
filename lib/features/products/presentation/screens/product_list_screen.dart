import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/product_card.dart';

/// Product List Screen
///
/// Displays a grid of products with filtering and sorting options.
class ProductListScreen extends StatefulWidget {
  final String? category;
  final String? searchQuery;

  const ProductListScreen({
    super.key,
    this.category,
    this.searchQuery,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _selectedSort = 'popular';
  bool _showVegOnly = false;
  RangeValues _priceRange = const RangeValues(0, 1000);

  // Category-specific products data (all veg)
  final Map<String, List<Map<String, dynamic>>> _categoryProducts = {
    'Pachadi': [
      {
        'name': 'Traditional Gongura Pachadi',
        'price': 199.0,
        'originalPrice': 249.0,
        'image': 'https://images.unsplash.com/photo-1601648764658-cf37e8c89b70?w=400',
        'isVeg': true,
        'rating': 4.7,
        'reviews': 312,
        'slug': 'traditional-gongura-pachadi',
      },
      {
        'name': 'Spicy Gongura Pachadi',
        'price': 219.0,
        'originalPrice': 269.0,
        'image': 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',
        'isVeg': true,
        'rating': 4.5,
        'reviews': 198,
        'slug': 'spicy-gongura-pachadi',
      },
      {
        'name': 'Mild Gongura Pachadi',
        'price': 189.0,
        'originalPrice': null,
        'image': 'https://images.unsplash.com/photo-1601648764658-cf37e8c89b70?w=400',
        'isVeg': true,
        'rating': 4.4,
        'reviews': 156,
        'slug': 'mild-gongura-pachadi',
      },
      {
        'name': 'Garlic Gongura Pachadi',
        'price': 229.0,
        'originalPrice': 279.0,
        'image': 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',
        'isVeg': true,
        'rating': 4.8,
        'reviews': 223,
        'slug': 'garlic-gongura-pachadi',
      },
    ],
    'Chutney': [
      {
        'name': 'Classic Gongura Chutney',
        'price': 149.0,
        'originalPrice': 189.0,
        'image': 'https://images.unsplash.com/photo-1546470427-227c7aa45214?w=400',
        'isVeg': true,
        'rating': 4.6,
        'reviews': 287,
        'slug': 'classic-gongura-chutney',
      },
      {
        'name': 'Tangy Gongura Chutney',
        'price': 159.0,
        'originalPrice': 199.0,
        'image': 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',
        'isVeg': true,
        'rating': 4.5,
        'reviews': 176,
        'slug': 'tangy-gongura-chutney',
      },
      {
        'name': 'Sweet Gongura Chutney',
        'price': 169.0,
        'originalPrice': null,
        'image': 'https://images.unsplash.com/photo-1546470427-227c7aa45214?w=400',
        'isVeg': true,
        'rating': 4.3,
        'reviews': 134,
        'slug': 'sweet-gongura-chutney',
      },
    ],
    'Powder': [
      {
        'name': 'Gongura Podi',
        'price': 129.0,
        'originalPrice': 159.0,
        'image': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400',
        'isVeg': true,
        'rating': 4.7,
        'reviews': 345,
        'slug': 'gongura-podi',
      },
      {
        'name': 'Spicy Gongura Powder',
        'price': 139.0,
        'originalPrice': 169.0,
        'image': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400',
        'isVeg': true,
        'rating': 4.6,
        'reviews': 234,
        'slug': 'spicy-gongura-powder',
      },
      {
        'name': 'Mild Gongura Powder',
        'price': 119.0,
        'originalPrice': null,
        'image': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400',
        'isVeg': true,
        'rating': 4.4,
        'reviews': 189,
        'slug': 'mild-gongura-powder',
      },
      {
        'name': 'Premium Gongura Powder',
        'price': 179.0,
        'originalPrice': 219.0,
        'image': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400',
        'isVeg': true,
        'rating': 4.9,
        'reviews': 156,
        'slug': 'premium-gongura-powder',
      },
    ],
  };

  List<Map<String, dynamic>> get _products {
    // If category is specified, return category-specific products
    if (widget.category != null && _categoryProducts.containsKey(widget.category)) {
      return _categoryProducts[widget.category]!;
    }
    // Otherwise return all products
    return _categoryProducts.values.expand((list) => list).toList();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    var filtered = _products.where((p) {
      if (_showVegOnly && !(p['isVeg'] as bool)) return false;
      final price = p['price'] as double;
      if (price < _priceRange.start || price > _priceRange.end) return false;
      return true;
    }).toList();

    // Sort
    switch (_selectedSort) {
      case 'price_low':
        filtered.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      case 'price_high':
        filtered.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
        break;
      case 'rating':
        filtered.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case 'popular':
      default:
        filtered.sort((a, b) => (b['reviews'] as int).compareTo(a['reviews'] as int));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.category ?? 'All Products'),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort and Filter Bar
          _buildSortBar(),

          // Products Grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCard(
                        name: product['name'] as String,
                        price: product['price'] as double,
                        originalPrice: product['originalPrice'] as double?,
                        imageUrl: product['image'] as String,
                        isVeg: product['isVeg'] as bool,
                        rating: product['rating'] as double,
                        onTap: () {
                          context.push(
                            AppRoutes.getProductDetailRoute(product['slug'] as String),
                          );
                        },
                        onAddToCart: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product['name']} added to cart'),
                              action: SnackBarAction(
                                label: 'VIEW CART',
                                onPressed: () => context.push(AppRoutes.cart),
                              ),
                            ),
                          );
                        },
                        onWishlistToggle: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product['name']} added to wishlist'),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          // Results count
          Text(
            '${_filteredProducts.length} products',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const Spacer(),

          // Veg filter icon
          GestureDetector(
            onTap: () {
              setState(() => _showVegOnly = !_showVegOnly);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _showVegOnly ? const Color(0xFF4A7C59).withAlpha(30) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF4A7C59),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7C59),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Sort dropdown
          PopupMenuButton<String>(
            initialValue: _selectedSort,
            onSelected: (value) {
              setState(() => _selectedSort = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'popular', child: Text('Most Popular')),
              const PopupMenuItem(value: 'rating', child: Text('Highest Rated')),
              const PopupMenuItem(value: 'price_low', child: Text('Price: Low to High')),
              const PopupMenuItem(value: 'price_high', child: Text('Price: High to Low')),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sort',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _showVegOnly = false;
                _priceRange = const RangeValues(0, 1000);
              });
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters', style: AppTextStyles.headlineSmall),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _showVegOnly = false;
                        _priceRange = const RangeValues(0, 1000);
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Dietary Preference
              Text('Dietary Preference', style: AppTextStyles.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: !_showVegOnly,
                    onSelected: (_) {
                      setModalState(() => _showVegOnly = false);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Veg Only'),
                    selected: _showVegOnly,
                    onSelected: (_) {
                      setModalState(() => _showVegOnly = true);
                    },
                    selectedColor: AppColors.veg.withAlpha(51),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Price Range
              Text('Price Range', style: AppTextStyles.titleSmall),
              const SizedBox(height: 12),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000,
                divisions: 20,
                labels: RangeLabels(
                  '\u20B9${_priceRange.start.round()}',
                  '\u20B9${_priceRange.end.round()}',
                ),
                onChanged: (values) {
                  setModalState(() => _priceRange = values);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\u20B9${_priceRange.start.round()}'),
                  Text('\u20B9${_priceRange.end.round()}'),
                ],
              ),
              const SizedBox(height: 24),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
