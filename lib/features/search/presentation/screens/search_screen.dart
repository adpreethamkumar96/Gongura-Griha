import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';

/// Search Screen
///
/// Allows users to search for products.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // Recent searches with icons - keys for localization
  final List<Map<String, dynamic>> _recentSearchesData = [
    {'key': 'pachadi', 'icon': Icons.eco},
    {'key': 'chutney', 'icon': Icons.restaurant_menu},
    {'key': 'podi', 'icon': Icons.grain},
  ];

  // Popular search suggestions with icons
  List<Map<String, dynamic>> _getPopularSearches(AppLocalizations l10n) => [
    {'name': l10n.traditionalGonguraPachadi, 'icon': Icons.eco, 'slug': 'traditional-gongura-pachadi'},
    {'name': l10n.classicGonguraChutney, 'icon': Icons.restaurant_menu, 'slug': 'classic-gongura-chutney'},
    {'name': l10n.spicyGonguraPodi, 'icon': Icons.grain, 'slug': 'spicy-gongura-podi'},
    {'name': l10n.natural100, 'icon': Icons.nature, 'isTag': true},
    {'name': l10n.freshDelivery, 'icon': Icons.local_shipping, 'isTag': true},
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

  // All products with proper data matching actual products
  List<Map<String, dynamic>> _getAllProducts(AppLocalizations l10n) => [
    {
      'name': l10n.traditionalGonguraPachadi,
      'price': 199.0,
      'image': 'assets/images/GonguraPickle.png',
      'isVeg': true,
      'slug': 'traditional-gongura-pachadi',
      'category': 'pachadi',
      'description': l10n.pachadiDescription,
    },
    {
      'name': l10n.classicGonguraChutney,
      'price': 149.0,
      'image': 'assets/images/GonguraChutney.png',
      'isVeg': true,
      'slug': 'classic-gongura-chutney',
      'category': 'chutney',
      'description': l10n.chutneyDescription,
    },
    {
      'name': l10n.spicyGonguraPodi,
      'price': 129.0,
      'image': 'assets/images/GonguraPowder.png',
      'isVeg': true,
      'slug': 'spicy-gongura-podi',
      'category': 'powder',
      'description': l10n.podiDescription,
    },
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query, AppLocalizations l10n) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Simulate search with localized products
    final allProducts = _getAllProducts(l10n);
    final results = allProducts.where((product) {
      final name = (product['name'] as String).toLowerCase();
      final category = (product['category'] as String).toLowerCase();
      final description = (product['description'] as String).toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) ||
             category.contains(searchQuery) ||
             description.contains(searchQuery);
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
      body: _searchController.text.isEmpty
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
        onChanged: (query) => _performSearch(query, l10n),
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
                    _performSearch('', l10n);
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
    final popularSearches = _getPopularSearches(l10n);

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
                    _performSearch(searchName, l10n);
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
          _buildFeaturedProductsRow(l10n),

          const SizedBox(height: 24),

          // Popular Searches with icons
          Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                l10n.popularSearches,
                style: AppTextStyles.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: popularSearches.map((search) {
              final isTag = search['isTag'] == true;
              return ActionChip(
                label: Text(
                  search['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: isTag ? AppColors.textSecondary : AppColors.primary,
                  ),
                ),
                onPressed: () {
                  if (!isTag && search['slug'] != null) {
                    context.push(AppRoutes.getProductDetailRoute(search['slug'] as String));
                  } else {
                    _searchController.text = search['name'] as String;
                    _performSearch(search['name'] as String, l10n);
                  }
                },
                avatar: Icon(
                  search['icon'] as IconData,
                  size: 16,
                  color: isTag ? AppColors.textSecondary : AppColors.primary,
                ),
                backgroundColor: isTag
                    ? AppColors.backgroundSecondary
                    : AppColors.primary.withAlpha(26),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

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

  Widget _buildFeaturedProductsRow(AppLocalizations l10n) {
    final products = _getAllProducts(l10n);

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              context.push(AppRoutes.getProductDetailRoute(product['slug'] as String));
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
                      child: Image.asset(
                        product['image'] as String,
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
                            (product['name'] as String).split(' ').take(2).join(' '),
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            Formatters.formatCurrency(product['price'] as double),
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
        'description': l10n.pachadiDescription.split('.').first,
        'slug': 'pachadi',
      },
      {
        'name': l10n.chutney,
        'icon': Icons.restaurant_menu,
        'color': AppColors.accent,
        'description': l10n.chutneyDescription.split('.').first,
        'slug': 'chutney',
      },
      {
        'name': l10n.powder,
        'icon': Icons.grain,
        'color': AppColors.info,
        'description': l10n.podiDescription.split('.').first,
        'slug': 'powder',
      },
      {
        'name': l10n.allProducts,
        'icon': Icons.grid_view,
        'color': AppColors.veg,
        'description': '',
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
              context.push(
                AppRoutes.getProductDetailRoute(product['slug'] as String),
              );
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
                      child: Image.asset(
                        product['image'] as String,
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
                                  color: (product['isVeg'] as bool)
                                      ? AppColors.veg
                                      : AppColors.nonVeg,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.eco,
                                size: 10,
                                color: (product['isVeg'] as bool)
                                    ? AppColors.veg
                                    : AppColors.nonVeg,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                product['name'] as String,
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
                            (product['category'] as String).toUpperCase(),
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
                          Formatters.formatCurrency(product['price'] as double),
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
