# Gongura-Griha: Payment Integration Guide

> **Document Status:** Sacred - Must be followed for all implementation decisions
> **Version:** 1.0.0
> **Last Updated:** December 2024

---

## 1. Payment Gateway: Razorpay

### 1.1 Why Razorpay

| Feature | Benefit |
|---------|---------|
| UPI Support | 99% success rate, native integration |
| UPI Pricing | 0% transaction fee |
| Card Pricing | ~2% per transaction |
| Settlement | T+2 working days |
| Indian Payment Methods | All major wallets, net banking |
| Flutter SDK | Official package available |
| Compliance | PCI DSS Level 1 |

### 1.2 Supported Payment Methods

| Method | Type | Notes |
|--------|------|-------|
| UPI | Google Pay, PhonePe, Paytm, BHIM | Recommended |
| Cards | Credit, Debit (Visa, Mastercard, RuPay) | 3D Secure |
| Net Banking | All major banks | Redirect flow |
| Wallets | Paytm, Amazon Pay, Freecharge, etc. | |
| EMI | Credit card EMI | For orders > ₹3000 |
| Pay Later | Simpl, LazyPay | Limited |
| Cash on Delivery | Manual | ₹40 extra charge |

---

## 2. Razorpay Setup

### 2.1 Account Configuration

**Required Documents:**
- PAN Card
- GST Registration
- Bank Account Details
- Business Registration Certificate
- Address Proof

**Dashboard Setup:**
1. Create account at https://dashboard.razorpay.com
2. Complete KYC verification
3. Configure webhook endpoints
4. Generate API keys (Test + Live)

### 2.2 API Keys

```
# Test Environment
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxxxxx

# Production Environment
RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxxxxx
```

**IMPORTANT:** Never expose `KEY_SECRET` in client-side code.

### 2.3 Webhook Configuration

**Webhook URL:** `https://api.gongura-griha.com/v1/webhooks/razorpay`

**Events to Subscribe:**
- `payment.captured`
- `payment.failed`
- `payment.authorized`
- `refund.created`
- `refund.processed`
- `refund.failed`

**Webhook Secret:** Configure in dashboard and store securely.

---

## 3. Payment Flow

### 3.1 Standard Payment Flow

```
┌─────────┐         ┌─────────┐         ┌─────────┐         ┌─────────┐
│  User   │         │   App   │         │  Server │         │Razorpay │
└────┬────┘         └────┬────┘         └────┬────┘         └────┬────┘
     │                   │                   │                   │
     │  1. Checkout      │                   │                   │
     │──────────────────>│                   │                   │
     │                   │                   │                   │
     │                   │ 2. Create Order   │                   │
     │                   │──────────────────>│                   │
     │                   │                   │                   │
     │                   │                   │ 3. Create RZP     │
     │                   │                   │    Order          │
     │                   │                   │──────────────────>│
     │                   │                   │                   │
     │                   │                   │ 4. Order ID       │
     │                   │                   │<──────────────────│
     │                   │                   │                   │
     │                   │ 5. Order Details  │                   │
     │                   │   + RZP Order ID  │                   │
     │                   │<──────────────────│                   │
     │                   │                   │                   │
     │                   │ 6. Open Razorpay  │                   │
     │                   │    Checkout       │                   │
     │<─────────────────────────────────────────────────────────>│
     │                   │                   │                   │
     │  7. Payment       │                   │                   │
     │──────────────────────────────────────────────────────────>│
     │                   │                   │                   │
     │                   │ 8. Payment        │                   │
     │                   │    Response       │                   │
     │                   │<─────────────────────────────────────│
     │                   │                   │                   │
     │                   │ 9. Verify Payment │                   │
     │                   │──────────────────>│                   │
     │                   │                   │                   │
     │                   │                   │ 10. Verify        │
     │                   │                   │     Signature     │
     │                   │                   │──────────────────>│
     │                   │                   │                   │
     │                   │                   │ 11. Confirmed     │
     │                   │                   │<──────────────────│
     │                   │                   │                   │
     │                   │ 12. Order         │                   │
     │                   │     Confirmed     │                   │
     │                   │<──────────────────│                   │
     │                   │                   │                   │
     │ 13. Success       │                   │                   │
     │<──────────────────│                   │                   │
     │                   │                   │                   │
```

### 3.2 Webhook Flow (Backup)

```
                                            ┌─────────────────┐
                                            │    Razorpay     │
                                            └────────┬────────┘
                                                     │
                                                     │ Webhook: payment.captured
                                                     ▼
                                            ┌─────────────────┐
                                            │     Server      │
                                            │                 │
                                            │ 1. Verify       │
                                            │    signature    │
                                            │                 │
                                            │ 2. Update order │
                                            │    status       │
                                            │                 │
                                            │ 3. Send         │
                                            │    confirmation │
                                            └─────────────────┘
```

