# Gongura Griha

Authentic Andhra Gongura Pickle E-commerce Mobile App

## About

Gongura Griha is a Flutter-based mobile application for selling authentic Andhra gongura (sorrel leaf) pickles and related products. The app provides a complete e-commerce experience including product browsing, cart management, order tracking, and multi-language support.

## Current Status

**Phase 1 Complete** - Full UI implementation with mock data

## Features

### Implemented
- Product catalog with categories (Pachadi, Chutney, Powder)
- Product detail with size variants and quantity selection
- Shopping cart with coupon support
- Checkout flow with address and payment selection
- Order tracking with progress timeline
- Wishlist management
- User profile and settings
- Search with suggestions
- Multi-language support (English, Hindi, Telugu)
- Push notification UI

### Coming Soon (Phase 2)
- Backend API integration
- Real payment processing (Razorpay)
- User authentication
- Push notifications

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.x |
| Language | Dart |
| Navigation | GoRouter |
| State | StatefulWidget (local state) |
| Localization | flutter_localizations + ARB files |
| Images | cached_network_image |

## Project Structure

```
lib/
├── app/              # App config, routes, theme
├── core/             # Utilities, formatters
├── features/         # Feature modules
│   ├── auth/         # Login, OTP, Register
│   ├── home/         # Home screen
│   ├── products/     # Product list & detail
│   ├── cart/         # Cart & checkout
│   ├── orders/       # Order list & detail
│   ├── wishlist/     # Saved products
│   ├── profile/      # User profile
│   ├── search/       # Product search
│   └── ...           # Other features
├── l10n/             # Localization files
└── shared/           # Shared widgets
```

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart SDK
- Android Studio / VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/your-repo/gongura-griha.git

# Navigate to project
cd gongura-griha

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run the app
flutter run
```

## Documentation

Detailed documentation is available in the `/docs` folder:

- [Frontend Implementation](docs/FRONTEND_IMPLEMENTATION.md) - Screen implementations and integration details
- [Project Overview](docs/PROJECT_OVERVIEW.md) - Vision and scope
- [Technical Architecture](docs/TECHNICAL_ARCHITECTURE.md) - System design
- [UI/UX Guidelines](docs/UI_UX_GUIDELINES.md) - Design system
- [Feature Specifications](docs/FEATURE_SPECIFICATIONS.md) - Detailed feature specs

## Products

The app currently features 3 gongura products:

1. **Traditional Gongura Pachadi** - Authentic Andhra-style pickle
2. **Classic Gongura Chutney** - Tangy and spicy chutney
3. **Spicy Gongura Podi** - Dry powder for rice

Each product is available in 3 sizes:
- Small (250g)
- Medium (500g)
- Large (1kg)

## Localization

The app supports:
- English (en)
- Hindi (hi)
- Telugu (te)

## License

Private - All rights reserved

## Contact

Gongura Griha
- Email: info@gonguragriha.com
- Phone: +91 7995314630
- Address: Hyderabad, Telangana
