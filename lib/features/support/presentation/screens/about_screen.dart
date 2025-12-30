import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// About Screen
///
/// Displays information about the app and company.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.eco,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gongura Griha',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Authentic Andhra Pickles',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Our Story
                _buildSection(
                  title: 'Our Story',
                  content:
                      'Gongura Griha was born from a passion for authentic Andhra flavors. '
                      'Started by a family of pickle enthusiasts in Hyderabad, we bring you '
                      'the taste of homemade Andhra pickles, made with love and traditional recipes '
                      'passed down through generations.\n\n'
                      'Our gongura pickles are made from the finest sorrel leaves, sourced directly '
                      'from farms in Telangana, ensuring the authentic tangy taste that Andhra '
                      'pickles are famous for.',
                ),

                const SizedBox(height: 16),

                // Why Choose Us
                _buildSection(
                  title: 'Why Choose Us',
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.eco,
                        title: '100% Natural',
                        description: 'No preservatives or artificial colors',
                      ),
                      _buildFeatureItem(
                        icon: Icons.verified,
                        title: 'Authentic Recipes',
                        description: 'Traditional Andhra cooking methods',
                      ),
                      _buildFeatureItem(
                        icon: Icons.local_shipping,
                        title: 'Fresh Delivery',
                        description: 'Delivered fresh to your doorstep',
                      ),
                      _buildFeatureItem(
                        icon: Icons.favorite,
                        title: 'Made with Love',
                        description: 'Handcrafted in small batches',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Connect With Us
                _buildSection(
                  title: 'Connect With Us',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.facebook,
                        color: AppColors.facebook,
                        onTap: () => _launchUrl('https://facebook.com'),
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        icon: Icons.camera_alt,
                        color: const Color(0xFFE1306C),
                        onTap: () => _launchUrl('https://instagram.com'),
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        icon: Icons.share,
                        color: const Color(0xFF1DA1F2),
                        onTap: () => _launchUrl('https://twitter.com'),
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        icon: Icons.play_arrow,
                        color: const Color(0xFFFF0000),
                        onTap: () => _launchUrl('https://youtube.com'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Contact Info
                _buildSection(
                  title: 'Contact Information',
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.location_on,
                            color: AppColors.primary),
                        title: const Text('Address'),
                        subtitle: const Text(
                          '123, Banjara Hills, Road No. 12\n'
                          'Hyderabad, Telangana - 500034',
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.email, color: AppColors.primary),
                        title: const Text('Email'),
                        subtitle: const Text('info@gonguragriha.com'),
                        onTap: () => _launchUrl(
                            'mailto:info@gonguragriha.com'),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone, color: AppColors.primary),
                        title: const Text('Phone'),
                        subtitle: const Text('+91 98765 43210'),
                        onTap: () => _launchUrl('tel:+919876543210'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // App Version
                Text(
                  'Version 1.0.0',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Made with love in India',
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
    required String title,
    String? content,
    Widget? child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall,
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
