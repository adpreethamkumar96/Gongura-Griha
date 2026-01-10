# Gongura-Griha: Feature Specifications

> **Document Status:** Sacred - Must be followed for all implementation decisions
> **Version:** 1.1.0
> **Last Updated:** January 2026
> **Implementation:** Phase 1 Complete - See [FRONTEND_IMPLEMENTATION.md](./FRONTEND_IMPLEMENTATION.md)

---

## Implementation Status Summary

| Screen | Status | Notes |
|--------|--------|-------|
| Splash Screen | COMPLETE | Navigates to onboarding/home |
| Onboarding | COMPLETE | 3 slides with skip/next |
| Login | UI COMPLETE | Phone + OTP (mock) |
| OTP Verification | UI COMPLETE | Mock verification |
| Registration | UI COMPLETE | Mock registration |
| Home | COMPLETE | Carousel, categories, featured products |
| Product List | COMPLETE | Grid, filters, sorting |
| Product Detail | COMPLETE | Size selector, highlights, nutrition |
| Cart | COMPLETE | Quantity controls, coupons, bill |
| Checkout | UI COMPLETE | Address, payment selection (mock) |
| Order Success | COMPLETE | Confirmation screen |
| Orders List | COMPLETE | Active/Past tabs with progress |
| Order Detail | COMPLETE | Timeline, items, help options |
| Wishlist | COMPLETE | Add/remove, move to cart |
| Profile | COMPLETE | All sections with menu items |
| Edit Profile | UI COMPLETE | Form (mock save) |
| Addresses | UI COMPLETE | List, add, edit (mock) |
| Search | COMPLETE | Suggestions, results, recent |
| Notifications | COMPLETE | List with dismiss |
| Settings/Language | COMPLETE | 3 languages working |
| Help & Support | COMPLETE | FAQ, contact options |
| About | COMPLETE | Story, contact info |
| Terms & Privacy | COMPLETE | Static content |

---

## 1. Splash Screen

### 1.1 Description
Initial screen shown when app launches, displaying brand identity while app initializes.

### 1.2 UI Elements
- Gongura-Griha logo (centered)
- Brand tagline: "Authentic Gongura Delights"
- Loading indicator (subtle)
- Background: Brand primary color or gradient

### 1.3 Behavior
| Condition | Action |
|-----------|--------|
| First launch | Navigate to Onboarding |
| Returning user (logged out) | Navigate to Home |
| Returning user (logged in) | Navigate to Home |
| App update available | Show optional update dialog |
| Force update required | Show mandatory update dialog |

### 1.4 Duration
- Minimum: 1.5 seconds (brand visibility)
- Maximum: 3 seconds (with network check)

---

## 2. Onboarding (First Launch Only)

### 2.1 Description
Introduction slides for first-time users explaining app value proposition.

### 2.2 Screens (3 slides)

**Slide 1: Welcome**
- Image: Product showcase
- Title: "Welcome to Gongura-Griha"
- Subtitle: "Discover authentic gongura pickles from Andhra & Telangana"

**Slide 2: Quality**
- Image: Traditional preparation
- Title: "Handcrafted with Love"
- Subtitle: "Traditional recipes, premium ingredients, no preservatives"

**Slide 3: Convenience**
- Image: Delivery illustration
- Title: "Delivered Fresh to You"
- Subtitle: "Order online, track delivery, taste tradition"

### 2.3 Navigation
- Skip button (top right)
- Page indicators (dots)
- Next/Get Started button
- Swipe gesture for navigation

---

## 3. Authentication

### 3.1 Login Screen

#### UI Elements
```
┌─────────────────────────────────────┐
│                                     │
│         [Gongura-Griha Logo]        │
│                                     │
│          Welcome Back!              │
│    Sign in to continue shopping     │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ +91 │ Mobile Number         │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │      Continue with OTP       │    │
│  └─────────────────────────────┘    │
│                                     │
│          ─── OR ───                 │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  [G] Continue with Google    │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  [] Continue with Apple     │    │  (iOS only)
│  └─────────────────────────────┘    │
│                                     │
│     Don't have an account?          │
│          [Register]                 │
│                                     │
│     [Skip] Continue as guest        │
│                                     │
└─────────────────────────────────────┘
```