---

## 4. Backend Implementation

### 4.1 Create Razorpay Order

```javascript
// services/payment.service.js

const Razorpay = require('razorpay');

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

async function createRazorpayOrder(orderId, amount, currency = 'INR') {
  try {
    const options = {
      amount: Math.round(amount * 100), // Convert to paise
      currency: currency,
      receipt: orderId,
      notes: {
        orderId: orderId,
        source: 'gongura-griha-app',
      },
    };

    const razorpayOrder = await razorpay.orders.create(options);

    return {
      razorpayOrderId: razorpayOrder.id,
      amount: razorpayOrder.amount,
      currency: razorpayOrder.currency,
      key: process.env.RAZORPAY_KEY_ID,
    };
  } catch (error) {
    console.error('Razorpay order creation failed:', error);
    throw new Error('Payment initialization failed');
  }
}
```

### 4.2 Verify Payment Signature

```javascript
// services/payment.service.js

const crypto = require('crypto');

function verifyPaymentSignature(razorpayOrderId, razorpayPaymentId, razorpaySignature) {
  const body = razorpayOrderId + '|' + razorpayPaymentId;

  const expectedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(body)
    .digest('hex');

  return expectedSignature === razorpaySignature;
}

async function verifyAndCapturePayment(orderId, paymentDetails) {
  const { razorpayPaymentId, razorpayOrderId, razorpaySignature } = paymentDetails;

  // Verify signature
  const isValid = verifyPaymentSignature(
    razorpayOrderId,
    razorpayPaymentId,
    razorpaySignature
  );

  if (!isValid) {
    throw new Error('Invalid payment signature');
  }

  // Fetch payment details from Razorpay for additional verification
  const payment = await razorpay.payments.fetch(razorpayPaymentId);

  if (payment.status !== 'captured') {
    throw new Error('Payment not captured');
  }

  // Update order in database
  await updateOrderPaymentStatus(orderId, {
    status: 'confirmed',
    paymentStatus: 'paid',
    razorpayOrderId,
    razorpayPaymentId,
    razorpaySignature,
    paymentMethod: mapPaymentMethod(payment.method),
  });

  return { success: true };
}

function mapPaymentMethod(razorpayMethod) {
  const methodMap = {
    'upi': 'upi',
    'card': 'card',
    'netbanking': 'netbanking',
    'wallet': 'wallet',
    'emi': 'emi',
  };
  return methodMap[razorpayMethod] || 'other';
}
```

### 4.3 Webhook Handler

```javascript
// routes/webhook.routes.js

const crypto = require('crypto');

async function handleRazorpayWebhook(req, res) {
  const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;
  const signature = req.headers['x-razorpay-signature'];

  // Verify webhook signature
  const expectedSignature = crypto
    .createHmac('sha256', webhookSecret)
    .update(JSON.stringify(req.body))
    .digest('hex');

  if (signature !== expectedSignature) {
    console.error('Webhook signature verification failed');
    return res.status(400).json({ error: 'Invalid signature' });
  }

  const event = req.body.event;
  const payload = req.body.payload;

  try {
    switch (event) {
      case 'payment.captured':
        await handlePaymentCaptured(payload.payment.entity);
        break;

      case 'payment.failed':
        await handlePaymentFailed(payload.payment.entity);
        break;

      case 'refund.processed':
        await handleRefundProcessed(payload.refund.entity);
        break;

      default:
        console.log('Unhandled webhook event:', event);
    }

    res.status(200).json({ received: true });
  } catch (error) {
    console.error('Webhook processing error:', error);
    res.status(500).json({ error: 'Webhook processing failed' });
  }
}

async function handlePaymentCaptured(payment) {
  const orderId = payment.notes?.orderId;

  if (!orderId) {
    console.error('Order ID not found in payment notes');
    return;
  }

  // Update order status (idempotent operation)
  await updateOrderPaymentStatus(orderId, {
    status: 'confirmed',
    paymentStatus: 'paid',
    razorpayPaymentId: payment.id,
  });

  // Send confirmation notification
  await sendOrderConfirmationNotification(orderId);
}

async function handlePaymentFailed(payment) {
  const orderId = payment.notes?.orderId;

  if (orderId) {
    await updateOrderPaymentStatus(orderId, {
      paymentStatus: 'failed',
      paymentErrorCode: payment.error_code,
      paymentErrorDescription: payment.error_description,
    });
  }
}
```

### 4.4 Refund Processing

