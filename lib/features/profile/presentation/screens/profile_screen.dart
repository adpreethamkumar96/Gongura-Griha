import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Profile Screen
///
/// Displays user profile information and settings options.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  title: 'Account',
                  items: [
                    _MenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () => context.push(AppRoutes.editProfile),
                    ),
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      subtitle: '2 addresses',
                      onTap: () => context.push(AppRoutes.addresses),
                    ),
                    _MenuItem(
                      icon: Icons.payment,
                      title: 'Payment Methods',
                      onTap: () => context.push(AppRoutes.paymentMethods),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Orders Section
                _buildSection(
                  title: 'Orders',
                  items: [
                    _MenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My Orders',
                      onTap: () => context.go(AppRoutes.orders),
                    ),
                    _MenuItem(
                      icon: Icons.favorite_outline,
                      title: 'Wishlist',
                      onTap: () => context.go(AppRoutes.wishlist),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Preferences Section
                _buildSection(
                  title: 'Preferences',
                  items: [
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: AppColors.primary,
                      ),
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () => context.push(AppRoutes.language),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Support Section
                _buildSection(
                  title: 'Support',
                  items: [
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => context.push(AppRoutes.help),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      title: 'About Us',
                      onTap: () => context.push(AppRoutes.about),
                    ),
                    _MenuItem(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      onTap: () => context.push(AppRoutes.termsConditions),
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
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
                      title: 'Logout',
                      iconColor: AppColors.error,
                      titleColor: AppColors.error,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // App Version
                Text(
                  'Version 1.0.0',
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
            child: Text(
              'Logout',
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