#### Validations
| Field | Rule |
|-------|------|
| Phone | 10 digits, starts with 6-9 |
| Country | India only (+91) |

#### Error States
- Invalid phone format
- Network error
- Rate limit exceeded

### 3.2 OTP Verification Screen

#### UI Elements
```
┌─────────────────────────────────────┐
│  [←]                                │
│                                     │
│         Verify Your Number          │
│                                     │
│    We've sent a 6-digit code to     │
│         +91 98765 43210             │
│                                     │
│     ┌───┬───┬───┬───┬───┬───┐      │
│     │ _ │ _ │ _ │ _ │ _ │ _ │      │
│     └───┴───┴───┴───┴───┴───┘      │
│                                     │
│     Didn't receive code?            │
│     [Resend OTP] (in 30s)           │
│                                     │
│  ┌─────────────────────────────┐    │
│  │         Verify              │    │
│  └─────────────────────────────┘    │
│                                     │
│     [Change Number]                 │
│                                     │
└─────────────────────────────────────┘
```

#### Behavior
- Auto-fill OTP from SMS (Android)
- Auto-submit on 6 digits
- Resend timer: 30 seconds
- Max attempts: 3 per session
- OTP expiry: 5 minutes

### 3.3 Registration Screen

#### UI Elements
```
┌─────────────────────────────────────┐
│  [←]                                │
│                                     │
│          Create Account             │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Full Name *                  │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Email Address (optional)     │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ +91 │ Mobile Number *        │    │
│  └─────────────────────────────┘    │
│                                     │
│  ☐ I agree to Terms & Privacy       │
│                                     │
│  ┌─────────────────────────────┐    │
│  │       Create Account         │    │
│  └─────────────────────────────┘    │
│                                     │
│     Already have an account?        │
│            [Login]                  │
│                                     │
└─────────────────────────────────────┘
```

#### Validations
| Field | Rule |
|-------|------|
| Name | 2-50 characters, alphabets & spaces |
| Email | Valid format (optional) |
| Phone | 10 digits, unique |
| Terms | Must be checked |

---

## 4. Home Screen

### 4.1 Description
Main landing screen showing products, categories, and promotions.

### 4.2 UI Structure
```
┌─────────────────────────────────────┐
│  [≡]    Gongura-Griha    [🔍] [🛒] │
├─────────────────────────────────────┤
│ 📍 Deliver to: Hyderabad 500001 [▼]│
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │    🔍 Search for products    │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │     [Banner Carousel]       │    │ ← Promotional banners
│  │      ● ○ ○ ○                │    │
│  └─────────────────────────────┘    │
│                                     │
│  Shop by Category                   │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ 🫙  │ │ 🥫  │ │ 🌶️  │ │ 🎁  │   │
│  │Pickle│ │Chut-│ │Podi │ │Combo│   │
│  │     │ │ney  │ │     │ │     │   │
│  └─────┘ └─────┘ └─────┘ └─────┘   │
│                                     │
│  Best Sellers                [See All]
│  ┌─────────┐ ┌─────────┐ ┌──────   │
│  │  [IMG]  │ │  [IMG]  │ │  [IM    │
│  │ Gongura │ │ Chicken │ │ Mutto   │
│  │ Pickle  │ │ Gongura │ │ Gong    │
│  │ ₹199    │ │ ₹349    │ │ ₹399    │
│  │ [Add]   │ │ [Add]   │ │ [Add    │
│  └─────────┘ └─────────┘ └──────   │
│                                     │
│  New Arrivals                [See All]
│  ┌─────────┐ ┌─────────┐ ┌──────   │
│  │  ...    │ │  ...    │ │  ...    │
│  └─────────┘ └─────────┘ └──────   │
│                                     │
└─────────────────────────────────────┘
│  [🏠]    [📦]    [❤️]    [👤]     │
│  Home   Orders  Wishlist Profile   │
└─────────────────────────────────────┘
```

