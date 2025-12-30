import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Terms & Conditions Screen
///
/// Displays the app's terms and conditions.
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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

            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using the Gongura Griha mobile application ("App"), '
                  'you accept and agree to be bound by the terms and provisions of this agreement. '
                  'If you do not agree to abide by these terms, please do not use this App.',
            ),

            _buildSection(
              '2. Use License',
              'Permission is granted to temporarily download one copy of the App for personal, '
                  'non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n'
                  '• Modify or copy the materials\n'
                  '• Use the materials for any commercial purpose\n'
                  '• Attempt to decompile or reverse engineer any software contained in the App\n'
                  '• Remove any copyright or other proprietary notations from the materials\n'
                  '• Transfer the materials to another person or "mirror" the materials on any other server',
            ),

            _buildSection(
              '3. Product Information',
              'We strive to provide accurate product descriptions, images, and pricing. However, we do not warrant that product descriptions or other content is accurate, complete, reliable, current, or error-free. '
                  'All products are subject to availability, and we reserve the right to limit quantities.',
            ),

            _buildSection(
              '4. Ordering and Payment',
              '• All orders are subject to acceptance and availability\n'
                  '• Prices are in Indian Rupees (INR) and include applicable taxes\n'
                  '• We accept various payment methods including UPI, Credit/Debit Cards, Net Banking, and Cash on Delivery\n'
                  '• Payment must be received before order dispatch (except COD orders)',
            ),

            _buildSection(
              '5. Shipping and Delivery',
              '• Delivery times are estimates and not guaranteed\n'
                  '• Risk of loss and title for items pass to you upon delivery\n'
                  '• We are not responsible for delays caused by shipping carriers or unforeseen circumstances\n'
                  '• Additional charges may apply for remote locations',
            ),

            _buildSection(
              '6. Returns and Refunds',
              '• Products can be returned within 7 days of delivery if unopened and in original packaging\n'
                  '• Perishable items cannot be returned unless damaged during transit\n'
                  '• Refunds will be processed within 5-7 business days after receiving the returned product\n'
                  '• Original shipping charges are non-refundable',
            ),

            _buildSection(
              '7. User Account',
              'You are responsible for maintaining the confidentiality of your account and password. '
                  'You agree to accept responsibility for all activities that occur under your account. '
                  'We reserve the right to refuse service, terminate accounts, or cancel orders at our sole discretion.',
            ),

            _buildSection(
              '8. Intellectual Property',
              'All content included in the App, such as text, graphics, logos, images, and software, '
                  'is the property of Gongura Griha or its content suppliers and is protected by Indian and international copyright laws.',
            ),

            _buildSection(
              '9. Limitation of Liability',
              'Gongura Griha shall not be liable for any indirect, incidental, special, consequential, or punitive damages, '
                  'including without limitation, loss of profits, data, use, goodwill, or other intangible losses.',
            ),

            _buildSection(
              '10. Governing Law',
              'These terms shall be governed by and construed in accordance with the laws of India. '
                  'Any disputes shall be subject to the exclusive jurisdiction of the courts in Hyderabad, Telangana.',
            ),

            _buildSection(
              '11. Changes to Terms',
              'We reserve the right to update or modify these terms at any time without prior notice. '
                  'Your continued use of the App following any changes constitutes acceptance of those changes.',
            ),

            _buildSection(
              '12. Contact Us',
              'If you have any questions about these Terms & Conditions, please contact us at:\n\n'
                  'Email: legal@gonguragriha.com\n'
                  'Phone: +91 98765 43210\n'
                  'Address: 123, Banjara Hills, Hyderabad - 500034',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
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
