import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Privacy Policy Screen
///
/// Displays the app's privacy policy.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Updated
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.update,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last Updated: January 1, 2025',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Introduction
            Text(
              'Your privacy is important to us. This Privacy Policy explains how Gongura Griha ("we", "us", or "our") collects, uses, discloses, and safeguards your information when you use our mobile application.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 24),

            _buildSection(
              '1. Information We Collect',
              'Personal Information',
              '• Name and contact details (email, phone number)\n'
                  '• Delivery addresses\n'
                  '• Payment information (processed securely through payment gateways)\n'
                  '• Order history and preferences',
            ),

            _buildSubSection(
              'Device Information',
              '• Device type and operating system\n'
                  '• Unique device identifiers\n'
                  '• IP address and location data\n'
                  '• App usage statistics',
            ),

            _buildSection(
              '2. How We Use Your Information',
              '',
              '• Process and fulfill your orders\n'
                  '• Send order confirmations and delivery updates\n'
                  '• Provide customer support\n'
                  '• Personalize your shopping experience\n'
                  '• Send promotional offers and updates (with your consent)\n'
                  '• Improve our products and services\n'
                  '• Detect and prevent fraud',
            ),

            _buildSection(
              '3. Information Sharing',
              '',
              'We may share your information with:\n\n'
                  '• Delivery partners to fulfill orders\n'
                  '• Payment processors for secure transactions\n'
                  '• Analytics providers to improve our services\n'
                  '• Law enforcement when required by law\n\n'
                  'We do not sell your personal information to third parties.',
            ),

            _buildSection(
              '4. Data Security',
              '',
              'We implement appropriate security measures to protect your personal information, including:\n\n'
                  '• Encryption of sensitive data\n'
                  '• Secure socket layer (SSL) technology\n'
                  '• Regular security assessments\n'
                  '• Access controls and authentication\n\n'
                  'However, no method of transmission over the Internet is 100% secure.',
            ),

            _buildSection(
              '5. Data Retention',
              '',
              'We retain your personal information for as long as necessary to:\n\n'
                  '• Provide our services to you\n'
                  '• Comply with legal obligations\n'
                  '• Resolve disputes\n'
                  '• Enforce our agreements\n\n'
                  'You may request deletion of your account and associated data at any time.',
            ),

            _buildSection(
              '6. Your Rights',
              '',
              'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Correct inaccurate information\n'
                  '• Request deletion of your data\n'
                  '• Opt-out of marketing communications\n'
                  '• Withdraw consent for data processing\n'
                  '• Data portability',
            ),

            _buildSection(
              '7. Cookies and Tracking',
              '',
              'We use cookies and similar tracking technologies to:\n\n'
                  '• Remember your preferences\n'
                  '• Analyze app usage patterns\n'
                  '• Deliver personalized content\n\n'
                  'You can control cookie preferences through your device settings.',
            ),

            _buildSection(
              '8. Third-Party Links',
              '',
              'Our app may contain links to third-party websites or services. '
                  'We are not responsible for the privacy practices of these external sites. '
                  'We encourage you to read the privacy policies of any linked services.',
            ),

            _buildSection(
              '9. Children\'s Privacy',
              '',
              'Our services are not intended for children under 18 years of age. '
                  'We do not knowingly collect personal information from children. '
                  'If you believe we have collected information from a child, please contact us immediately.',
            ),

            _buildSection(
              '10. Changes to This Policy',
              '',
              'We may update this Privacy Policy from time to time. '
                  'We will notify you of any changes by posting the new policy on this page '
                  'and updating the "Last Updated" date. Continued use of the app after changes '
                  'constitutes acceptance of the updated policy.',
            ),

            _buildSection(
              '11. Contact Us',
              '',
              'If you have any questions about this Privacy Policy, please contact us:\n\n'
                  'Email: privacy@gonguragriha.com\n'
                  'Phone: +91 7995314630\n'
                  'Address: Sierra - I - 701, Rajapushpa Atria, Kokapet, Hyderabad, Telangana - 500075\n\n'
                  'Data Protection Officer: dpo@gonguragriha.com',
            ),

            const SizedBox(height: 16),

            // Consent Statement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(51)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.verified_user,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using Gongura Griha, you consent to the collection and use of your information as described in this Privacy Policy.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
