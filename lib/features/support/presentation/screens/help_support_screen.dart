import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Help & Support Screen
///
/// Provides customer support options and FAQs.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Contact Options
            _buildContactSection(),

            const SizedBox(height: 16),

            // FAQ Section
            _buildFAQSection(),

            const SizedBox(height: 16),

            // Quick Actions
            _buildQuickActions(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.support_agent,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            'How can we help you?',
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our support team is available 24/7',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  icon: Icons.phone,
                  label: 'Call Us',
                  onTap: () => _launchPhone(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactButton(
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () => _launchEmail(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactButton(
                  icon: Icons.chat,
                  label: 'Chat',
                  onTap: () => _launchWhatsApp(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': 'How do I track my order?',
        'answer':
            'You can track your order from the "My Orders" section. Click on any order to see the detailed tracking information.',
      },
      {
        'question': 'What are the delivery charges?',
        'answer':
            'Delivery is free for orders above Rs. 499. For orders below Rs. 499, a delivery charge of Rs. 49 is applicable.',
      },
      {
        'question': 'How can I return a product?',
        'answer':
            'We accept returns within 7 days of delivery for unopened products. Please contact our support team to initiate a return.',
      },
      {
        'question': 'What payment methods are accepted?',
        'answer':
            'We accept UPI, Credit/Debit Cards, Net Banking, and Cash on Delivery. All online payments are secure and encrypted.',
      },
      {
        'question': 'How long does delivery take?',
        'answer':
            'Standard delivery takes 3-5 business days. Express delivery (where available) takes 1-2 business days.',
      },
    ];

    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Frequently Asked Questions',
              style: AppTextStyles.titleMedium,
            ),
          ),
          ...faqs.map((faq) => _buildFAQItem(
                question: faq['question']!,
                answer: faq['answer']!,
              )),
        ],
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppTextStyles.bodyMedium,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          answer,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Quick Actions',
              style: AppTextStyles.titleMedium,
            ),
          ),
          ListTile(
            leading: Icon(Icons.report_problem_outlined,
                color: AppColors.textSecondary),
            title: const Text('Report an Issue'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
            onTap: () => _showReportDialog(context),
          ),
          ListTile(
            leading:
                Icon(Icons.feedback_outlined, color: AppColors.textSecondary),
            title: const Text('Send Feedback'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
            onTap: () => _showFeedbackDialog(context),
          ),
          ListTile(
            leading:
                Icon(Icons.star_outline, color: AppColors.textSecondary),
            title: const Text('Rate Our App'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
            onTap: () => _rateApp(),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:+919876543210');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse(
        'mailto:support@gonguragriha.com?subject=Support Request');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse('https://wa.me/919876543210');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe your issue...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Issue reported. We\'ll get back to you soon.'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your feedback...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    // TODO: Open app store for rating
  }
}