### 4.3 Sections

| Section | Content | Behavior |
|---------|---------|----------|
| Header | Logo, Search, Cart | Fixed |
| Location | Delivery PIN code | Tappable, opens location picker |
| Search Bar | Search input | Opens search screen |
| Banner Carousel | Promotional images | Auto-scroll (5s), tappable |
| Categories | Category icons | Horizontal scroll, tappable |
| Best Sellers | Top products | Horizontal scroll, "See All" link |
| New Arrivals | Latest products | Horizontal scroll |
| Recommendations | Personalized | Based on history (logged in users) |

### 4.4 Bottom Navigation
| Tab | Icon | Screen |
|-----|------|--------|
| Home | 🏠 | Home screen |
| Orders | 📦 | Order history |
| Wishlist | ❤️ | Saved items |
| Profile | 👤 | User profile |

---

## 5. Product Listing Screen

### 5.1 UI Structure
```
┌─────────────────────────────────────┐
│  [←]     Category Name      [🔍][⚙️]│
├─────────────────────────────────────┤
│  [Filter] [Sort ▼] 24 products      │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────┐  ┌───────────┐       │
│  │   [IMG]   │  │   [IMG]   │       │
│  │  ❤️       │  │  ❤️       │       │
│  │           │  │  🏷️ 20%   │       │
│  ├───────────┤  ├───────────┤       │
│  │ Gongura   │  │ Mutton    │       │
│  │ Classic   │  │ Gongura   │       │
│  │ ★ 4.5 (120)│  │ ★ 4.8 (85)│       │
│  │ ₹199      │  │ ₹̶4̶9̶9̶ ₹399 │       │
│  │  [Add]    │  │  [Add]    │       │
│  └───────────┘  └───────────┘       │
│                                     │
│  ┌───────────┐  ┌───────────┐       │
│  │   ...     │  │   ...     │       │
│  └───────────┘  └───────────┘       │
│                                     │
│         [Load More / Infinite]      │
│                                     │
└─────────────────────────────────────┘
```

### 5.2 Filter Options
```
┌─────────────────────────────────────┐
│  [✕]         Filters                │
├─────────────────────────────────────┤
│                                     │
│  Category                           │
│  ☐ Pickles  ☐ Chutneys  ☐ Powders  │
│                                     │
│  Price Range                        │
│  ○───────────●───────────○          │
│  ₹100                    ₹1000      │
│                                     │
│  Type                               │
│  ☐ Vegetarian  ☐ Non-Vegetarian    │
│                                     │
│  Spice Level                        │
│  ☐ Mild  ☐ Medium  ☐ Hot  ☐ Extra Hot│
│                                     │
│  Size                               │
│  ☐ 250g  ☐ 500g  ☐ 1kg             │
│                                     │
│  Rating                             │
│  ☐ 4★ & above  ☐ 3★ & above        │
│                                     │
│  ┌───────────────────────────────┐  │
│  │      Apply Filters (12)       │  │
│  └───────────────────────────────┘  │
│                                     │
│         [Clear All]                 │
│                                     │
└─────────────────────────────────────┘
```

### 5.3 Sort Options
- Popularity (default)
- Price: Low to High
- Price: High to Low
- Rating: High to Low
- Newest First

---

## 6. Product Detail Screen

