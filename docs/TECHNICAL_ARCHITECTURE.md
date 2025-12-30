# Gongura-Griha: Technical Architecture

> **Document Status:** Sacred - Must be followed for all implementation decisions
> **Version:** 1.0.0
> **Last Updated:** December 2024

---

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│    ┌──────────────────┐         ┌──────────────────┐                        │
│    │   Android App    │         │     iOS App      │                        │
│    │    (Flutter)     │         │    (Flutter)     │                        │
│    └────────┬─────────┘         └────────┬─────────┘                        │
│             │                            │                                   │
│             └────────────┬───────────────┘                                   │
│                          │                                                   │
└──────────────────────────┼───────────────────────────────────────────────────┘
                           │ HTTPS/REST API
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              API GATEWAY                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│    ┌─────────────────────────────────────────────────────────────────┐      │
│    │                    API Gateway / Load Balancer                   │      │
│    │                    (Rate Limiting, SSL, Routing)                 │      │
│    └─────────────────────────────────────────────────────────────────┘      │
└──────────────────────────┬───────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           APPLICATION LAYER                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│    ┌───────────────┐  ┌───────────────┐  ┌───────────────┐                  │
│    │  Auth Service │  │ Product Svc   │  │  Order Svc    │                  │
│    │               │  │               │  │               │                  │
│    └───────────────┘  └───────────────┘  └───────────────┘                  │
│                                                                              │
│    ┌───────────────┐  ┌───────────────┐  ┌───────────────┐                  │
│    │ Payment Svc   │  │ Notification  │  │  User Svc     │                  │
│    │               │  │    Service    │  │               │                  │
│    └───────────────┘  └───────────────┘  └───────────────┘                  │
│                                                                              │
└──────────────────────────┬───────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                             DATA LAYER                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│    ┌───────────────┐  ┌───────────────┐  ┌───────────────┐                  │
│    │  PostgreSQL   │  │    Redis      │  │  AWS S3 /     │                  │
│    │  (Primary DB) │  │   (Cache)     │  │  Cloudinary   │                  │
│    └───────────────┘  └───────────────┘  └───────────────┘                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         EXTERNAL SERVICES                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│    ┌───────────────┐  ┌───────────────┐  ┌───────────────┐                  │
│    │   Razorpay    │  │   Firebase    │  │  SMS Gateway  │                  │
│    │   (Payments)  │  │  (FCM, Auth)  │  │  (MSG91)      │                  │
│    └───────────────┘  └───────────────┘  └───────────────┘                  │
│                                                                              │
│    ┌───────────────┐  ┌───────────────┐                                     │
│    │   SendGrid    │  │  Google Maps  │                                     │
│    │   (Email)     │  │   (Geocoding) │                                     │
│    └───────────────┘  └───────────────┘                                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Mobile Application Architecture (Flutter)

### 2.1 Flutter Architecture Pattern: Clean Architecture + BLoC

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                    │
│    │   Screens   │    │   Widgets   │    │    BLoCs    │                    │
│    │   (Pages)   │◄───│ (Components)│◄───│   (State)   │                    │
│    └─────────────┘    └─────────────┘    └──────┬──────┘                    │
│                                                  │                           │
└──────────────────────────────────────────────────┼───────────────────────────┘
                                                   │
                                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DOMAIN LAYER                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                    │
│    │   Entities  │    │  Use Cases  │    │ Repositories│                    │
│    │  (Models)   │    │  (Business  │    │ (Interfaces)│                    │
│    │             │    │   Logic)    │    │             │                    │
│    └─────────────┘    └─────────────┘    └──────┬──────┘                    │
│                                                  │                           │
└──────────────────────────────────────────────────┼───────────────────────────┘
                                                   │
                                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            DATA LAYER                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                    │
│    │ Repositories│    │ Data Sources│    │   Models    │                    │
│    │   (Impl)    │◄───│  (API/Local)│◄───│   (DTOs)    │                    │
│    └─────────────┘    └─────────────┘    └─────────────┘                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Project Structure

