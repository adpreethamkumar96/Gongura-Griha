# Gongura-Griha: UI/UX Guidelines

> **Document Status:** Sacred - Must be followed for all implementation decisions
> **Version:** 1.0.0
> **Last Updated:** December 2024

---

## 1. Design Philosophy

### 1.1 Core Principles

1. **Authenticity** - Design should reflect traditional Indian aesthetics with modern usability
2. **Simplicity** - Clean, uncluttered interfaces that focus on products
3. **Trust** - Professional design that builds customer confidence
4. **Accessibility** - Usable by all users regardless of ability
5. **Performance** - Lightweight assets, fast loading

### 1.2 Design Goals

- **3-tap rule:** Any action should be achievable within 3 taps
- **Visual hierarchy:** Important elements should stand out
- **Consistency:** Same patterns across all screens
- **Feedback:** Every action should have visible feedback
- **Error prevention:** Guide users to avoid mistakes

---

## 2. Brand Identity

### 2.1 Logo

**Primary Logo:**
- Gongura leaf icon + "Gongura-Griha" wordmark
- Used in splash screen, header, marketing

**App Icon:**
- Simplified gongura leaf symbol
- Works at small sizes (512x512 to 48x48)

**Logo Clear Space:**
- Minimum padding: 1x height of logo on all sides

### 2.2 Brand Colors

```dart
// Primary Colors
static const Color primaryGreen = Color(0xFF2E7D32);      // Gongura leaf green
static const Color primaryGreenLight = Color(0xFF4CAF50);
static const Color primaryGreenDark = Color(0xFF1B5E20);

// Secondary Colors
static const Color accentOrange = Color(0xFFFF5722);      // Spice/Chili orange
static const Color accentOrangeLight = Color(0xFFFF8A65);

// Background Colors
static const Color backgroundPrimary = Color(0xFFFAFAFA);
static const Color backgroundSecondary = Color(0xFFFFFFFF);
static const Color backgroundTertiary = Color(0xFFF5F5F5);

// Text Colors
static const Color textPrimary = Color(0xFF212121);
static const Color textSecondary = Color(0xFF757575);
static const Color textTertiary = Color(0xFFBDBDBD);
static const Color textOnPrimary = Color(0xFFFFFFFF);

// Status Colors
static const Color success = Color(0xFF4CAF50);
static const Color warning = Color(0xFFFFC107);
static const Color error = Color(0xFFF44336);
static const Color info = Color(0xFF2196F3);

// Other
static const Color divider = Color(0xFFE0E0E0);
static const Color disabled = Color(0xFFBDBDBD);
static const Color overlay = Color(0x80000000);

// Veg/Non-Veg Indicators
static const Color vegGreen = Color(0xFF00C853);
static const Color nonVegRed = Color(0xFFD32F2F);
```

### 2.3 Color Usage Guidelines

| Element | Color |
|---------|-------|
| App bar background | White or Primary Green |
| Primary buttons | Primary Green |
| Secondary buttons | White with Primary Green border |
| Links | Primary Green |
| Prices | Text Primary |
| Discounted prices | Accent Orange |
| Original prices (struck) | Text Tertiary |
| Success messages | Success Green |
| Error messages | Error Red |
| Veg indicator | Veg Green |
| Non-veg indicator | Non-Veg Red |

---

## 3. Typography

### 3.1 Font Family

**Primary Font:** Poppins (Google Fonts)
- Weights: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)

**Fallback:** System default sans-serif

### 3.2 Type Scale