### 6.1 UI Structure
```
┌─────────────────────────────────────┐
│  [←]                    [❤️] [📤]   │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │     [Product Image]         │    │
│  │                             │    │
│  │        ● ○ ○ ○              │    │
│  └─────────────────────────────┘    │
│                                     │
│  🥬 VEGETARIAN                      │
│                                     │
│  Gongura Classic Pickle             │
│  Traditional Andhra-style pickle    │
│                                     │
│  ★ 4.5 (120 reviews)                │
│                                     │
│  ₹̶2̶4̶9̶  ₹199  (20% OFF)              │
│  Inclusive of all taxes             │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Select Size                        │
│  ┌──────┐ ┌──────┐ ┌──────┐        │
│  │ 250g │ │ 500g │ │ 1 kg │        │
│  │ ₹199 │ │ ₹349 │ │ ₹649 │        │
│  └──────┘ └──────┘ └──────┘        │
│                                     │
│  Select Spice Level                 │
│  ┌──────┐ ┌──────┐ ┌──────┐        │
│  │ Mild │ │Medium│ │ Hot  │        │
│  └──────┘ └──────┘ └──────┘        │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  📦 Delivery to 500001              │
│     Available by Jan 5, 2025        │
│     FREE delivery on orders ₹499+   │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  ▼ Product Details                  │
│  • 100% Natural ingredients         │
│  • No artificial preservatives      │
│  • Shelf life: 6 months            │
│  • Store in cool, dry place         │
│                                     │
│  ▼ Ingredients                      │
│  Gongura leaves, Red chilies,       │
│  Garlic, Mustard seeds, Oil, Salt   │
│                                     │
│  ▼ Nutritional Info (per 100g)      │
│  Calories: 150 | Protein: 2g        │
│  Fat: 12g | Carbs: 8g               │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Frequently Bought Together         │
│  ┌─────────┐ ┌─────────┐           │
│  │  ...    │ │  ...    │           │
│  └─────────┘ └─────────┘           │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Ratings & Reviews                  │
│  ★★★★★ 4.5 out of 5                │
│  Based on 120 reviews               │
│                                     │
│  ★★★★★ 5   ████████████ 80%        │
│  ★★★★☆ 4   ████        15%         │
│  ★★★☆☆ 3   █           3%          │
│  ★★☆☆☆ 2   ░           1%          │
│  ★☆☆☆☆ 1   ░           1%          │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Rahul S.           Dec 2024 │   │
│  │ ★★★★★                       │   │
│  │ "Authentic taste! Reminds   │   │
│  │  me of my grandmother's     │   │
│  │  pickle. Will order again!" │   │
│  │  [🖼️ Photo]                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  [View All 120 Reviews]             │
│                                     │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐    │
│  │ [-]  1  [+]    Add to Cart  │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

### 6.2 Interactions

| Element | Action |
|---------|--------|
| Images | Swipe carousel, tap to zoom |
| Wishlist (❤️) | Toggle add/remove |
| Share (📤) | Open share sheet |
| Size chips | Select variant |
| Spice chips | Select variant |
| Quantity | Increment/decrement (1-10) |
| Add to Cart | Add with selected options |
| Reviews | Navigate to reviews screen |

---

## 7. Cart Screen

### 7.1 UI Structure
```
┌─────────────────────────────────────┐
│  [←]           Cart            [🗑️] │
├─────────────────────────────────────┤
│                                     │
│  📦 3 items in your cart            │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ┌─────┐                     │    │
│  │ │[IMG]│ Gongura Classic     │    │
│  │ │     │ 500g | Medium       │    │
│  │ └─────┘ ₹349                │    │
│  │                             │    │
│  │  [-]  2  [+]      ₹698     │    │
│  │                     [🗑️]    │    │
│  │  [♡ Save for Later]        │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ┌─────┐                     │    │
│  │ │[IMG]│ Chicken Gongura     │    │
│  │ │     │ 250g | Hot          │    │
│  │ └─────┘ ₹399                │    │
│  │                             │    │
│  │  [-]  1  [+]      ₹399     │    │
│  │                     [🗑️]    │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🏷️ Apply Coupon         [▶] │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Price Details                      │
│                                     │
│  Subtotal (3 items)        ₹1,097  │
│  Discount                    -₹100  │
│  Delivery                     FREE  │
│  ─────────────────────────────────  │
│  Total                     ₹997    │
│                                     │
│  💰 You're saving ₹100 on this order│
│                                     │
├─────────────────────────────────────┤
│  ₹997              [Proceed to Buy] │
└─────────────────────────────────────┘
```

### 7.2 Empty Cart State
```
┌─────────────────────────────────────┐
│  [←]           Cart                 │
├─────────────────────────────────────┤
│                                     │
│                                     │
│           [🛒 Empty Icon]           │
│                                     │
│        Your cart is empty           │
│                                     │
│     Looks like you haven't added    │
│      anything to your cart yet      │
│                                     │
│  ┌─────────────────────────────┐    │
│  │      Start Shopping          │    │
│  └─────────────────────────────┘    │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

