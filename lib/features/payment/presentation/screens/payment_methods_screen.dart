import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Payment Methods Screen
///
/// Displays and manages saved payment methods.
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // Mock saved payment methods
  final List<Map<String, dynamic>> _savedCards = [
    {
      'id': '1',
      'type': 'visa',
      'lastFour': '4242',
      'expiryMonth': '12',
      'expiryYear': '26',
      'holderName': 'Ramesh Kumar',
      'isDefault': true,
    },
    {
      'id': '2',
      'type': 'mastercard',
      'lastFour': '8888',
      'expiryMonth': '08',
      'expiryYear': '25',
      'holderName': 'Ramesh Kumar',
      'isDefault': false,
    },
  ];

  final List<Map<String, dynamic>> _savedUpi = [
    {
      'id': '1',
      'upiId': 'ramesh@okicici',
      'isDefault': true,
    },
    {
      'id': '2',
      'upiId': 'ramesh.kumar@paytm',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // UPI Section
            _buildSectionHeader('UPI', onAdd: _showAddUpiDialog),
            if (_savedUpi.isEmpty)
              _buildEmptyCard('No UPI IDs saved')
            else
              ..._savedUpi.map((upi) => _buildUpiCard(upi)),

            const SizedBox(height: 24),

            // Cards Section
            _buildSectionHeader('Cards', onAdd: _showAddCardDialog),
            if (_savedCards.isEmpty)
              _buildEmptyCard('No cards saved')
            else
              ..._savedCards.map((card) => _buildCardItem(card)),

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

  Widget _buildUpiCard(Map<String, dynamic> upi) {
    final isDefault = upi['isDefault'] as bool;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isDefault
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
          upi['upiId'] as String,
          style: AppTextStyles.bodyMedium,
        ),
        subtitle: isDefault
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
            if (!isDefault)
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

  Widget _buildCardItem(Map<String, dynamic> card) {
    final isDefault = card['isDefault'] as bool;
    final cardType = card['type'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isDefault
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
            _getCardIcon(cardType),
            color: AppColors.card,
          ),
        ),
        title: Text(
          '${_getCardName(cardType)} •••• ${card['lastFour']}',
          style: AppTextStyles.bodyMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expires ${card['expiryMonth']}/${card['expiryYear']}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (isDefault)
              Text(
                'Default',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCardAction(value, card),
          itemBuilder: (context) => [
            if (!isDefault)
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
        isThreeLine: isDefault,
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

  IconData _getCardIcon(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  String _getCardName(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'Amex';
      default:
        return 'Card';
    }
  }

  void _handleUpiAction(String action, Map<String, dynamic> upi) {
    switch (action) {
      case 'default':
        setState(() {
          for (var u in _savedUpi) {
            u['isDefault'] = u['id'] == upi['id'];
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default UPI updated')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(
          'Remove UPI',
          'Are you sure you want to remove this UPI ID?',
          () {
            setState(() {
              _savedUpi.removeWhere((u) => u['id'] == upi['id']);
            });
          },
        );
        break;
    }
  }

  void _handleCardAction(String action, Map<String, dynamic> card) {
    switch (action) {
      case 'default':
        setState(() {
          for (var c in _savedCards) {
            c['isDefault'] = c['id'] == card['id'];
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default card updated')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(
          'Remove Card',
          'Are you sure you want to remove this card?',
          () {
            setState(() {
              _savedCards.removeWhere((c) => c['id'] == card['id']);
            });
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Removed successfully')),
              );
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _savedUpi.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'upiId': controller.text,
                    'isDefault': _savedUpi.isEmpty,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('UPI ID added')),
                );
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
              'Card details will be securely collected through Razorpay during checkout.',
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
