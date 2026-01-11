import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/models/product_inventory_model.dart';
import '../../../../core/data/models/wishlist_item_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cards/product_card.dart';

/// Product List Screen
///
/// Displays a grid of products from Firestore with filtering and sorting options.
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

  List<ProductInventoryModel> _allProducts = [];
  bool _isLoading = true;
  StreamSubscription? _inventorySubscription;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _inventorySubscription?.cancel();
    super.dispose();
  }

  void _loadProducts() {
    // First, check if we already have cached inventory data
    final cachedProducts = inventoryService.cachedInventory;
    if (cachedProducts.isNotEmpty) {
      _allProducts = cachedProducts.values.where((p) => p.isActive).toList();
      _isLoading = false;
    }

    // Listen to inventory stream for real-time updates
    _inventorySubscription = inventoryService.inventoryStream.listen(
      (productsMap) {
        if (mounted) {
          setState(() {
            _allProducts = productsMap.values.where((p) => p.isActive).toList();
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

  List<ProductInventoryModel> _getFilteredProducts() {
    var filtered = _allProducts.where((p) {
      // Category filter
      if (widget.category != null &&
          p.category.toLowerCase() != widget.category!.toLowerCase()) {
        return false;
      }
      // Veg filter
      if (_showVegOnly && !p.isVeg) return false;
      // Price range filter
      if (p.basePrice < _priceRange.start || p.basePrice > _priceRange.end) {
        return false;
      }
      // Search query filter
      if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
        final query = widget.searchQuery!.toLowerCase();
        if (!p.productName.toLowerCase().contains(query) &&
            !p.category.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Sort
    switch (_selectedSort) {
      case 'price_low':
        filtered.sort((a, b) => a.basePrice.compareTo(b.basePrice));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.basePrice.compareTo(a.basePrice));
        break;
      case 'name':
        filtered.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case 'popular':
      default:
        // Keep original order (could be sorted by popularity in backend)
        break;
    }

    return filtered;
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
    setState(() {}); // Refresh to show updated wishlist state
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.category ?? l10n.allProducts),
        actions: [
          IconButton(
            onPressed: () => _showFilterBottomSheet(l10n),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Sort and Filter Bar
                _buildSortBar(l10n, filteredProducts.length),

                // Products Grid
                Expanded(
                  child: filteredProducts.isEmpty
                      ? _buildEmptyState(l10n)
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final isWishlisted = wishlistRepository.isInWishlist(product.productSlug);
                            final isNetworkImage = product.productImage.startsWith('http');

                            return ProductCard(
                              name: product.productName,
                              price: product.basePrice,
                              imageUrl: product.productImage,
                              isVeg: product.isVeg,
                              isAsset: !isNetworkImage,
                              isWishlisted: isWishlisted,
                              isOutOfStock: !product.isInStock,
                              onTap: () {
                                context.push(
                                  AppRoutes.getProductDetailRoute(product.productSlug),
                                );
                              },
                              onAddToCart: () {
                                context.push(
                                  AppRoutes.getProductDetailRoute(product.productSlug),
                                );
                              },
                              onWishlistToggle: () => _toggleWishlist(product),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSortBar(AppLocalizations l10n, int productCount) {
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
            l10n.productsCount(productCount),
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
              PopupMenuItem(value: 'popular', child: Text(l10n.mostPopular)),
              PopupMenuItem(value: 'name', child: Text(l10n.nameAToZ)),
              PopupMenuItem(value: 'price_low', child: Text(l10n.priceLowToHigh)),
              PopupMenuItem(value: 'price_high', child: Text(l10n.priceHighToLow)),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.sort,
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

  Widget _buildEmptyState(AppLocalizations l10n) {
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
            l10n.noProductsFound,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tryAdjustingFilters,
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
            child: Text(l10n.clearFilters),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(AppLocalizations l10n) {
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
                  Text(l10n.filters, style: AppTextStyles.headlineSmall),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _showVegOnly = false;
                        _priceRange = const RangeValues(0, 1000);
                      });
                    },
                    child: Text(l10n.reset),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Dietary Preference
              Text(l10n.dietaryPreference, style: AppTextStyles.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.all),
                    selected: !_showVegOnly,
                    onSelected: (_) {
                      setModalState(() => _showVegOnly = false);
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.vegOnly),
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
              Text(l10n.priceRange, style: AppTextStyles.titleSmall),
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
                  child: Text(l10n.applyFilters),
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