---

## 8. Checkout Flow

### 8.1 Address Selection
```
┌─────────────────────────────────────┐
│  [←]      Select Address            │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ◉ Home                      │    │
│  │   Rahul Sharma              │    │
│  │   123, ABC Apartments       │    │
│  │   Banjara Hills, Hyderabad  │    │
│  │   Telangana - 500034        │    │
│  │   📞 +91 98765 43210        │    │
│  │                    [Edit]   │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ○ Work                      │    │
│  │   ...                       │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  [+] Add New Address         │    │
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│  [Deliver to this Address]          │
└─────────────────────────────────────┘
```

### 8.2 Order Summary
```
┌─────────────────────────────────────┐
│  [←]      Order Summary             │
├─────────────────────────────────────┤
│                                     │
│  Delivery Address                   │
│  ┌─────────────────────────────┐    │
│  │ Rahul Sharma               │    │
│  │ 123, ABC Apartments...     │    │
│  │                   [Change] │    │
│  └─────────────────────────────┘    │
│                                     │
│  📅 Estimated Delivery: Jan 5-7     │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Items (3)                          │
│  ┌─────────────────────────────┐    │
│  │ Gongura Classic 500g  x2    │    │
│  │ Medium spice          ₹698 │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ Chicken Gongura 250g  x1   │    │
│  │ Hot spice             ₹399 │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Price Details                      │
│  Subtotal                  ₹1,097  │
│  Coupon (FIRST100)          -₹100  │
│  Delivery                     FREE  │
│  GST (5%)                     ₹50  │
│  ─────────────────────────────────  │
│  Total Payable             ₹1,047  │
│                                     │
├─────────────────────────────────────┤
│  ₹1,047        [Continue to Pay]    │
└─────────────────────────────────────┘
```

### 8.3 Payment Selection
```
┌─────────────────────────────────────┐
│  [←]      Payment Method            │
├─────────────────────────────────────┤
│                                     │
│  UPI (Recommended)                  │
│  ┌─────────────────────────────┐    │
│  │ ◉ Google Pay               │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ ○ PhonePe                  │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ ○ Paytm                    │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ ○ Enter UPI ID             │    │
│  └─────────────────────────────┘    │
│                                     │
│  Cards                              │
│  ┌─────────────────────────────┐    │
│  │ ○ Credit / Debit Card      │    │
│  └─────────────────────────────┘    │
│                                     │
│  More Options                       │
│  ┌─────────────────────────────┐    │
│  │ ○ Net Banking              │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ ○ Cash on Delivery         │    │
│  │   (₹40 extra charge)       │    │
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│  ₹1,047            [Pay Now]        │
└─────────────────────────────────────┘
```

---

## 9. Order Confirmation