```
lib/
├── main.dart                      # App entry point
├── app/
│   ├── app.dart                   # App widget
│   ├── routes.dart                # Route definitions
│   └── theme.dart                 # App theme
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart     # API endpoints
│   │   ├── app_constants.dart     # App constants
│   │   └── storage_keys.dart      # Local storage keys
│   │
│   ├── errors/
│   │   ├── exceptions.dart        # Custom exceptions
│   │   └── failures.dart          # Failure classes
│   │
│   ├── network/
│   │   ├── api_client.dart        # HTTP client (Dio)
│   │   ├── api_interceptors.dart  # Request/Response interceptors
│   │   └── network_info.dart      # Connectivity checker
│   │
│   ├── utils/
│   │   ├── validators.dart        # Input validators
│   │   ├── formatters.dart        # Date, currency formatters
│   │   └── helpers.dart           # Utility functions
│   │
│   └── di/
│       └── injection.dart         # Dependency injection (GetIt)
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login.dart
│   │   │       ├── register.dart
│   │   │       └── logout.dart
│   │   │
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   ├── register_page.dart
│   │       │   └── otp_page.dart
│   │       └── widgets/
│   │           ├── phone_input.dart
│   │           └── otp_input.dart
│   │
│   ├── products/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── cart/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── orders/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── checkout/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── home/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── shared/
    ├── widgets/
    │   ├── buttons/
    │   ├── inputs/
    │   ├── cards/
    │   └── dialogs/
    └── extensions/
        ├── context_extensions.dart
        └── string_extensions.dart
```

### 2.3 State Management: BLoC Pattern

```dart
// Example: Cart BLoC

// Events
abstract class CartEvent {}
class AddToCart extends CartEvent { final Product product; }
class RemoveFromCart extends CartEvent { final String productId; }
class UpdateQuantity extends CartEvent { final String productId; final int qty; }
class ClearCart extends CartEvent {}

// States
abstract class CartState {}
class CartInitial extends CartState {}
class CartLoading extends CartState {}
class CartLoaded extends CartState { final Cart cart; }
class CartError extends CartState { final String message; }

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  final AddToCartUseCase addToCart;
  final RemoveFromCartUseCase removeFromCart;
  // ... use cases injected via DI
}
```

---

## 3. Backend Architecture

### 3.1 API Architecture (Node.js + Express)

```
backend/
├── src/
│   ├── index.js                   # Entry point
│   ├── app.js                     # Express app setup
│   │
│   ├── config/
│   │   ├── database.js            # DB connection
│   │   ├── redis.js               # Redis connection
│   │   ├── razorpay.js            # Razorpay config
│   │   └── firebase.js            # Firebase config
│   │
│   ├── routes/
│   │   ├── index.js               # Route aggregator
│   │   ├── auth.routes.js
│   │   ├── product.routes.js
│   │   ├── cart.routes.js
│   │   ├── order.routes.js
│   │   ├── user.routes.js
│   │   └── payment.routes.js
│   │
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   ├── product.controller.js
│   │   ├── cart.controller.js
│   │   ├── order.controller.js
│   │   ├── user.controller.js
│   │   └── payment.controller.js
│   │
│   ├── services/
│   │   ├── auth.service.js
│   │   ├── product.service.js
│   │   ├── cart.service.js
│   │   ├── order.service.js
│   │   ├── payment.service.js
│   │   ├── notification.service.js
│   │   └── sms.service.js
│   │
│   ├── models/
│   │   ├── user.model.js
│   │   ├── product.model.js
│   │   ├── category.model.js
│   │   ├── cart.model.js
│   │   ├── order.model.js
│   │   ├── address.model.js
│   │   └── review.model.js
│   │
│   ├── middlewares/
│   │   ├── auth.middleware.js     # JWT verification
│   │   ├── error.middleware.js    # Error handling
│   │   ├── validate.middleware.js # Request validation
│   │   └── rateLimit.middleware.js
│   │
│   ├── validators/
│   │   ├── auth.validator.js
│   │   ├── product.validator.js
│   │   └── order.validator.js
│   │
│   ├── utils/
│   │   ├── apiResponse.js         # Standard response format
│   │   ├── apiError.js            # Custom error class
│   │   ├── asyncHandler.js        # Async wrapper
│   │   └── helpers.js
│   │
│   └── jobs/
│       ├── orderReminder.job.js
│       └── abandonedCart.job.js
│
├── tests/
├── package.json
└── .env.example
```

