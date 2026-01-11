import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/models/saved_payment_model.dart';
import '../../../../core/di/injection.dart';

/// Payment Methods Screen
///
/// Displays and manages saved payment methods from Firestore.
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Payment Methods')),
        body: const Center(child: Text('Please log in to view payment methods')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: StreamBuilder<List<SavedPaymentModel>>(
        stream: savedPaymentService.getSavedPaymentsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final payments = snapshot.data ?? [];
          final cards = payments.where((p) => p.type == SavedPaymentType.card).toList();
          final upis = payments.where((p) => p.type == SavedPaymentType.upi).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // UPI Section
                _buildSectionHeader('UPI', onAdd: _showAddUpiDialog),
                if (upis.isEmpty)
                  _buildEmptyCard('No UPI IDs saved')
                else
                  ...upis.map((upi) => _buildUpiCard(upi)),

                const SizedBox(height: 24),

                // Cards Section
                _buildSectionHeader('Cards', onAdd: _showAddCardDialog),
                if (cards.isEmpty)
                  _buildEmptyCard('No cards saved')
                else
                  ...cards.map((card) => _buildCardItem(card)),

                const SizedBox(height: 24),

                // Other Payment Options
                _buildSectionHeader('Other Options'),
                _buildPaymentOption(
                  icon: Icons.money,
                  title: 'Cash on Delivery',
                  subtitle: 'Pay when you receive your order',
                  color: AppColors.cod,
                ),
                _buildPaymentOption(
                  icon: Icons.account_balance,
                  title: 'Net Banking',
                  subtitle: 'Pay using your bank account',
                  color: AppColors.info,
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium,
          ),
          if (onAdd != null)
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildUpiCard(SavedPaymentModel upi) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: upi.isDefault
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.upi.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: AppColors.upi,
          ),
        ),
        title: Text(
          upi.displayName,
          style: AppTextStyles.bodyMedium,
        ),
        subtitle: upi.isDefault
            ? Text(
                'Default',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              )
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUpiAction(value, upi),
          itemBuilder: (context) => [
            if (!upi.isDefault)
              const PopupMenuItem(
                value: 'default',
                child: Text('Set as Default'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Remove'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(SavedPaymentModel card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: card.isDefault
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.card.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.credit_card,
            color: AppColors.card,
          ),
        ),
        title: Text(
          card.displayName,
          style: AppTextStyles.bodyMedium,
        ),
        subtitle: card.isDefault
            ? Text(
                'Default',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              )
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCardAction(value, card),
          itemBuilder: (context) => [
            if (!card.isDefault)
              const PopupMenuItem(
                value: 'default',
                child: Text('Set as Default'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Remove'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: AppTextStyles.bodyMedium),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Future<void> _handleUpiAction(String action, SavedPaymentModel upi) async {
    final user = authService.currentUser;
    if (user == null) return;

    switch (action) {
      case 'default':
        final success = await savedPaymentService.setDefaultPayment(user.uid, upi.id);
        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Default UPI updated')),
          );
        }
        break;
      case 'delete':
        _showDeleteConfirmation(
          'Remove UPI',
          'Are you sure you want to remove this UPI ID?',
          () async {
            final success = await savedPaymentService.deletePayment(user.uid, upi.id);
            if (mounted && success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('UPI removed successfully')),
              );
            }
          },
        );
        break;
    }
  }

  Future<void> _handleCardAction(String action, SavedPaymentModel card) async {
    final user = authService.currentUser;
    if (user == null) return;

    switch (action) {
      case 'default':
        final success = await savedPaymentService.setDefaultPayment(user.uid, card.id);
        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Default card updated')),
          );
        }
        break;
      case 'delete':
        _showDeleteConfirmation(
          'Remove Card',
          'Are you sure you want to remove this card?',
          () async {
            final success = await savedPaymentService.deletePayment(user.uid, card.id);
            if (mounted && success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card removed successfully')),
              );
            }
          },
        );
        break;
    }
  }

  void _showDeleteConfirmation(
      String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUpiDialog() {
    final controller = TextEditingController();
    final user = authService.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add UPI ID'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'yourname@upi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                Navigator.pop(dialogContext);

                final result = await savedPaymentService.saveUpi(
                  userId: user.uid,
                  upiId: controller.text.trim(),
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result != null
                          ? 'UPI ID added'
                          : 'Failed to add UPI ID'),
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.credit_card,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Card details will be securely collected through Razorpay during checkout. Your card will be saved for future purchases.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