```javascript
// services/payment.service.js

async function initiateRefund(orderId, amount, reason) {
  const order = await getOrderById(orderId);

  if (!order.razorpayPaymentId) {
    throw new Error('No payment found for this order');
  }

  const refundOptions = {
    payment_id: order.razorpayPaymentId,
    amount: Math.round(amount * 100), // In paise
    speed: 'normal', // 'normal' or 'optimum'
    notes: {
      orderId: orderId,
      reason: reason,
    },
  };

  const refund = await razorpay.payments.refund(
    order.razorpayPaymentId,
    refundOptions
  );

  // Update order
  await updateOrder(orderId, {
    status: 'refund_initiated',
    refundId: refund.id,
    refundAmount: amount,
    refundReason: reason,
  });

  return refund;
}
```

---

## 5. Flutter Implementation

### 5.1 Package Setup

```yaml
# pubspec.yaml
dependencies:
  razorpay_flutter: ^1.3.6
```

### 5.2 Payment Service

```dart
// lib/features/checkout/data/services/payment_service.dart

import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;

  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required String razorpayOrderId,
    required int amount, // In paise
    required String key,
    required String userPhone,
    required String userEmail,
    required String userName,
    String? description,
  }) {
    var options = {
      'key': key,
      'amount': amount,
      'order_id': razorpayOrderId,
      'name': 'Gongura-Griha',
      'description': description ?? 'Order Payment',
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': '#2E7D32', // Primary green
      },
      'modal': {
        'confirm_close': true,
        'animation': true,
      },
      'retry': {
        'enabled': true,
        'max_count': 3,
      },
      'send_sms_hash': true,
      'remember_customer': true,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onExternalWallet?.call(response);
  }

  void dispose() {
    _razorpay.clear();
  }
}
```

### 5.3 Checkout BLoC

```dart
// lib/features/checkout/presentation/bloc/checkout_bloc.dart

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CreateOrderUseCase createOrder;
  final VerifyPaymentUseCase verifyPayment;
  final PaymentService paymentService;

  CheckoutBloc({
    required this.createOrder,
    required this.verifyPayment,
    required this.paymentService,
  }) : super(CheckoutInitial()) {
    on<InitiatePaymentEvent>(_onInitiatePayment);
    on<PaymentSuccessEvent>(_onPaymentSuccess);
    on<PaymentFailedEvent>(_onPaymentFailed);

    // Setup payment callbacks
    paymentService.onPaymentSuccess = (response) {
      add(PaymentSuccessEvent(
        paymentId: response.paymentId!,
        orderId: response.orderId!,
        signature: response.signature!,
      ));
    };

    paymentService.onPaymentError = (response) {
      add(PaymentFailedEvent(
        code: response.code,
        message: response.message ?? 'Payment failed',
      ));
    };
  }

  Future<void> _onInitiatePayment(
    InitiatePaymentEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());

    try {
      // Create order on backend
      final result = await createOrder(CreateOrderParams(
        addressId: event.addressId,
        paymentMethod: event.paymentMethod,
        couponCode: event.couponCode,
      ));

      result.fold(
        (failure) => emit(CheckoutError(failure.message)),
        (orderData) {
          if (event.paymentMethod == 'cod') {
            // COD doesn't need Razorpay
            emit(CheckoutSuccess(orderData.order));
          } else {
            // Open Razorpay checkout
            emit(PaymentInProgress(orderData.order.id));

            paymentService.openCheckout(
              razorpayOrderId: orderData.payment.razorpayOrderId,
              amount: orderData.payment.amount,
              key: orderData.payment.key,
              userPhone: event.userPhone,
              userEmail: event.userEmail,
              userName: event.userName,
            );
          }
        },
      );
    } catch (e) {
      emit(CheckoutError('Failed to create order'));
    }
  }

  Future<void> _onPaymentSuccess(
    PaymentSuccessEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(VerifyingPayment());

    try {
      final result = await verifyPayment(VerifyPaymentParams(
        orderId: state.orderId!,
        razorpayPaymentId: event.paymentId,
        razorpayOrderId: event.orderId,
        razorpaySignature: event.signature,
      ));

      result.fold(
        (failure) => emit(CheckoutError('Payment verification failed')),
        (order) => emit(CheckoutSuccess(order)),
      );
    } catch (e) {
      emit(CheckoutError('Payment verification failed'));
    }
  }

  Future<void> _onPaymentFailed(
    PaymentFailedEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(PaymentFailed(
      code: event.code,
      message: event.message,
    ));
  }

  @override
  Future<void> close() {
    paymentService.dispose();
    return super.close();
  }
}
```

### 5.4 Payment Error Handling