```dart
// Headings
static const TextStyle h1 = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 32,
  fontWeight: FontWeight.w700,
  height: 1.25,
);

static const TextStyle h2 = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 24,
  fontWeight: FontWeight.w600,
  height: 1.3,
);

static const TextStyle h3 = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 20,
  fontWeight: FontWeight.w600,
  height: 1.4,
);

static const TextStyle h4 = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 1.4,
);

// Body
static const TextStyle bodyLarge = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.5,
);

static const TextStyle bodyMedium = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.5,
);

static const TextStyle bodySmall = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  height: 1.5,
);

// Labels
static const TextStyle labelLarge = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  fontWeight: FontWeight.w500,
  height: 1.4,
);

static const TextStyle labelMedium = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 12,
  fontWeight: FontWeight.w500,
  height: 1.4,
);

static const TextStyle labelSmall = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 10,
  fontWeight: FontWeight.w500,
  height: 1.4,
  letterSpacing: 0.5,
);

// Prices
static const TextStyle priceRegular = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 1.2,
);

static const TextStyle priceLarge = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 20,
  fontWeight: FontWeight.w700,
  height: 1.2,
);

static const TextStyle priceStruck = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  decoration: TextDecoration.lineThrough,
  color: textTertiary,
);

// Buttons
static const TextStyle buttonLarge = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 1.25,
);

static const TextStyle buttonMedium = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 1.25,
);
```

### 3.3 Typography Usage

| Element | Style |
|---------|-------|
| Screen titles | h2 or h3 |
| Section headings | h4 |
| Product names (card) | bodyMedium, Medium |
| Product names (detail) | h3 |
| Descriptions | bodyMedium |
| Prices | priceRegular or priceLarge |
| Button text | buttonMedium |
| Form labels | labelMedium |
| Helper text | bodySmall |
| Chips/Tags | labelSmall |

---

## 4. Spacing & Layout

### 4.1 Spacing Scale (8px base)

```dart
static const double spacing4 = 4.0;
static const double spacing8 = 8.0;
static const double spacing12 = 12.0;
static const double spacing16 = 16.0;
static const double spacing20 = 20.0;
static const double spacing24 = 24.0;
static const double spacing32 = 32.0;
static const double spacing40 = 40.0;
static const double spacing48 = 48.0;
static const double spacing56 = 56.0;
static const double spacing64 = 64.0;
```

### 4.2 Screen Padding

```dart
// Standard screen padding
static const EdgeInsets screenPadding = EdgeInsets.all(16.0);

// Horizontal only (for lists)
static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: 16.0);
```

### 4.3 Component Spacing

| Between | Spacing |
|---------|---------|
| Sections | 24px |
| Cards in grid | 12px |
| Cards in list | 12px |
| Items within card | 8px |
| Icon and text | 8px |
| Button icon and label | 8px |
| Form fields | 16px |
| Label and input | 8px |

### 4.4 Grid System

**Product Grid:**
- 2 columns on phones
- 16px outer padding
- 12px gap between items

**Category Grid:**
- 4 columns horizontal scroll
- 16px outer padding
- 12px gap between items

---

## 5. Components

### 5.1 Buttons

#### Primary Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.white,
    minimumSize: Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 0,
  ),
  child: Text('Button Text'),
)
```

#### Secondary Button
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: primaryGreen,
    minimumSize: Size(double.infinity, 48),
    side: BorderSide(color: primaryGreen),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('Button Text'),
)
```

#### Text Button
```dart
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: primaryGreen,
  ),
  child: Text('Button Text'),
)
```

#### Icon Button
```dart
IconButton(
  icon: Icon(Icons.favorite_border),
  onPressed: () {},
  color: textSecondary,
)
```

**Button States:**
- Default: Normal colors
- Pressed: 10% darker
- Disabled: 50% opacity
- Loading: Show circular progress indicator

**Button Sizes:**
| Size | Height | Font |
|------|--------|------|
| Large | 56px | 16px |
| Medium | 48px | 14px |
| Small | 36px | 12px |

---

### 5.2 Input Fields

