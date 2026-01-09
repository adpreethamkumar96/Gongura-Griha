import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// Profile Screen
///
/// Displays user profile information and settings options.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Mock user data
    const user = {
      'name': 'Ramesh Kumar',
      'phone': '+91 98765 43210',
      'email': 'ramesh.kumar@email.com',
      'avatar': null,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: Text(
                          user['name']!.toString().substring(0, 1),
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Name
                      Text(
                        user['name'] as String,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      // Phone
                      Text(
                        user['phone'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push(AppRoutes.editProfile),
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),

          // Profile Options
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Account Section
                _buildSection(
                  title: l10n.account,
                  items: [
                    _MenuItem(
                      icon: Icons.person_outline,
                      title: l10n.editProfile,
                      onTap: () => context.push(AppRoutes.editProfile),
                    ),
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      title: l10n.savedAddresses,
                      subtitle: l10n.addressesCount(2),
                      onTap: () => context.push(AppRoutes.addresses),
                    ),
                    _MenuItem(
                      icon: Icons.payment,
                      title: l10n.paymentMethods,
                      onTap: () => context.push(AppRoutes.paymentMethods),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Orders Section
                _buildSection(
                  title: l10n.orders,
                  items: [
                    _MenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: l10n.myOrders,
                      onTap: () => context.go(AppRoutes.orders),
                    ),
                    _MenuItem(
                      icon: Icons.favorite_outline,
                      title: l10n.wishlist,
                      onTap: () => context.go(AppRoutes.wishlist),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Preferences Section
                _buildSection(
                  title: l10n.preferences,
                  items: [
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      title: l10n.notifications,
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: AppColors.primary,
                      ),
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.language,
                      title: l10n.language,
                      subtitle: l10n.english,
                      onTap: () => context.push(AppRoutes.language),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Support Section
                _buildSection(
                  title: l10n.support,
                  items: [
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: l10n.helpSupport,
                      onTap: () => context.push(AppRoutes.help),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      title: l10n.aboutUs,
                      onTap: () => context.push(AppRoutes.about),
                    ),
                    _MenuItem(
                      icon: Icons.description_outlined,
                      title: l10n.termsConditions,
                      onTap: () => context.push(AppRoutes.termsConditions),
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.privacyPolicy,
                      onTap: () => context.push(AppRoutes.privacyPolicy),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Logout Section
                _buildSection(
                  items: [
                    _MenuItem(
                      icon: Icons.logout,
                      title: l10n.logout,
                      iconColor: AppColors.error,
                      titleColor: AppColors.error,
                      onTap: () => _showLogoutDialog(context, l10n),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // App Version
                Text(
                  '${l10n.version} 1.0.0',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    String? title,
    required List<_MenuItem> items,
  }) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ...items.map((item) => _buildMenuItem(item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: item.iconColor ?? AppColors.textSecondary,
      ),
      title: Text(
        item.title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: item.titleColor,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            )
          : null,
      trailing: item.trailing ??
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
      onTap: item.onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
            child: Text(
              l10n.yesLogout,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.titleColor,
    required this.onTap,
  });
}