```dart
// Common Razorpay error codes

String getPaymentErrorMessage(int code) {
  switch (code) {
    case 0:
      return 'Network error. Please check your connection.';
    case 1:
      return 'Payment cancelled by user.';
    case 2:
      return 'Payment failed. Please try again.';
    case 3:
      return 'TLS error. Please update your app.';
    default:
      return 'Payment failed. Please try again.';
  }
}
```

---

## 6. Cash on Delivery (COD)

### 6.1 COD Flow

```
1. User selects COD at checkout
2. Backend creates order with status 'pending'
3. Order confirmation shown (no Razorpay involved)
4. Order marked 'confirmed' automatically
5. Payment collected on delivery
6. Delivery agent updates status to 'delivered' + 'paid'
```

### 6.2 COD Restrictions

| Rule | Value |
|------|-------|
| Minimum order value | ₹0 |
| Maximum order value | ₹5,000 |
| COD charge | ₹40 |
| Available PIN codes | Check serviceability API |

### 6.3 COD Implementation

```javascript
// Backend
async function createCODOrder(orderData) {
  const order = await createOrder({
    ...orderData,
    paymentMethod: 'cod',
    paymentStatus: 'pending',
    status: 'confirmed', // Auto-confirm COD orders
    deliveryCharge: orderData.deliveryCharge + 40, // Add COD charge
  });

  return order;
}
```

---

## 7. Price Calculation

### 7.1 Order Total Calculation

```javascript
function calculateOrderTotal(cart, coupon, deliveryPinCode, paymentMethod) {
  // 1. Calculate subtotal
  let subtotal = cart.items.reduce((sum, item) => {
    return sum + (item.variant.price * item.quantity);
  }, 0);

  // 2. Apply coupon discount
  let discount = 0;
  if (coupon) {
    if (coupon.discountType === 'percentage') {
      discount = (subtotal * coupon.discountValue) / 100;
      if (coupon.maxDiscount) {
        discount = Math.min(discount, coupon.maxDiscount);
      }
    } else {
      discount = coupon.discountValue;
    }
  }

  // 3. Calculate delivery charge
  let deliveryCharge = 0;
  const subtotalAfterDiscount = subtotal - discount;

  if (subtotalAfterDiscount < 499) {
    deliveryCharge = 49; // Standard delivery charge
  }

  // 4. Add COD charge if applicable
  if (paymentMethod === 'cod') {
    deliveryCharge += 40;
  }

  // 5. Calculate tax (GST 5% on food products)
  const taxableAmount = subtotalAfterDiscount;
  const tax = Math.round(taxableAmount * 0.05 * 100) / 100;

  // 6. Calculate total
  const total = subtotalAfterDiscount + deliveryCharge + tax;

  return {
    subtotal: Math.round(subtotal * 100) / 100,
    discount: Math.round(discount * 100) / 100,
    deliveryCharge: Math.round(deliveryCharge * 100) / 100,
    tax: Math.round(tax * 100) / 100,
    total: Math.round(total * 100) / 100,
  };
}
```

---

## 8. Testing

### 8.1 Test Cards

| Card Number | Behavior |
|-------------|----------|
| 4111 1111 1111 1111 | Success |
| 4000 0000 0000 0002 | Failure |

**Test UPI:** `success@razorpay`

### 8.2 Test Mode

```dart
// Use test key in development
const razorpayKey = kDebugMode
  ? 'rzp_test_xxxxxxxxxxxx'
  : 'rzp_live_xxxxxxxxxxxx';
```

### 8.3 Testing Checklist

- [ ] UPI payment success
- [ ] Card payment success
- [ ] Payment failure handling
- [ ] Payment cancellation handling
- [ ] Network error during payment
- [ ] Webhook delivery (use Razorpay dashboard)
- [ ] Refund processing
- [ ] COD order creation
- [ ] Order total calculation accuracy

---

## 9. Security Considerations

### 9.1 Must Follow

1. **Never expose API Secret** in client code
2. **Always verify signature** on server before confirming
3. **Use webhooks** as backup verification
4. **Log all transactions** for audit
5. **Implement idempotency** in webhook handlers
6. **Use HTTPS** for all API calls
7. **Validate amounts** on server side

### 9.2 Fraud Prevention

- Limit COD to verified users
- Implement velocity checks (max orders per day)
- Flag suspicious patterns
- Review high-value orders manually

---

## 10. Monitoring & Alerts

### 10.1 Metrics to Track

- Payment success rate
- Average payment time
- Popular payment methods
- Failed payment reasons
- Refund rate

### 10.2 Alerts

- Payment success rate drops below 95%
- High number of payment failures
- Webhook delivery failures
- Unusual transaction patterns

---

*Document maintained by: Gongura-Griha Development Team*