#### Text Input
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Placeholder',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: primaryGreen, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: error),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
)
```

**Input States:**
- Default: Grey border (#E0E0E0)
- Focused: Primary green border (2px)
- Error: Red border + error text below
- Disabled: Light grey background

---

### 5.3 Cards

#### Product Card
```
┌─────────────────────┐
│                     │
│    [Product Image]  │  Aspect ratio: 1:1
│         ❤️          │  Heart icon top-right
│    🏷️ 20% OFF       │  Badge bottom-left (if discount)
├─────────────────────┤
│ 🥬                  │  Veg/Non-veg indicator
│ Product Name        │  Max 2 lines, ellipsis
│ ★ 4.5 (120)         │  Rating
│ ₹̶2̶4̶9̶ ₹199          │  Prices
│                     │
│ [  Add to Cart  ]   │  Button
└─────────────────────┘
```

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

---

### 5.4 Bottom Navigation

```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.white,
  selectedItemColor: primaryGreen,
  unselectedItemColor: textTertiary,
  selectedLabelStyle: labelSmall.copyWith(fontWeight: FontWeight.w600),
  unselectedLabelStyle: labelSmall,
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Orders'),
    BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
)
```

---

### 5.5 App Bar

```dart
AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  centerTitle: true,
  title: Text('Title', style: h4.copyWith(color: textPrimary)),
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: textPrimary),
    onPressed: () => Navigator.pop(context),
  ),
  actions: [
    IconButton(icon: Icon(Icons.search), onPressed: () {}),
    IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
  ],
)
```

---

### 5.6 Chips & Tags

#### Selection Chip
```dart
ChoiceChip(
  label: Text('250g'),
  selected: isSelected,
  selectedColor: primaryGreenLight.withOpacity(0.2),
  labelStyle: labelMedium.copyWith(
    color: isSelected ? primaryGreen : textSecondary,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    side: BorderSide(
      color: isSelected ? primaryGreen : divider,
    ),
  ),
)
```

#### Status Badge
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: statusColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(
    'Delivered',
    style: labelSmall.copyWith(color: statusColor),
  ),
)
```

---

### 5.7 Dialogs & Modals

#### Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
  builder: (context) => Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: 16),
        // Content
      ],
    ),
  ),
)
```

#### Alert Dialog
```dart
AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  title: Text('Title'),
  content: Text('Message'),
  actions: [
    TextButton(child: Text('Cancel'), onPressed: () {}),
    ElevatedButton(child: Text('Confirm'), onPressed: () {}),
  ],
)
```

---

### 5.8 Loading States

#### Full Screen Loader
```dart
Center(
  child: CircularProgressIndicator(
    color: primaryGreen,
  ),
)
```

#### Skeleton Loading
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(8),
  ),
)
// Animate with shimmer effect
```

#### Button Loading
```dart
ElevatedButton(
  onPressed: null,
  child: SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: Colors.white,
    ),
  ),
)
```

---

## 6. Icons

### 6.1 Icon Library

**Primary:** Material Icons (built into Flutter)
**Secondary:** Custom SVG icons for brand-specific elements

### 6.2 Icon Sizes

| Context | Size |
|---------|------|
| Bottom navigation | 24px |
| App bar actions | 24px |
| List item leading | 24px |
| Button with icon | 20px |
| Input prefix | 20px |
| Inline text | 16px |
| Badge/tag | 14px |

### 6.3 Common Icons

| Purpose | Icon |
|---------|------|
| Back | `arrow_back` |
| Close | `close` |
| Search | `search` |
| Cart | `shopping_cart` |
| Wishlist (empty) | `favorite_border` |
| Wishlist (filled) | `favorite` |
| Home | `home` |
| Orders | `shopping_bag` |
| Profile | `person` |
| Add | `add` |
| Remove | `remove` |
| Delete | `delete` |
| Edit | `edit` |
| Share | `share` |
| Location | `location_on` |
| Phone | `phone` |
| Email | `email` |
| Star (filled) | `star` |
| Star (empty) | `star_border` |
| Check | `check` |
| Error | `error` |
| Info | `info` |
| Veg | Custom (green square with circle) |
| Non-veg | Custom (red square with circle) |

---

## 7. Images

### 7.1 Image Specifications

| Image Type | Dimensions | Format |
|------------|------------|--------|
| Product main | 800x800px | JPG/WebP |
| Product thumbnail | 400x400px | JPG/WebP |
| Category icon | 200x200px | PNG/SVG |
| Banner (mobile) | 1080x540px | JPG/WebP |
| User avatar | 200x200px | JPG/PNG |
| Logo (splash) | 300x300px | PNG |
| App icon | 512x512px | PNG |

### 7.2 Image Loading

```dart
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => ShimmerPlaceholder(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fit: BoxFit.cover,
)
```

### 7.3 Image Placeholders

- Use shimmer effect during loading
- Show grey placeholder with icon on error
- Maintain aspect ratio at all times