### 3.2 API Design Principles

1. **RESTful Conventions**
   - Use nouns for resources (`/products`, `/orders`)
   - Use HTTP methods correctly (GET, POST, PUT, DELETE)
   - Use proper status codes

2. **Versioning**
   - URL versioning: `/api/v1/products`

3. **Response Format**
```json
{
  "success": true,
  "message": "Products fetched successfully",
  "data": {
    "products": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

4. **Error Format**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

---

## 4. Database Architecture

### 4.1 PostgreSQL Schema Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│     users       │     │    addresses    │     │    products     │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ id              │────<│ user_id         │     │ id              │
│ name            │     │ name            │     │ name            │
│ email           │     │ phone           │     │ description     │
│ phone           │     │ address_line1   │     │ price           │
│ password_hash   │     │ city            │     │ category_id     │>───┐
│ created_at      │     │ state           │     │ images          │    │
└─────────────────┘     │ pin_code        │     │ stock           │    │
                        └─────────────────┘     └─────────────────┘    │
                                                                        │
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐    │
│   categories    │<────│  product_variants│    │     orders      │    │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤    │
│ id              │     │ id              │     │ id              │    │
│ name            │     │ product_id      │     │ user_id         │    │
│ image           │     │ name            │     │ address_id      │    │
│ parent_id       │     │ price           │     │ status          │    │
└─────────────────┘     │ stock           │     │ total           │    │
        ▲               └─────────────────┘     │ payment_id      │    │
        │                                       └─────────────────┘    │
        │                                               │              │
        └───────────────────────────────────────────────┴──────────────┘
                                                        │
┌─────────────────┐     ┌─────────────────┐            │
│   order_items   │     │     reviews     │            │
├─────────────────┤     ├─────────────────┤            │
│ id              │     │ id              │            │
│ order_id        │>────│ user_id         │            │
│ product_id      │     │ product_id      │>───────────┘
│ variant_id      │     │ rating          │
│ quantity        │     │ comment         │
│ price           │     │ created_at      │
└─────────────────┘     └─────────────────┘

┌─────────────────┐     ┌─────────────────┐
│      cart       │     │   cart_items    │
├─────────────────┤     ├─────────────────┤
│ id              │────<│ cart_id         │
│ user_id         │     │ product_id      │
│ created_at      │     │ variant_id      │
│ updated_at      │     │ quantity        │
└─────────────────┘     └─────────────────┘
```

---

## 5. Caching Strategy

### 5.1 Redis Cache Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                       CACHE STRATEGY                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   LAYER 1: Application Cache (Redis)                            │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │ • Product catalog (TTL: 1 hour)                         │   │
│   │ • Category list (TTL: 6 hours)                          │   │
│   │ • User sessions (TTL: 7 days)                           │   │
│   │ • OTP codes (TTL: 5 minutes)                            │   │
│   │ • Rate limiting counters                                 │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   LAYER 2: CDN Cache (CloudFront/Cloudflare)                    │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │ • Product images                                         │   │
│   │ • Static assets                                          │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   LAYER 3: Client Cache (Flutter)                               │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │ • Product catalog (Hive/SQLite)                         │   │
│   │ • User preferences                                       │   │
│   │ • Cart (local storage)                                   │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Cache Invalidation

| Data Type | Invalidation Trigger |
|-----------|---------------------|
| Products | Admin update, stock change |
| Categories | Admin update |
| User Session | Logout, password change |
| Cart | User action, checkout |
| Orders | Status change |

---

## 6. Security Architecture

