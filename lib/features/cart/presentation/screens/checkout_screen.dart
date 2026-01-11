import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/models/address_model.dart';
import '../../../../core/data/models/order_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/inventory_service.dart';
import '../../../../core/services/payment_service.dart';
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
  String? _selectedAddressId;
  String _selectedPaymentMethod = 'upi';
  bool _isPlacingOrder = false;
  bool _isLoadingAddresses = true;
  bool _orderInProgress = false; // Prevents double-tap

  List<AddressModel> _addresses = [];
  StreamSubscription? _addressSubscription;

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

  // Order summary from CartRepository
  double get _subtotal => cartRepository.subtotal;
  double get _deliveryCharge =>
      cartRepository.calculateDeliveryCharge(_subtotal);
  double get _total => cartRepository.calculateTotal();

  AddressModel? get _selectedAddress {
    if (_selectedAddressId == null) return null;
    try {
      return _addresses.firstWhere((a) => a.id == _selectedAddressId);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _addressSubscription?.cancel();
    super.dispose();
  }

  void _loadAddresses() {
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoadingAddresses = false);
      return;
    }

    _addressSubscription =
        addressService.getUserAddressesStream(userId).listen((addresses) {
      if (mounted) {
        setState(() {
          _addresses = addresses;
          _isLoadingAddresses = false;

          // Select default address or first address
          if (_selectedAddressId == null && addresses.isNotEmpty) {
            final defaultAddress = addresses.where((a) => a.isDefault).toList();
            _selectedAddressId = defaultAddress.isNotEmpty
                ? defaultAddress.first.id
                : addresses.first.id;
          }
        });
      }
    });
  }

  PaymentMethod _getPaymentMethod() {
    switch (_selectedPaymentMethod) {
      case 'upi':
        return PaymentMethod.upi;
      case 'card':
        return PaymentMethod.card;
      case 'cod':
        return PaymentMethod.cod;
      default:
        return PaymentMethod.cod;
    }
  }

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
    if (_isLoadingAddresses) {
      return Container(
        padding: const EdgeInsets.all(32),
        color: AppColors.surface,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_addresses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        color: AppColors.surface,
        child: Column(
          children: [
            Icon(Icons.location_off, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              'No saved addresses',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.addAddress),
              icon: const Icon(Icons.add),
              label: const Text('Add Address'),
            ),
          ],
        ),
      );
    }

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          ..._addresses.map((address) => _buildAddressCard(address)),
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

  Widget _buildAddressCard(AddressModel address) {
    final isSelected = address.id == _selectedAddressId;

    return InkWell(
      onTap: () => setState(() => _selectedAddressId = address.id),
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
            Radio<String>(
              value: address.id,
              groupValue: _selectedAddressId,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedAddressId = value);
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
                          address.type.displayName,
                          style: AppTextStyles.labelSmall,
                        ),
                      ),
                      if (address.isDefault) ...[
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
                    address.name,
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.landmark.isNotEmpty
                        ? '${address.address}, ${address.landmark}'
                        : address.address,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${address.city} - ${address.pincode}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phone,
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
                  context.push(AppRoutes.getEditAddressRoute(address.id));
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
    final itemCount = cartRepository.getItems().length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          _buildSummaryRow('Items ($itemCount)', _subtotal),
          _buildSummaryRow(
            'Delivery',
            _deliveryCharge,
            subtitle: _deliveryCharge == 0 ? 'FREE' : null,
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
    final canPlaceOrder = _selectedAddress != null && !_isPlacingOrder;

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
                      onPressed: canPlaceOrder ? _handlePlaceOrder : null,
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
    // Prevent double-tap - if order is already in progress, ignore
    if (_orderInProgress) {
      debugPrint('Order already in progress, ignoring duplicate tap');
      return;
    }

    final selectedAddress = _selectedAddress;
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    final userId = authService.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place order')),
      );
      return;
    }

    // Set order in progress BEFORE any async operation
    _orderInProgress = true;
    setState(() => _isPlacingOrder = true);

    final cartItems = cartRepository.getItems();
    final validationItems = cartItems
        .map((item) => CartValidationItem(
              productSlug: item.productSlug,
              productName: item.productName,
              sizeCode: item.sizeCode,
              quantity: item.quantity,
            ))
        .toList();

    // Step 1: Reserve inventory FIRST using atomic transaction
    // This prevents race conditions where 5 users try to buy the same item
    final reservationResult = await inventoryService.reserveInventory(validationItems);

    if (!reservationResult.success) {
      _orderInProgress = false;
      setState(() => _isPlacingOrder = false);
      if (mounted) {
        _showStockUnavailableDialog(reservationResult.errors);
      }
      return;
    }

    // Step 2: Inventory reserved successfully - proceed with payment
    if (_selectedPaymentMethod == 'cod') {
      // Cash on Delivery - create order directly
      await _createOrder(
        userId: userId,
        selectedAddress: selectedAddress,
        cartItems: cartItems,
        validationItems: validationItems,
        paymentId: null,
        inventoryAlreadyReserved: true,
      );
    } else {
      // Online Payment - Open Razorpay
      // If payment fails, we'll release the reserved inventory
      _openRazorpayCheckout(
        userId: userId,
        selectedAddress: selectedAddress,
        cartItems: cartItems,
        validationItems: validationItems,
      );
    }
  }

  void _openRazorpayCheckout({
    required String userId,
    required AddressModel selectedAddress,
    required List<dynamic> cartItems,
    required List<CartValidationItem> validationItems,
  }) {
    final userPhone = selectedAddress.phone.replaceAll('+91 ', '').replaceAll(' ', '');
    final userEmail = authService.currentUser?.email;

    // Generate a temporary order ID for Razorpay
    // In production, you would create a Razorpay order on your backend first
    final tempOrderId = 'GG${DateTime.now().millisecondsSinceEpoch}';

    paymentService.openCheckout(
      amount: _total,
      orderId: tempOrderId,
      customerName: selectedAddress.name,
      customerPhone: userPhone,
      customerEmail: userEmail,
      description: 'Order for ${cartItems.length} item(s)',
      onComplete: (PaymentResult result) async {
        if (!mounted) return;

        if (result.isSuccess) {
          // Payment successful - create order directly
          // NOTE: In production with server-side order creation, verify signature here
          // For testing without Razorpay Orders API, we skip signature verification
          try {
            await _createOrder(
              userId: userId,
              selectedAddress: selectedAddress,
              cartItems: cartItems,
              validationItems: validationItems,
              paymentId: result.paymentId,
              inventoryAlreadyReserved: true,
            );
          } catch (e) {
            // Order creation error - release inventory
            await inventoryService.releaseInventory(validationItems);
            _orderInProgress = false;
            setState(() => _isPlacingOrder = false);
            _showPaymentFailedDialog(e.toString().replaceFirst('Exception: ', ''));
          }
        } else if (result.isExternalWallet) {
          // External wallet selected - wait for completion
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Redirecting to ${result.walletName}...'),
              backgroundColor: AppColors.info,
            ),
          );
        } else {
          // Payment failed or cancelled - RELEASE the reserved inventory
          await inventoryService.releaseInventory(validationItems);
          _orderInProgress = false;
          setState(() => _isPlacingOrder = false);
          _showPaymentFailedDialog(result.errorMessage ?? 'Payment failed');
        }
      },
    );
  }

  Future<void> _createOrder({
    required String userId,
    required AddressModel selectedAddress,
    required List<dynamic> cartItems,
    required List<CartValidationItem> validationItems,
    String? paymentId,
    bool inventoryAlreadyReserved = false,
  }) async {
    // Note: Inventory should already be reserved before calling this method
    // This is done atomically in _handlePlaceOrder to prevent race conditions

    // Create order in Firestore
    try {
      final orderItems = cartItems
          .map((item) => OrderItem(
                productSlug: item.productSlug,
                productName: item.productName,
                productImage: item.productImage,
                sizeCode: item.sizeCode,
                sizeName: item.sizeName,
                weight: item.weight,
                quantity: item.quantity,
                price: item.price,
                totalPrice: item.price * item.quantity,
              ))
          .toList();

      final orderAddress = OrderAddress(
        name: selectedAddress.name,
        phone: selectedAddress.phone,
        address: selectedAddress.address,
        landmark: selectedAddress.landmark,
        city: selectedAddress.city,
        state: selectedAddress.state,
        pincode: selectedAddress.pincode,
        type: selectedAddress.type.displayName,
      );

      final order = await orderService.createOrder(
        userId: userId,
        items: orderItems,
        deliveryAddress: orderAddress,
        subtotal: _subtotal,
        deliveryCharge: _deliveryCharge,
        total: _total,
        paymentMethod: _getPaymentMethod(),
        paymentId: paymentId,
      );

      // Track purchase in analytics
      analyticsService.logPurchase(
        orderId: order.orderNumber,
        items: orderItems.map((item) => {
          'itemId': item.productSlug,
          'itemName': item.productName,
          'category': null,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
        value: _total,
        shipping: _deliveryCharge,
        discount: null, // TODO: Implement coupon support
        couponCode: null,
      );

      // Clear cart after successful order
      await cartRepository.clearCart();

      setState(() => _isPlacingOrder = false);

      if (mounted) {
        // Navigate to order success with order number
        context.go(
          AppRoutes.orderSuccess,
          extra: {'orderNumber': order.orderNumber},
        );
      }
    } catch (e) {
      // Release inventory if order creation fails
      await inventoryService.releaseInventory(validationItems);
      _orderInProgress = false;
      setState(() => _isPlacingOrder = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPaymentFailedDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Payment Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePlaceOrder(); // Retry
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showStockUnavailableDialog(List<String> errors) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.warning),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Stock No Longer Available'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sorry! Someone else just purchased the last item(s):',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  children: errors.map((error) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withAlpha(50)),
                      ),
                      child: Text(
                        error,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please update your cart and try again.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.cart);
            },
            child: const Text('Update Cart'),
          ),
        ],
      ),
    );
  }
}