---

## 8. Animation & Motion

### 8.1 Animation Principles

1. **Purpose:** Animations should guide attention and provide feedback
2. **Duration:** Keep animations short (150-300ms)
3. **Easing:** Use natural curves (Curves.easeInOut)
4. **Consistency:** Same animation for same action

### 8.2 Standard Durations

```dart
static const Duration fast = Duration(milliseconds: 150);
static const Duration normal = Duration(milliseconds: 250);
static const Duration slow = Duration(milliseconds: 400);
```

### 8.3 Common Animations

| Action | Animation |
|--------|-----------|
| Page transition | Slide right (forward), Slide left (back) |
| Modal/Bottom sheet | Slide up |
| Add to cart | Product image fly to cart icon |
| Wishlist toggle | Heart scale + color change |
| Button press | Scale down slightly |
| List item appear | Fade in + slide up |
| Skeleton loading | Shimmer left to right |
| Pull to refresh | Rotate + bounce |

### 8.4 Micro-interactions

- Button ripple effect on tap
- Checkbox bounce when checked
- Quantity increment subtle pulse
- Toast slide in from top
- Success checkmark draw animation

---

## 9. Accessibility

### 9.1 Color Contrast

- Text on backgrounds: Minimum 4.5:1 ratio
- Large text (18px+): Minimum 3:1 ratio
- Interactive elements: Minimum 3:1 ratio

### 9.2 Touch Targets

- Minimum touch target size: 48x48px
- Spacing between targets: Minimum 8px

### 9.3 Screen Reader

```dart
Semantics(
  label: 'Add Gongura Classic Pickle to cart',
  button: true,
  child: AddToCartButton(),
)
```

### 9.4 Text Scaling

- Support system text scaling (0.85x to 1.3x)
- Test layouts at maximum scale
- Use flexible layouts that accommodate larger text

---

## 10. Dark Mode (Future)

Reserved for future implementation. Design system should be built with dark mode capability in mind.

```dart
// Dark mode colors (placeholder)
static const Color darkBackground = Color(0xFF121212);
static const Color darkSurface = Color(0xFF1E1E1E);
static const Color darkTextPrimary = Color(0xFFFFFFFF);
static const Color darkTextSecondary = Color(0xFFB3B3B3);
```

---

## 11. Platform Specifics

### 11.1 Android

- Use Material Design components
- Bottom navigation
- Floating action button (where appropriate)
- Material ripple effects

### 11.2 iOS

- Respect iOS conventions where needed
- Use Cupertino widgets for pickers, switches
- Handle safe areas (notch, home indicator)
- Support haptic feedback

---

## 12. Assets Organization

```
assets/
├── images/
│   ├── logo/
│   │   ├── logo_full.png
│   │   ├── logo_icon.png
│   │   └── logo_splash.png
│   ├── illustrations/
│   │   ├── empty_cart.svg
│   │   ├── empty_wishlist.svg
│   │   ├── empty_orders.svg
│   │   ├── no_internet.svg
│   │   └── error.svg
│   └── onboarding/
│       ├── onboarding_1.png
│       ├── onboarding_2.png
│       └── onboarding_3.png
├── icons/
│   ├── veg.svg
│   ├── non_veg.svg
│   └── spice_levels/
│       ├── mild.svg
│       ├── medium.svg
│       ├── hot.svg
│       └── extra_hot.svg
└── fonts/
    └── Poppins/
        ├── Poppins-Regular.ttf
        ├── Poppins-Medium.ttf
        ├── Poppins-SemiBold.ttf
        └── Poppins-Bold.ttf
```

---

## 13. Design Checklist

Before finalizing any screen:

- [ ] Follows 8px spacing grid
- [ ] Uses defined color palette
- [ ] Uses defined typography scale
- [ ] Touch targets are 48x48px minimum
- [ ] Loading state defined
- [ ] Error state defined
- [ ] Empty state defined
- [ ] Accessibility labels added
- [ ] Works on small screens (320px width)
- [ ] Works on large screens (428px width)
- [ ] Tested with large text (1.3x)

---

*Document maintained by: Gongura-Griha Development Team*