### 9.1 Success Screen
```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│            ✓                        │
│       [Green Checkmark]             │
│                                     │
│      Order Placed Successfully!     │
│                                     │
│      Order ID: #GG123456789         │
│                                     │
│   Thank you for your order. You'll  │
│   receive a confirmation shortly.   │
│                                     │
│   📅 Expected Delivery              │
│      January 5-7, 2025              │
│                                     │
│  ┌─────────────────────────────┐    │
│  │       Track Order           │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │    Continue Shopping        │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

## 10. Order Tracking

### 10.1 Order Details Screen
```
┌─────────────────────────────────────┐
│  [←]      Order Details             │
├─────────────────────────────────────┤
│                                     │
│  Order #GG123456789                 │
│  Placed on Dec 29, 2024             │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Order Status                       │
│                                     │
│  ✓ Order Confirmed                  │
│  │  Dec 29, 2024 - 10:30 AM        │
│  │                                  │
│  ✓ Processing                       │
│  │  Dec 29, 2024 - 11:00 AM        │
│  │                                  │
│  ✓ Packed                           │
│  │  Dec 29, 2024 - 3:00 PM         │
│  │                                  │
│  ● Shipped                          │
│  │  Dec 30, 2024 - 9:00 AM         │
│  │  Tracking: DELHIVERY123456       │
│  │                                  │
│  ○ Out for Delivery                 │
│  │                                  │
│  ○ Delivered                        │
│     Expected: Jan 5, 2025           │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Delivery Address                   │
│  Rahul Sharma                       │
│  123, ABC Apartments, Banjara Hills │
│  Hyderabad, Telangana - 500034      │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Items (3)                          │
│  ┌─────┐ Gongura Classic x2   ₹698 │
│  └─────┘                            │
│  ┌─────┐ Chicken Gongura x1   ₹399 │
│  └─────┘                            │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Payment Summary                    │
│  Subtotal                  ₹1,097  │
│  Discount                   -₹100  │
│  Delivery                     FREE  │
│  GST                          ₹50  │
│  ─────────────────────────────────  │
│  Total Paid               ₹1,047   │
│  Paid via Google Pay               │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  [📥 Download Invoice]              │
│  [🔄 Reorder]                       │
│  [❓ Need Help?]                    │
│                                     │
└─────────────────────────────────────┘
```

---

## 11. Profile & Settings

### 11.1 Profile Screen
```
┌─────────────────────────────────────┐
│  [←]         Profile                │
├─────────────────────────────────────┤
│                                     │
│        ┌─────────┐                  │
│        │  [📷]   │                  │
│        │   RS    │                  │
│        └─────────┘                  │
│       Rahul Sharma                  │
│    +91 98765 43210                  │
│    [Edit Profile]                   │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 📦  My Orders            ▶  │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ 📍  Saved Addresses      ▶  │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ ❤️  Wishlist             ▶  │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ 💳  Payment Methods      ▶  │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ 🎁  Coupons & Offers     ▶  │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🔔  Notifications        ▶  │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ ❓  Help & Support       ▶  │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ 📄  Terms & Privacy      ▶  │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ ℹ️   About Us            ▶  │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🚪  Logout                   │    │
│  └─────────────────────────────┘    │
│                                     │
│  App Version 1.0.0                  │
│                                     │
└─────────────────────────────────────┘
```

---

## 12. Error & Empty States

### 12.1 Error States

**Network Error**
```
┌─────────────────────────────────────┐
│                                     │
│         [📡 No Signal Icon]         │
│                                     │
│       No Internet Connection        │
│                                     │
│    Please check your connection     │
│         and try again               │
│                                     │
│        [Retry]                      │
│                                     │
└─────────────────────────────────────┘
```

**Server Error**
```
┌─────────────────────────────────────┐
│                                     │
│         [⚠️ Error Icon]             │
│                                     │
│        Something went wrong         │
│                                     │
│     We're working on fixing it.     │
│        Please try again later.      │
│                                     │
│        [Retry]                      │
│                                     │
└─────────────────────────────────────┘
```

### 12.2 Empty States

| Screen | Message | Action |
|--------|---------|--------|
| Cart | "Your cart is empty" | Start Shopping |
| Wishlist | "No items saved yet" | Explore Products |
| Orders | "No orders yet" | Start Shopping |
| Search Results | "No products found" | Try different keywords |
| Notifications | "No notifications" | - |

---

*Document maintained by: Gongura-Griha Development Team*
