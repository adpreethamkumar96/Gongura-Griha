import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

/// Checkout Screen
///
/// Allows user to select delivery address and payment method.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedAddressIndex = 0;
  String _selectedPaymentMethod = 'upi';
  bool _isPlacingOrder = false;

  // Mock data
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': '1',
      'type': 'Home',
      'name': 'Ramesh Kumar',
      'phone': '+91 98765 43210',
      'address': '123, Green Valley Apartments',
      'landmark': 'Near City Mall',
      'city': 'Hyderabad',
      'pincode': '500001',
      'isDefault': true,
    },
    {
      'id': '2',
      'type': 'Office',
      'name': 'Ramesh Kumar',
      'phone': '+91 98765 43210',
      'address': '456, Tech Park, Hitec City',
      'landmark': 'Opposite Metro Station',
      'city': 'Hyderabad',
      'pincode': '500081',
      'isDefault': false,
    },
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'upi',
      'name': 'UPI',
      'description': 'Pay using any UPI app',
      'icon': Icons.account_balance,
      'color': AppColors.upi,
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'description': 'Visa, Mastercard, RuPay',
      'icon': Icons.credit_card,
      'color': AppColors.card,
    },
    {
      'id': 'cod',
      'name': 'Cash on Delivery',
      'description': 'Pay when you receive',
      'icon': Icons.money,
      'color': AppColors.cod,
    },
  ];

  // Order summary
  final double _subtotal = 1846.0;
  final double _discount = 250.0;
  final double _deliveryCharge = 0.0;
  double get _total => _subtotal - _discount + _deliveryCharge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Section
            _buildSectionHeader('Delivery Address'),
            _buildAddressSection(),

            const SizedBox(height: 8),

            // Delivery Time Section
            _buildSectionHeader('Delivery Time'),
            _buildDeliveryTimeSection(),

            const SizedBox(height: 8),

            // Payment Method Section
            _buildSectionHeader('Payment Method'),
            _buildPaymentSection(),

            const SizedBox(height: 8),

            // Order Summary
            _buildSectionHeader('Order Summary'),
            _buildOrderSummary(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: AppTextStyles.titleSmall),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          ..._addresses.asMap().entries.map((entry) {
            final index = entry.key;
            final address = entry.value;
            return _buildAddressCard(address, index);
          }),
          // Add new address
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.primary),
            ),
            title: Text(
              'Add New Address',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            onTap: () => context.push(AppRoutes.addAddress),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address, int index) {
    final isSelected = index == _selectedAddressIndex;

    return InkWell(
      onTap: () => setState(() => _selectedAddressIndex = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<int>(
              value: index,
              groupValue: _selectedAddressIndex,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedAddressIndex = value);
                }
              },
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          address['type'] as String,
                          style: AppTextStyles.labelSmall,
                        ),
                      ),
                      if (address['isDefault'] as bool) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Default',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address['name'] as String,
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${address['address']}, ${address['landmark']}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${address['city']} - ${address['pincode']}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address['phone'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              IconButton(
                onPressed: () {
                  // Edit address
                },
                icon: Icon(Icons.edit, color: AppColors.primary, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.schedule, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Delivery',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Tomorrow, 10 AM - 2 PM',
                  style: AppTextStyles.titleSmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: _paymentMethods.map((method) {
          final isSelected = _selectedPaymentMethod == method['id'];
          return InkWell(
            onTap: () =>
                setState(() => _selectedPaymentMethod = method['id'] as String),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: method['id'] as String,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPaymentMethod = value);
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (method['color'] as Color).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      method['icon'] as IconData,
                      color: method['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method['name'] as String,
                          style: AppTextStyles.titleSmall,
                        ),
                        Text(
                          method['description'] as String,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          _buildSummaryRow('Items (3)', _subtotal),
          _buildSummaryRow('Discount', -_discount, isDiscount: true),
          _buildSummaryRow(
            'Delivery',
            _deliveryCharge,
            subtitle: 'FREE',
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: AppTextStyles.titleMedium),
              Text(
                Formatters.formatCurrency(_total),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isDiscount = false, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          subtitle != null
              ? Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Text(
                  isDiscount
                      ? '-${Formatters.formatCurrency(amount.abs())}'
                      : Formatters.formatCurrency(amount),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDiscount ? AppColors.success : null,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(_total),
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: PrimaryButton(
                      text: 'Place Order',
                      isLoading: _isPlacingOrder,
                      onPressed: _handlePlaceOrder,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder() async {
    setState(() => _isPlacingOrder = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isPlacingOrder = false);

    if (mounted) {
      // Navigate to order success
      context.go(AppRoutes.orderSuccess);
    }
  }
}
