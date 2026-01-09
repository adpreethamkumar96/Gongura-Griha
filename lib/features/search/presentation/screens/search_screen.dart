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

  // Mock recent searches
  final List<String> _recentSearches = [
    'Gongura Pickle',
    'Mutton Pickle',
    'Spicy',
    'Prawns',
  ];

  // Mock popular searches
  final List<String> _popularSearches = [
    'Classic Gongura',
    'Chicken Pickle',
    'Veg Pickles',
    'Non-Veg Pickles',
    'Gift Packs',
    'Combo Offers',
  ];

  // Mock products
  final List<Map<String, dynamic>> _allProducts = [
    {
      'name': 'Classic Gongura Pickle',
      'price': 299.0,
      'image': 'https://via.placeholder.com/100x100/4CAF50/FFFFFF?text=G',
      'isVeg': true,
      'slug': 'classic-gongura-pickle',
    },
    {
      'name': 'Spicy Gongura Mutton',
      'price': 549.0,
      'image': 'https://via.placeholder.com/100x100/FF5722/FFFFFF?text=M',
      'isVeg': false,
      'slug': 'spicy-gongura-mutton',
    },
    {
      'name': 'Gongura Prawns Pickle',
      'price': 599.0,
      'image': 'https://via.placeholder.com/100x100/2196F3/FFFFFF?text=P',
      'isVeg': false,
      'slug': 'gongura-prawns-pickle',
    },
    {
      'name': 'Mild Gongura Pickle',
      'price': 249.0,
      'image': 'https://via.placeholder.com/100x100/8BC34A/FFFFFF?text=G',
      'isVeg': true,
      'slug': 'mild-gongura-pickle',
    },
    {
      'name': 'Gongura Chicken Pickle',
      'price': 499.0,
      'image': 'https://via.placeholder.com/100x100/FF9800/FFFFFF?text=C',
      'isVeg': false,
      'slug': 'gongura-chicken-pickle',
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

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Simulate search
    final results = _allProducts.where((product) {
      final name = (product['name'] as String).toLowerCase();
      return name.contains(query.toLowerCase());
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentSearches,
                  style: AppTextStyles.titleSmall,
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _recentSearches.clear());
                  },
                  child: Text(
                    l10n.clearAll,
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                  child: Chip(
                    label: Text(search),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() => _recentSearches.remove(search));
                    },
                    backgroundColor: AppColors.surface,
                    side: BorderSide(color: AppColors.divider),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Searches
          Text(
            l10n.popularSearches,
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) {
              return ActionChip(
                label: Text(search),
                onPressed: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
                avatar: Icon(
                  Icons.trending_up,
                  size: 16,
                  color: AppColors.primary,
                ),
                backgroundColor: AppColors.primary.withAlpha(26),
                side: BorderSide.none,
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Categories
          Text(
            l10n.browseCategories,
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 12),
          _buildCategoryGrid(l10n),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(AppLocalizations l10n) {
    final categories = [
      {'name': l10n.vegPickles, 'icon': Icons.eco, 'color': AppColors.veg},
      {
        'name': l10n.nonVegPickles,
        'icon': Icons.restaurant,
        'color': AppColors.nonVeg
      },
      {'name': l10n.chutneys, 'icon': Icons.soup_kitchen, 'color': AppColors.info},
      {
        'name': l10n.giftPacks,
        'icon': Icons.card_giftcard,
        'color': AppColors.accent
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            context.push(
              '${AppRoutes.productList}?category=${category['name']}',
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: (category['color'] as Color).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (category['color'] as Color).withAlpha(51),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category['name'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: category['color'] as Color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product['image'] as String,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: AppColors.backgroundSecondary,
                child: Icon(
                  Icons.image,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (product['isVeg'] as bool)
                      ? AppColors.veg
                      : AppColors.nonVeg,
                ),
              ),
              Expanded(
                child: Text(
                  product['name'] as String,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
          subtitle: Text(
            Formatters.formatCurrency(product['price'] as double),
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
          onTap: () {
            context.push(
              AppRoutes.getProductDetailRoute(product['slug'] as String),
            );
          },
        );
      },
    );
  }
}
