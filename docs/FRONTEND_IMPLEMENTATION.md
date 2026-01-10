# Frontend Implementation Guide

> **Last Updated:** January 2026
> **Status:** Phase 1 Complete - UI Implementation
> **Flutter Version:** 3.x
> **Architecture:** Feature-First with Presentation Layer

This document serves as the **source of truth** for the Gongura Griha frontend implementation. All screens, components, and integrations are documented here.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Navigation System](#navigation-system)
3. [Screen Implementations](#screen-implementations)
4. [Shared Components](#shared-components)
5. [Theme System](#theme-system)
6. [Localization](#localization)
7. [Data Layer](#data-layer)
8. [Assets](#assets)

---

## Architecture Overview

### Project Structure

```
lib/
├── app/
│   ├── app.dart                    # App widget with MaterialApp
│   ├── routes.dart                 # GoRouter configuration
│   └── theme/
│       ├── app_colors.dart         # Color constants
│       ├── app_text_styles.dart    # Text style constants
│       └── app_typography.dart     # Typography definitions
├── core/
│   └── utils/
│       ├── formatters.dart         # Currency, date formatters
│       └── validators.dart         # Input validation
├── features/
│   ├── address/                    # Address management
│   ├── auth/                       # Authentication screens
│   ├── cart/                       # Cart & checkout
│   ├── home/                       # Home screen
│   ├── legal/                      # Terms, Privacy
│   ├── notifications/              # Notifications
│   ├── onboarding/                 # Onboarding flow
│   ├── orders/                     # Orders management
│   ├── payment/                    # Payment methods
│   ├── products/                   # Product list & detail
│   ├── profile/                    # User profile
│   ├── search/                     # Search functionality
│   ├── settings/                   # App settings
│   ├── splash/                     # Splash screen
│   ├── support/                    # Help & About
│   └── wishlist/                   # Wishlist
├── l10n/
│   ├── app_en.arb                  # English translations
│   ├── app_hi.arb                  # Hindi translations
│   └── app_te.arb                  # Telugu translations
└── shared/
    └── widgets/
        ├── buttons/
        │   └── primary_button.dart
        ├── cards/
        │   ├── category_card.dart
        │   └── product_card.dart
        └── inputs/
            ├── app_text_field.dart
            └── custom_text_field.dart
```

### State Management

- **Current:** `StatefulWidget` with local state
- **Pattern:** Presentation layer handles state directly
- **Data:** Mock/hardcoded data in presentation layer

### Key Dependencies

- `go_router`: Navigation & routing
- `flutter_localizations`: Internationalization
- `cached_network_image`: Image caching
- `url_launcher`: External links

---

## Navigation System

### Router Configuration

**File:** `lib/app/routes.dart`

The app uses GoRouter with a ShellRoute for bottom navigation persistence.

### Route Definitions

| Route | Path | Screen | Notes |
|-------|------|--------|-------|
| Splash | `/` | SplashScreen | Entry point |
| Onboarding | `/onboarding` | OnboardingScreen | First-time users |
| Login | `/login` | LoginScreen | Phone-based auth |
| OTP | `/otp` | OtpScreen | OTP verification |
| Register | `/register` | RegisterScreen | User registration |
| Home | `/home` | HomeScreen | Main screen (ShellRoute) |
| Products | `/products` | ProductListScreen | Query param: `?category=` |
| Product Detail | `/product/:slug` | ProductDetailScreen | Dynamic slug |
| Cart | `/cart` | CartScreen | ShellRoute |
| Checkout | `/checkout` | CheckoutScreen | Outside shell |
| Order Success | `/order-success` | OrderSuccessScreen | Confirmation |
| Orders | `/orders` | OrdersScreen | ShellRoute |
| Order Detail | `/order/:orderNumber` | OrderDetailScreen | Dynamic orderNumber |
| Wishlist | `/wishlist` | WishlistScreen | ShellRoute |
| Profile | `/profile` | ProfileScreen | ShellRoute |
| Edit Profile | `/profile/edit` | EditProfileScreen | |
| Addresses | `/addresses` | AddressListScreen | |
| Add Address | `/addresses/add` | AddAddressScreen | |
| Edit Address | `/addresses/edit/:id` | EditAddressScreen | Dynamic id |
| Search | `/search` | SearchScreen | |
| Notifications | `/notifications` | NotificationsScreen | |
| Help | `/help` | HelpSupportScreen | |
| About | `/about` | AboutScreen | |
| Payment Methods | `/payment-methods` | PaymentMethodsScreen | |
| Language | `/language` | LanguageScreen | |
| Terms | `/terms-conditions` | TermsConditionsScreen | |
| Privacy | `/privacy-policy` | PrivacyPolicyScreen | |

### Bottom Navigation

The app uses a ShellRoute with 4 main destinations:
1. **Home** - Home, Products, Product Detail, Cart
2. **Orders** - Orders list, Order detail
3. **Wishlist** - Saved products
4. **Profile** - User settings

### Route Helpers

```dart
// Get product detail route
AppRoutes.getProductDetailRoute(String slug) => '/product/$slug'

// Get order detail route
AppRoutes.getOrderDetailRoute(String orderNumber) => '/order/$orderNumber'

// Get edit address route
AppRoutes.getEditAddressRoute(String id) => '/addresses/edit/$id'
```

---

## Screen Implementations

### 1. Splash Screen

**File:** `lib/features/splash/presentation/screens/splash_screen.dart`

**Description:** App entry point with branding animation.

**Components:**
- App logo (eco icon with gradient background)
- App name with tagline
- Loading indicator

**Behavior:**
- Displays for 2 seconds
- Auto-navigates to onboarding or home

**Integration:**
- Initial route in GoRouter (`/`)

---

### 2. Onboarding Screen

**File:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

**Description:** First-time user experience with swipeable pages.

**Components:**
- PageView with 3 onboarding pages
- Page indicator dots
- Skip button
- Get Started button

**Behavior:**
- Swipeable pages with illustrations
- Can skip to end
- Navigates to login on completion

---

### 3. Login Screen

**File:** `lib/features/auth/presentation/screens/login_screen.dart`

**Description:** Phone-based OTP authentication.

**Components:**
- Phone number input with country code (+91)
- Continue button
- Terms acceptance text

**Validation:**
- Uses `Validators.validatePhone()`
- 10-digit phone number required

**Integration:**
- Navigates to OTP screen on success
- Passes phone number as route extra

---

### 4. Home Screen

**File:** `lib/features/home/presentation/screens/home_screen.dart`

**Description:** Main landing screen with product discovery.

**Components:**
- **Header Section:**
  - Location with "Deliver to" label
  - Notification bell (badge shows count)
  - Cart icon (badge shows count)
- **Search Bar:** Tappable, navigates to search screen
- **Banner Carousel:**
  - 3 promotional banners
  - Auto-play with 4-second interval
  - Page indicators
  - Localized titles/subtitles
- **Categories Grid:**
  - 3 categories: Pachadi, Chutney, Powder
  - Icon + label for each
  - Navigates to filtered product list
- **Featured Products:**
  - "View All" link
  - 3 products in horizontal scroll
  - ProductCard widget usage

**Data Structure:**
```dart
// Categories
[
  {'name': l10n.pachadi, 'icon': Icons.rice_bowl, 'key': 'Pachadi'},
  {'name': l10n.chutney, 'icon': Icons.blender, 'key': 'Chutney'},
  {'name': l10n.powder, 'icon': Icons.grain, 'key': 'Powder'},
]

// Featured Products
[
  {
    'name': l10n.traditionalGonguraPachadi,
    'image': 'assets/images/GonguraPickle.png',
    'price': 199.0,
    'slug': 'traditional-gongura-pachadi',
    'isAsset': true,
  },
  // ... chutney and podi
]
```

---

### 5. Product List Screen

**File:** `lib/features/products/presentation/screens/product_list_screen.dart`

**Description:** Grid display of all products with filtering.

**Components:**
- AppBar with filter button
- Grid view of ProductCards
- Filter/Sort bottom sheet

**Features:**
- **Sorting Options:**
  - Most Popular
  - Name: A to Z
  - Price: Low to High
  - Price: High to Low
- **Filters:**
  - Veg Only toggle
  - Price Range slider

**Query Parameters:**
- `?category=pachadi|chutney|powder` - Filter by category

**Integration:**
- Receives optional `category` parameter
- Uses `ProductCard` shared widget

---

### 6. Product Detail Screen

**File:** `lib/features/products/presentation/screens/product_detail_screen.dart`

**Description:** Full product details with purchase options.

**Components:**
- **SliverAppBar:** Product image with parallax
- **Size Selector:** 3 size options with leaf icons
- **Highlights Section:** Product features
- **Ingredients Section:** List with icons
- **Nutrition Info:** Expandable section
- **Quantity Selector:** With leaf icons
- **Add to Cart Button:** Bottom sticky

**Product Data:**
```dart
// 3 Products
'traditional-gongura-pachadi' -> Traditional Gongura Pachadi
'classic-gongura-chutney'     -> Classic Gongura Chutney
'spicy-gongura-podi'          -> Spicy Gongura Podi

// Size Options (per product)
Small:  250g - Base price
Medium: 500g - Higher price
Large:  1kg  - Highest price

// Quantity Limits per Size
Small:  max 2
Medium: max 4
Large:  max 5
```

**Size Icons:**
- Small: `Icons.eco`
- Medium: `Icons.nature`
- Large: `Icons.forest`

---

### 7. Cart Screen

**File:** `lib/features/cart/presentation/screens/cart_screen.dart`

**Description:** Shopping cart with order summary.

**Components:**
- **Cart Items List:**
  - Product image
  - Name, size, price
  - Quantity controls with leaf icons
  - Remove option
- **Free Delivery Banner:** Shows threshold (Rs.499)
- **Coupon Section:**
  - Enter code input
  - Available coupons list
- **Bill Details:**
  - Item Total
  - Coupon Discount (if applied)
  - Delivery charges
  - Total to pay
- **Checkout Button:** Bottom sticky

**Business Logic:**
- Free delivery for orders >= Rs.499
- Size-based quantity limits enforced
- Coupon validation

**Available Coupons:**
- `GONGURA20`: 20% off (min Rs.500)
- `FIRST50`: Rs.50 off first order
- `FREESHIP`: Free delivery (min Rs.299)

---

### 8. Checkout Screen

**File:** `lib/features/cart/presentation/screens/checkout_screen.dart`

**Description:** Order completion flow.

**Components:**
- **Address Selection:**
  - Saved addresses list
  - Add new address option
  - Selected address indicator
- **Delivery Time:** Estimated delivery display
- **Payment Methods:**
  - UPI (Google Pay, PhonePe, Paytm)
  - Credit/Debit Card
  - Cash on Delivery
- **Order Summary:** Items and totals
- **Place Order Button:** Bottom sticky

**Integration:**
- Navigates to Order Success on completion

---

### 9. Orders Screen

**File:** `lib/features/orders/presentation/screens/orders_screen.dart`

**Description:** Order history with status tracking.

**Components:**
- **TabBar:**
  - Active orders (with count)
  - Past orders (with count)
- **Order Cards:**
  - Order number
  - Order date (relative time)
  - Status badge (with icon & color)
  - Progress bar (for active orders)
  - Items preview (max 2 shown)
  - Total amount
  - Expected/Delivered date

**Order Statuses:**
| Status | Color | Icon |
|--------|-------|------|
| Processing | Warning | access_time |
| Shipped | Info | local_shipping |
| Delivered | Success | check_circle |
| Cancelled | Error | cancel |

**Progress Bar Stages:**
1. Placed
2. Confirmed
3. Preparing
4. Shipped
5. Delivered

---

### 10. Order Detail Screen

**File:** `lib/features/orders/presentation/screens/order_detail_screen.dart`

**Description:** Detailed order information and tracking.

**Components:**
- **Status Card:** Current status with icon
- **Tracking Timeline:** Vertical progress with timestamps
- **Items Section:** Full item list with prices
- **Delivery Address:** Full address details
- **Payment Details:** Method, status, transaction ID
- **Bill Details:** Breakdown of charges
- **Help Section:** Chat, Call, Cancel options

**Data Lookup:**
- Uses `orderNumber` parameter to find order
- Displays "No results" if order not found

---

### 11. Wishlist Screen

**File:** `lib/features/wishlist/presentation/screens/wishlist_screen.dart`

**Description:** Saved products for later.

**Components:**
- **Empty State:**
  - Heart icon
  - "Wishlist is empty" message
  - Discover Products button
- **Wishlist Items:**
  - Product image (full width)
  - Category badge
  - Remove from wishlist button
  - Product name and price
  - Add to cart button

**Behavior:**
- Remove shows snackbar confirmation
- Add button navigates to product detail

---

### 12. Profile Screen

**File:** `lib/features/profile/presentation/screens/profile_screen.dart`

**Description:** User profile and settings hub.

**Components:**
- **Header (SliverAppBar):**
  - Gradient background
  - User avatar (initial)
  - Name and phone
  - Edit button
- **Account Section:**
  - Edit Profile
  - Saved Addresses
  - Payment Methods
- **Orders Section:**
  - My Orders
  - Wishlist
- **Preferences Section:**
  - Notifications (toggle)
  - Language (with current selection)
- **Support Section:**
  - Help & Support
  - About Us
  - Terms & Conditions
  - Privacy Policy
- **Logout Button**
- **App Version**

---

### 13. Search Screen

**File:** `lib/features/search/presentation/screens/search_screen.dart`

**Description:** Product search with suggestions.

**Components:**
- **Search Bar:** Auto-focus, clear button
- **Suggestions View (empty query):**
  - Recent Searches (with clear all)
  - Featured Products (horizontal scroll)
  - Popular Searches (chips)
  - Browse Categories (grid)
  - Quick Filters
- **Search Results:** Product cards list
- **No Results State:** Icon and message

**Search Logic:**
- Searches in: name, category, description
- Case-insensitive matching

---

### 14. Language Screen

**File:** `lib/features/settings/presentation/screens/language_screen.dart`

**Description:** App language selection.

**Components:**
- Info card about language change
- Language list with:
  - Flag emoji
  - English name
  - Native name
  - Selection indicator

**Supported Languages:**
| Code | Name | Native |
|------|------|--------|
| en | English | English |
| hi | Hindi | हिंदी |
| te | Telugu | తెలుగు |

**Behavior:**
- Confirmation dialog on change
- Uses `localeProvider` to update
- Snackbar confirmation

---

### 15. Notifications Screen

**File:** `lib/features/notifications/presentation/screens/notifications_screen.dart`

**Description:** User notifications and updates.

**Components:**
- **AppBar:** "Mark all read" action
- **Notification List:**
  - Type icon (order, promo, info)
  - Title (bold if unread)
  - Message (2 lines max)
  - Time (relative format)
  - Unread indicator dot
- **Swipe to Delete**
- **Empty State**

**Notification Types:**
| Type | Color | Icon |
|------|-------|------|
| order | Primary | local_shipping |
| promo | Accent | local_offer |
| info | Info | info |

---

### 16. About Screen

**File:** `lib/features/support/presentation/screens/about_screen.dart`

**Description:** Company and app information.

**Components:**
- **Header (SliverAppBar):**
  - Gradient background
  - App logo
  - App name and tagline
- **Our Story Section**
- **Why Choose Us:** Feature cards
- **Connect With Us:** Social media links
- **Contact Information:**
  - Address
  - Email (tappable)
  - Phone (tappable)
- **App Version**

**External Links:**
- Uses `url_launcher` for email, phone, social

---

## Shared Components

### ProductCard

**File:** `lib/shared/widgets/cards/product_card.dart`

**Variants:**
1. **ProductCard** - Grid card for product listing
2. **ProductCardHorizontal** - List card for cart

**ProductCard Props:**
```dart
name: String
imageUrl: String
price: double
originalPrice: double?
rating: double?
reviewCount: int?
description: String?
isVeg: bool (default: true)
isWishlisted: bool
isOutOfStock: bool
isAsset: bool (default: false)
onTap: VoidCallback?
onAddToCart: VoidCallback?
onWishlistToggle: VoidCallback?
```

**Features:**
- Gradient background on image
- Wishlist heart button
- Out of stock overlay
- Price with "onwards" label
- Add button with leaf icon

### PrimaryButton

**File:** `lib/shared/widgets/buttons/primary_button.dart`

Standard elevated button with primary color.

### AppTextField / CustomTextField

**Files:** `lib/shared/widgets/inputs/`

Styled text input fields with validation support.

---

## Theme System

### AppColors

**File:** `lib/app/theme/app_colors.dart`

**Primary Palette:**
- Primary: `#2E7D32` (Gongura leaf green)
- Primary Light: `#4CAF50`
- Primary Dark: `#1B5E20`
- Accent: `#FF5722` (Spice orange)

**Background Colors:**
- Background: `#FAFAFA`
- Surface: `#FFFFFF`
- Secondary: `#F5F5F5`

**Text Colors:**
- Primary: `#212121`
- Secondary: `#757575`
- Tertiary: `#BDBDBD`

**Status Colors:**
- Success: `#4CAF50`
- Warning: `#FFC107`
- Error: `#F44336`
- Info: `#2196F3`

**Special Colors:**
- Veg: `#00C853`
- Non-Veg: `#D32F2F`
- UPI: `#00897B`
- Card: `#1565C0`
- COD: `#795548`

### AppTextStyles

**File:** `lib/app/theme/app_text_styles.dart`

Predefined text styles for consistent typography.

### AppTypography

**File:** `lib/app/theme/app_typography.dart`

Additional typography definitions.

---

## Localization

### Setup

**Configuration:** `lib/l10n/`

The app supports 3 languages:
- English (en) - Primary
- Hindi (hi)
- Telugu (te)

### Key Categories

**General:**
- `appName`, `appTagline`
- `home`, `orders`, `wishlist`, `profile`

**Products:**
- `traditionalGonguraPachadi`
- `classicGonguraChutney`
- `spicyGonguraPodi`
- `pachadiDescription`, `chutneyDescription`, `podiDescription`

**Categories:**
- `pachadi`, `chutney`, `powder`

**Actions:**
- `add`, `addToCart`, `shopNow`, `viewAll`
- `checkout`, `placeOrder`, `apply`

**Orders:**
- `orderPlaced`, `orderConfirmed`, `orderPreparing`
- `orderShipped`, `orderDelivered`

**Placeholders:**
```dart
// Dynamic values
l10n.addMoreForFreeDelivery(amount)  // "Add Rs.{amount} more..."
l10n.youSaved(amount)                 // "You saved Rs.{amount}"
l10n.maxQuantityHint(max)             // "Max {max} for this size..."
l10n.productsCount(count)             // "{count} products"
```

### Usage Pattern

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.addToCart)
```

---

## Data Layer

### Current Implementation

All data is currently **mock/hardcoded** in the presentation layer.

**Products Data Location:**
- `home_screen.dart`: Featured products
- `product_list_screen.dart`: All products
- `product_detail_screen.dart`: Full product data with sizes
- `search_screen.dart`: Searchable products

**Orders Data Location:**
- `orders_screen.dart`: Order list
- `order_detail_screen.dart`: Detailed order data

### Product Data Structure

```dart
{
  'slug': 'traditional-gongura-pachadi',
  'name': l10n.traditionalGonguraPachadi,
  'description': l10n.pachadiDescription,
  'image': 'assets/images/GonguraPickle.png',
  'category': 'pachadi',
  'isVeg': true,
  'sizes': [
    {'name': 'Small', 'weight': '250g', 'price': 199.0, 'maxQty': 2},
    {'name': 'Medium', 'weight': '500g', 'price': 349.0, 'maxQty': 4},
    {'name': 'Large', 'weight': '1kg', 'price': 599.0, 'maxQty': 5},
  ],
  'ingredients': [...],
  'highlights': [...],
  'nutrition': {...},
}
```

### Future Backend Integration

Screens are structured to easily accept data from:
- API services
- State management (BLoC/Riverpod)
- Repository pattern

---

## Assets

### Images

**Location:** `assets/images/`

| File | Usage |
|------|-------|
| GonguraPickle.png | Traditional Gongura Pachadi |
| GonguraChutney.png | Classic Gongura Chutney |
| GonguraPowder.png | Spicy Gongura Podi |

### Fonts

Using default Flutter fonts.

### Icons

Material Icons used throughout:
- `Icons.eco` - Leaf/veg indicator
- `Icons.nature` - Medium size
- `Icons.forest` - Large size
- `Icons.favorite` / `favorite_outline` - Wishlist
- `Icons.shopping_cart` - Cart

---

## Summary

### Completed Features

- [x] Complete UI implementation for all screens
- [x] Navigation with GoRouter and bottom nav
- [x] Full localization (EN, HI, TE)
- [x] Theme system with colors and typography
- [x] Product browsing and detail views
- [x] Cart with quantity controls
- [x] Checkout flow
- [x] Order tracking with progress bar
- [x] Wishlist management
- [x] User profile with settings
- [x] Search with suggestions
- [x] Notifications list
- [x] Language selection

### Pending Features (Phase 2)

- [ ] Backend API integration
- [ ] State management (BLoC)
- [ ] User authentication persistence
- [ ] Real order placement
- [ ] Payment gateway integration
- [ ] Push notifications
- [ ] Analytics

---

*This document should be updated whenever new screens or features are added to the frontend.*