### 6.1 Authentication Flow

```
┌─────────┐         ┌─────────┐         ┌─────────┐         ┌─────────┐
│  User   │         │   App   │         │   API   │         │   DB    │
└────┬────┘         └────┬────┘         └────┬────┘         └────┬────┘
     │                   │                   │                   │
     │  Enter Phone      │                   │                   │
     │──────────────────>│                   │                   │
     │                   │  POST /auth/otp   │                   │
     │                   │──────────────────>│                   │
     │                   │                   │  Generate OTP     │
     │                   │                   │──────────────────>│
     │                   │                   │                   │
     │                   │                   │  Send SMS         │
     │                   │                   │──────────────────>│
     │                   │                   │                   │
     │  Receive OTP      │                   │                   │
     │<──────────────────│                   │                   │
     │                   │                   │                   │
     │  Enter OTP        │                   │                   │
     │──────────────────>│                   │                   │
     │                   │ POST /auth/verify │                   │
     │                   │──────────────────>│                   │
     │                   │                   │  Verify OTP       │
     │                   │                   │──────────────────>│
     │                   │                   │                   │
     │                   │  JWT Token        │                   │
     │                   │<──────────────────│                   │
     │                   │                   │                   │
     │  Logged In        │                   │                   │
     │<──────────────────│                   │                   │
     │                   │                   │                   │
```

### 6.2 JWT Token Structure

```javascript
// Access Token (short-lived: 15 minutes)
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "userId": "uuid",
    "phone": "+91XXXXXXXXXX",
    "type": "access",
    "iat": 1234567890,
    "exp": 1234568790
  }
}

// Refresh Token (long-lived: 7 days)
{
  "payload": {
    "userId": "uuid",
    "type": "refresh",
    "iat": 1234567890,
    "exp": 1235172690
  }
}
```

---

## 7. Payment Architecture

### 7.1 Payment Flow with Razorpay

```
┌─────────┐         ┌─────────┐         ┌─────────┐         ┌─────────┐
│  User   │         │   App   │         │   API   │         │Razorpay │
└────┬────┘         └────┬────┘         └────┬────┘         └────┬────┘
     │                   │                   │                   │
     │  Checkout         │                   │                   │
     │──────────────────>│                   │                   │
     │                   │  Create Order     │                   │
     │                   │──────────────────>│                   │
     │                   │                   │  Create Order     │
     │                   │                   │──────────────────>│
     │                   │                   │                   │
     │                   │                   │  Order ID         │
     │                   │                   │<──────────────────│
     │                   │  Order Details    │                   │
     │                   │<──────────────────│                   │
     │                   │                   │                   │
     │                   │  Open Razorpay    │                   │
     │                   │  Checkout         │                   │
     │                   │──────────────────────────────────────>│
     │                   │                   │                   │
     │  Complete Payment │                   │                   │
     │──────────────────────────────────────────────────────────>│
     │                   │                   │                   │
     │                   │  Payment Response │                   │
     │                   │<──────────────────────────────────────│
     │                   │                   │                   │
     │                   │  Verify Payment   │                   │
     │                   │──────────────────>│                   │
     │                   │                   │  Verify Signature │
     │                   │                   │──────────────────>│
     │                   │                   │                   │
     │                   │                   │  Confirmed        │
     │                   │                   │<──────────────────│
     │                   │  Order Confirmed  │                   │
     │                   │<──────────────────│                   │
     │  Success          │                   │                   │
     │<──────────────────│                   │                   │
```

---

## 8. Notification Architecture

