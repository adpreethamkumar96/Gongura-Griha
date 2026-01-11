import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/models/product_inventory_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';

/// Search Screen
///
/// Allows users to search for products from Firestore inventory.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<ProductInventoryModel> _allProducts = [];
  List<ProductInventoryModel> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  StreamSubscription? _inventorySubscription;

  // Recent searches with icons - keys for localization
  final List<Map<String, dynamic>> _recentSearchesData = [
    {'key': 'pachadi', 'icon': Icons.eco},
    {'key': 'chutney', 'icon': Icons.restaurant_menu},
    {'key': 'podi', 'icon': Icons.grain},
  ];

  // Get localized recent search names
  String _getRecentSearchName(String key, AppLocalizations l10n) {
    switch (key) {
      case 'pachadi':
        return l10n.pachadi;
      case 'chutney':
        return l10n.chutney;
      case 'podi':
        return l10n.powder;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
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

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Track search in analytics (only for meaningful queries)
    if (query.length >= 3) {
      analyticsService.logSearch(searchTerm: query);
    }

    final results = _allProducts.where((product) {
      final name = product.productName.toLowerCase();
      final category = product.category.toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || category.contains(searchQuery);
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildSearchBar(l10n),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchController.text.isEmpty
              ? _buildSuggestions(l10n)
              : _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? _buildNoResults(l10n)
                      : _buildSearchResults(),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(right: 16),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: _performSearch,
        decoration: InputDecoration(
          hintText: l10n.searchPickles,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textTertiary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.backgroundSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(AppLocalizations l10n) {
    final featuredProducts = _allProducts.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches with icons
          if (_recentSearchesData.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.recentSearches,
                      style: AppTextStyles.titleSmall,
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _recentSearchesData.clear());
                  },
                  icon: Icon(Icons.clear_all, size: 16, color: AppColors.primary),
                  label: Text(
                    l10n.clearAll,
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _recentSearchesData.map((searchData) {
                final searchName = _getRecentSearchName(searchData['key'] as String, l10n);
                return GestureDetector(
                  onTap: () {
                    _searchController.text = searchName;
                    _performSearch(searchName);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          searchData['icon'] as IconData,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          searchName,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() => _recentSearchesData.remove(searchData));
                          },
                          child: Icon(Icons.close, size: 16, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Quick Actions - Featured Products
          if (featuredProducts.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.local_fire_department, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  l10n.featuredProducts,
                  style: AppTextStyles.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFeaturedProductsRow(featuredProducts),
            const SizedBox(height: 24),
          ],

          // Categories
          Row(
            children: [
              Icon(Icons.category, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.browseCategories,
                style: AppTextStyles.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCategoryGrid(l10n),

          const SizedBox(height: 24),

          // Quick Filters
          Row(
            children: [
              Icon(Icons.filter_list, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                l10n.filters,
                style: AppTextStyles.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickFilters(l10n),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductsRow(List<ProductInventoryModel> products) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          final isNetworkImage = product.productImage.startsWith('http');

          return GestureDetector(
            onTap: () {
              context.push(AppRoutes.getProductDetailRoute(product.productSlug));
            },
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      color: AppColors.primary.withAlpha(20),
                      child: isNetworkImage
                          ? Image.network(
                              product.productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.eco,
                                size: 32,
                                color: AppColors.primary.withAlpha(100),
                              ),
                            )
                          : Image.asset(
                              product.productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.eco,
                                size: 32,
                                color: AppColors.primary.withAlpha(100),
                              ),
                            ),
                    ),
                  ),
                  // Product Name & Price
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.productName.split(' ').take(2).join(' '),
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            Formatters.formatCurrency(product.basePrice),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickFilters(AppLocalizations l10n) {
    final filters = [
      {'name': l10n.vegOnly, 'icon': Icons.eco, 'color': AppColors.veg},
      {'name': l10n.mostPopular, 'icon': Icons.star, 'color': AppColors.accent},
      {'name': l10n.priceLowToHigh, 'icon': Icons.arrow_upward, 'color': AppColors.info},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: filters.map((filter) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: (filter['color'] as Color).withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (filter['color'] as Color).withAlpha(50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filter['icon'] as IconData,
                size: 16,
                color: filter['color'] as Color,
              ),
              const SizedBox(width: 6),
              Text(
                filter['name'] as String,
                style: AppTextStyles.bodySmall.copyWith(
                  color: filter['color'] as Color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryGrid(AppLocalizations l10n) {
    final categories = [
      {
        'name': l10n.pachadi,
        'icon': Icons.eco,
        'color': AppColors.primary,
        'slug': 'Pachadi',
      },
      {
        'name': l10n.chutney,
        'icon': Icons.restaurant_menu,
        'color': AppColors.accent,
        'slug': 'Chutney',
      },
      {
        'name': l10n.powder,
        'icon': Icons.grain,
        'color': AppColors.info,
        'slug': 'Powder',
      },
      {
        'name': l10n.allProducts,
        'icon': Icons.grid_view,
        'color': AppColors.veg,
        'slug': 'all',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final color = category['color'] as Color;
        return GestureDetector(
          onTap: () {
            final slug = category['slug'] as String;
            if (slug == 'all') {
              context.push(AppRoutes.productList);
            } else {
              context.push('${AppRoutes.productList}?category=$slug');
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withAlpha(30),
                  color.withAlpha(15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(40)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with background
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                // Category name
                Text(
                  category['name'] as String,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                // Arrow indicator
                Row(
                  children: [
                    Text(
                      l10n.viewAll,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: color.withAlpha(180),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: color.withAlpha(180),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResults(AppLocalizations l10n) {
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
            l10n.noResults,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tryDifferentKeywords,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        final isNetworkImage = product.productImage.startsWith('http');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              context.push(AppRoutes.getProductDetailRoute(product.productSlug));
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: AppColors.primary.withAlpha(20),
                      child: isNetworkImage
                          ? Image.network(
                              product.productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.eco,
                                size: 32,
                                color: AppColors.primary.withAlpha(100),
                              ),
                            )
                          : Image.asset(
                              product.productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.eco,
                                size: 32,
                                color: AppColors.primary.withAlpha(100),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Veg indicator + Name
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: product.isVeg
                                      ? AppColors.veg
                                      : AppColors.nonVeg,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.eco,
                                size: 10,
                                color: product.isVeg
                                    ? AppColors.veg
                                    : AppColors.nonVeg,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                product.productName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Price
                        Text(
                          Formatters.formatCurrency(product.basePrice),
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