### 8.1 Push Notification Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    NOTIFICATION SYSTEM                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────┐    ┌─────────────────┐                    │
│   │  Order Service  │───>│  Notification   │                    │
│   │  Payment Service│    │    Service      │                    │
│   │  Admin Action   │    │                 │                    │
│   └─────────────────┘    └────────┬────────┘                    │
│                                   │                              │
│                                   ▼                              │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Message Queue                         │   │
│   │                    (Redis/Bull)                          │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                   │                              │
│           ┌───────────────────────┼───────────────────────┐     │
│           ▼                       ▼                       ▼     │
│   ┌───────────────┐       ┌───────────────┐       ┌───────────┐ │
│   │    Firebase   │       │  SMS Gateway  │       │  Email    │ │
│   │     (FCM)     │       │   (MSG91)     │       │ (SendGrid)│ │
│   └───────────────┘       └───────────────┘       └───────────┘ │
│           │                       │                       │     │
│           ▼                       ▼                       ▼     │
│   ┌───────────────┐       ┌───────────────┐       ┌───────────┐ │
│   │  Mobile Push  │       │     SMS       │       │   Email   │ │
│   │ Notification  │       │   Message     │       │   Inbox   │ │
│   └───────────────┘       └───────────────┘       └───────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 8.2 Notification Types

| Event | Push | SMS | Email |
|-------|------|-----|-------|
| Order Placed | ✓ | ✓ | ✓ |
| Order Shipped | ✓ | ✓ | - |
| Order Delivered | ✓ | ✓ | - |
| Payment Failed | ✓ | ✓ | ✓ |
| Promotional | ✓ | - | ✓ |
| Abandoned Cart | ✓ | - | ✓ |

---

## 9. Deployment Architecture

### 9.1 Cloud Infrastructure (AWS/GCP)

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLOUD INFRASTRUCTURE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                     CDN (CloudFront)                     │   │
│   │              Static Assets, Product Images               │   │
│   └─────────────────────────────────────────────────────────┘   │
│                               │                                  │
│                               ▼                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │              Load Balancer (ALB/NLB)                     │   │
│   │                   SSL Termination                        │   │
│   └─────────────────────────────────────────────────────────┘   │
│                               │                                  │
│                               ▼                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                  Container Cluster                       │   │
│   │                  (ECS/EKS/GKE)                           │   │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │   │
│   │  │  API Pod 1  │  │  API Pod 2  │  │  API Pod 3  │      │   │
│   │  └─────────────┘  └─────────────┘  └─────────────┘      │   │
│   └─────────────────────────────────────────────────────────┘   │
│                               │                                  │
│           ┌───────────────────┼───────────────────┐             │
│           ▼                   ▼                   ▼             │
│   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐    │
│   │  PostgreSQL   │   │    Redis      │   │      S3       │    │
│   │    (RDS)      │   │ (ElastiCache) │   │   (Storage)   │    │
│   └───────────────┘   └───────────────┘   └───────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 10. Technology Stack Summary

### 10.1 Mobile Application
| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| State Management | flutter_bloc |
| DI | get_it + injectable |
| HTTP Client | dio |
| Local Storage | hive, shared_preferences |
| Navigation | go_router |
| Forms | flutter_form_builder |
| Images | cached_network_image |
| Payments | razorpay_flutter |

### 10.2 Backend
| Component | Technology |
|-----------|------------|
| Runtime | Node.js 20.x LTS |
| Framework | Express.js 4.x |
| Database | PostgreSQL 15 |
| ORM | Prisma |
| Cache | Redis 7.x |
| Queue | Bull (Redis-based) |
| Validation | Joi / Zod |
| Auth | jsonwebtoken, bcrypt |
| File Upload | multer + S3 |

### 10.3 DevOps & Infrastructure
| Component | Technology |
|-----------|------------|
| Cloud | AWS / GCP / DigitalOcean |
| Containers | Docker |
| Orchestration | ECS / Kubernetes |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus + Grafana |
| Logging | ELK Stack / CloudWatch |
| APM | New Relic / Datadog |

### 10.4 External Services
| Service | Provider |
|---------|----------|
| Payments | Razorpay |
| Push Notifications | Firebase Cloud Messaging |
| SMS | MSG91 / Twilio |
| Email | SendGrid / AWS SES |
| Analytics | Firebase Analytics |
| Crash Reporting | Firebase Crashlytics |
| Maps | Google Maps |

---

*Document maintained by: Gongura-Griha Development Team*
