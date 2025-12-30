# Gongura-Griha: Development Guidelines

> **Document Status:** Sacred - Must be followed for all implementation decisions
> **Version:** 1.0.0
> **Last Updated:** December 2024

---

## 1. Development Environment

### 1.1 Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | 3.16+ | Mobile app framework |
| Dart | 3.2+ | Programming language |
| Node.js | 20.x LTS | Backend runtime |
| PostgreSQL | 15+ | Database |
| Redis | 7+ | Caching |
| Git | 2.40+ | Version control |
| VS Code / Android Studio | Latest | IDE |

### 1.2 Flutter Setup

```bash
# Verify installation
flutter doctor

# Expected output - all checkmarks
[✓] Flutter (Channel stable, 3.16.x)
[✓] Android toolchain
[✓] Xcode
[✓] Chrome
[✓] Android Studio
[✓] VS Code
```

### 1.3 Recommended VS Code Extensions

- Flutter
- Dart
- Bloc
- Flutter Intl (i18n)
- Error Lens
- GitLens
- Prettier
- ESLint (for backend)

---

## 2. Project Structure

### 2.1 Flutter Project Structure

```
gongura_griha_app/
├── android/                    # Android native code
├── ios/                        # iOS native code
├── lib/
│   ├── main.dart              # Entry point
│   ├── app/
│   │   ├── app.dart           # App widget & MaterialApp
│   │   ├── routes.dart        # Route configuration
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── colors.dart
│   │       └── typography.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/
│   │   ├── utils/
│   │   └── di/
│   │
│   ├── features/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── products/
│   │   ├── cart/
│   │   ├── checkout/
│   │   ├── orders/
│   │   ├── profile/
│   │   └── wishlist/
│   │
│   └── shared/
│       ├── widgets/
│       └── extensions/
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

### 2.2 Feature Module Structure

```
features/
└── products/
    ├── data/
    │   ├── datasources/
    │   │   ├── product_remote_datasource.dart
    │   │   └── product_local_datasource.dart
    │   ├── models/
    │   │   ├── product_model.dart
    │   │   └── category_model.dart
    │   └── repositories/
    │       └── product_repository_impl.dart
    │
    ├── domain/
    │   ├── entities/
    │   │   ├── product.dart
    │   │   └── category.dart
    │   ├── repositories/
    │   │   └── product_repository.dart
    │   └── usecases/
    │       ├── get_products.dart
    │       ├── get_product_details.dart
    │       └── search_products.dart
    │
    └── presentation/
        ├── bloc/
        │   ├── product_bloc.dart
        │   ├── product_event.dart
        │   └── product_state.dart
        ├── pages/
        │   ├── product_list_page.dart
        │   └── product_detail_page.dart
        └── widgets/
            ├── product_card.dart
            └── product_filters.dart
```

---

## 3. Coding Standards

### 3.1 Dart Style Guide

Follow the official [Effective Dart](https://dart.dev/effective-dart) guide.

**Key Rules:**

```dart
// ✓ DO use UpperCamelCase for types
class ProductRepository {}
enum PaymentMethod { upi, card, cod }

// ✓ DO use lowerCamelCase for variables, functions
final productName = 'Gongura Pickle';
void addToCart() {}

// ✓ DO use lowercase_with_underscores for files
// product_repository.dart
// payment_service.dart

// ✓ DO use SCREAMING_CAPS for constants
const MAX_QUANTITY = 10;
const API_TIMEOUT = Duration(seconds: 30);

// ✓ DO prefer single quotes for strings
final name = 'Gongura-Griha';

// ✓ DO use trailing commas for better formatting
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Hello'),
        Text('World'),
      ],
    ),
  );
}
```

### 3.2 Analysis Options

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - always_require_non_null_named_parameters
    - annotate_overrides
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_returning_null_for_void
    - avoid_slow_async_io
    - avoid_types_as_parameter_names
    - avoid_unused_constructor_parameters
    - await_only_futures
    - camel_case_extensions
    - camel_case_types
    - cancel_subscriptions
    - close_sinks
    - constant_identifier_names
    - curly_braces_in_flow_control_structures
    - empty_catches
    - empty_constructor_bodies
    - exhaustive_cases
    - file_names
    - hash_and_equals
    - implementation_imports
    - library_names
    - library_prefixes
    - no_duplicate_case_values
    - non_constant_identifier_names
    - null_closures
    - overridden_fields
    - package_names
    - package_prefixed_library_names
    - prefer_adjacent_string_concatenation
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_contains
    - prefer_equal_for_default_values
    - prefer_final_fields
    - prefer_final_locals
    - prefer_for_elements_to_map_fromIterable
    - prefer_generic_function_type_aliases
    - prefer_if_null_operators
    - prefer_initializing_formals
    - prefer_interpolation_to_compose_strings
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_iterable_whereType
    - prefer_single_quotes
    - prefer_spread_collections
    - recursive_getters
    - slash_for_doc_comments
    - sort_child_properties_last
    - sort_constructors_first
    - sort_unnamed_constructors_first
    - type_init_formals
    - unawaited_futures
    - unnecessary_await_in_return
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_getters_setters
    - unnecessary_lambdas
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_null_in_if_null_operators
    - unnecessary_overrides
    - unnecessary_parenthesis
    - unnecessary_statements
    - unnecessary_string_escapes
    - unnecessary_string_interpolations
    - unnecessary_this
    - unrelated_type_equality_checks
    - use_full_hex_values_for_flutter_colors
    - use_function_type_syntax_for_parameters
    - use_rethrow_when_possible
    - valid_regexps
    - void_checks

analyzer:
  errors:
    missing_required_param: error
    missing_return: error
    must_be_immutable: error
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

### 3.3 BLoC Pattern Guidelines

```dart
// ✓ Events should be immutable
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final String? category;
  final int page;

  const LoadProducts({this.category, this.page = 1});

  @override
  List<Object?> get props => [category, page];
}

// ✓ States should be immutable
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;

  const ProductLoaded({
    required this.products,
    this.hasReachedMax = false,
  });

  ProductLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [products, hasReachedMax];
}

// ✓ BLoC should be focused and single-purpose
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProducts;

  ProductBloc({required this.getProducts}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<RefreshProducts>(_onRefreshProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getProducts(
      GetProductsParams(category: event.category, page: event.page),
    );

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }
}
```

### 3.4 Widget Guidelines

```dart
// ✓ Extract widgets for reusability
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          children: [
            _buildImage(),
            _buildDetails(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // ...
  }

  Widget _buildDetails() {
    // ...
  }

  Widget _buildActions() {
    // ...
  }
}

// ✓ Use const constructors when possible
class AppConstants {
  static const padding = EdgeInsets.all(16);
  static const borderRadius = BorderRadius.all(Radius.circular(8));
}

// ✓ Prefer composition over inheritance
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text),
    );
  }
}
```

---

## 4. Git Workflow

### 4.1 Branch Naming

```
main              # Production-ready code
develop           # Integration branch
feature/XXX       # New features
bugfix/XXX        # Bug fixes
hotfix/XXX        # Production hotfixes
release/X.X.X     # Release preparation
```

**Examples:**
```
feature/user-authentication
feature/product-search
bugfix/cart-total-calculation
hotfix/payment-crash
release/1.0.0
```

### 4.2 Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting (no code change)
- `refactor`: Code restructure
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(auth): add phone OTP login

fix(cart): correct total calculation with discount

docs(api): update payment endpoint documentation

refactor(products): extract product card widget

test(checkout): add unit tests for price calculation

chore(deps): update flutter_bloc to 8.1.3
```

### 4.3 Pull Request Guidelines

**PR Title:** Same as commit message format

**PR Description Template:**
```markdown
## Summary
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Changes Made
- Change 1
- Change 2

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if UI changes)
[Add screenshots]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed code
- [ ] Commented complex logic
- [ ] Updated documentation
- [ ] No new warnings
```

### 4.4 Git Workflow

```bash
# Start new feature
git checkout develop
git pull origin develop
git checkout -b feature/product-search

# Work on feature
git add .
git commit -m "feat(products): add search functionality"

# Push and create PR
git push origin feature/product-search

# After PR approved and merged
git checkout develop
git pull origin develop
git branch -d feature/product-search
```

---

## 5. Testing Standards

### 5.1 Test Structure

```
test/
├── unit/
│   ├── features/
│   │   ├── auth/
│   │   │   └── domain/
│   │   │       └── usecases/
│   │   │           └── login_test.dart
│   │   └── cart/
│   │       └── domain/
│   │           └── usecases/
│   │               └── add_to_cart_test.dart
│   └── core/
│       └── utils/
│           └── validators_test.dart
│
├── widget/
│   ├── features/
│   │   └── products/
│   │       └── presentation/
│   │           └── widgets/
│   │               └── product_card_test.dart
│   └── shared/
│       └── widgets/
│           └── primary_button_test.dart
│
└── integration/
    └── checkout_flow_test.dart
```

### 5.2 Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

@GenerateMocks([ProductRepository])
void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  group('GetProductsUseCase', () {
    final testProducts = [
      Product(id: '1', name: 'Gongura Pickle'),
      Product(id: '2', name: 'Chicken Gongura'),
    ];

    test('should return list of products from repository', () async {
      // Arrange
      when(mockRepository.getProducts(any))
          .thenAnswer((_) async => Right(testProducts));

      // Act
      final result = await useCase(GetProductsParams());

      // Assert
      expect(result, Right(testProducts));
      verify(mockRepository.getProducts(any)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(mockRepository.getProducts(any))
          .thenAnswer((_) async => Left(ServerFailure('Server error')));

      // Act
      final result = await useCase(GetProductsParams());

      // Assert
      expect(result, isA<Left>());
    });
  });
}
```

### 5.3 Widget Test Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductCard', () {
    testWidgets('displays product name and price', (tester) async {
      final product = Product(
        id: '1',
        name: 'Gongura Pickle',
        price: 199.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: product),
          ),
        ),
      );

      expect(find.text('Gongura Pickle'), findsOneWidget);
      expect(find.text('₹199'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final product = Product(id: '1', name: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: product,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ProductCard));
      expect(tapped, isTrue);
    });
  });
}
```

### 5.4 Test Coverage

**Minimum Coverage Requirements:**
- Domain layer (Use Cases): 90%
- Data layer (Repositories): 80%
- Presentation (BLoC): 80%
- Widgets: 70%
- Overall: 75%

```bash
# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## 6. Error Handling

### 6.1 Error Classes

```dart
// core/errors/failures.dart
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred'])
      : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
      : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error'])
      : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

// core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Server error',
    this.statusCode,
  });
}

class NetworkException implements Exception {}

class CacheException implements Exception {}
```

### 6.2 Error Handling Pattern

```dart
// Repository implementation
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<Product>>> getProducts(
    GetProductsParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getProducts(params);
        await localDataSource.cacheProducts(products);
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error'));
      }
    } else {
      try {
        final cachedProducts = await localDataSource.getCachedProducts();
        return Right(cachedProducts);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
```

---

## 7. Performance Guidelines

### 7.1 Widget Optimization

```dart
// ✓ Use const constructors
const SizedBox(height: 16);
const EdgeInsets.all(16);

// ✓ Use RepaintBoundary for complex widgets
RepaintBoundary(
  child: ComplexAnimatedWidget(),
)

// ✓ Use ListView.builder for long lists
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) => ProductCard(product: products[index]),
)

// ✓ Cache expensive computations
class ProductList extends StatelessWidget {
  final List<Product> products;

  // Computed once
  late final sortedProducts = List.of(products)..sort();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sortedProducts.length,
      itemBuilder: (context, index) => ProductCard(
        product: sortedProducts[index],
      ),
    );
  }
}

// ✓ Use keys for lists that change
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) => ProductCard(
    key: ValueKey(products[index].id),
    product: products[index],
  ),
)
```

### 7.2 Image Optimization

```dart
// ✓ Use CachedNetworkImage
CachedNetworkImage(
  imageUrl: product.imageUrl,
  placeholder: (context, url) => ShimmerPlaceholder(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheHeight: 300,
  memCacheWidth: 300,
)

// ✓ Specify image dimensions
Image.network(
  url,
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  cacheWidth: 200, // 2x for high DPI
  cacheHeight: 200,
)
```

### 7.3 State Management Optimization

```dart
// ✓ Use BlocBuilder with buildWhen
BlocBuilder<CartBloc, CartState>(
  buildWhen: (previous, current) {
    return previous.itemCount != current.itemCount;
  },
  builder: (context, state) {
    return Badge(count: state.itemCount);
  },
)

// ✓ Use BlocSelector for granular rebuilds
BlocSelector<CartBloc, CartState, int>(
  selector: (state) => state.itemCount,
  builder: (context, itemCount) {
    return Badge(count: itemCount);
  },
)
```

---

## 8. Documentation

### 8.1 Code Documentation

```dart
/// A repository that handles product data operations.
///
/// This repository fetches products from the remote server and caches
/// them locally for offline access.
///
/// Example:
/// ```dart
/// final repository = ProductRepositoryImpl(
///   remoteDataSource: remoteDataSource,
///   localDataSource: localDataSource,
/// );
///
/// final result = await repository.getProducts(params);
/// ```
class ProductRepositoryImpl implements ProductRepository {
  /// Creates a new [ProductRepositoryImpl] instance.
  ///
  /// [remoteDataSource] - The remote data source for API calls.
  /// [localDataSource] - The local data source for caching.
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Fetches products based on the given [params].
  ///
  /// Returns [Right] with list of products on success.
  /// Returns [Left] with [Failure] on error.
  ///
  /// Throws no exceptions - all errors are wrapped in [Failure].
  @override
  Future<Either<Failure, List<Product>>> getProducts(
    GetProductsParams params,
  ) async {
    // Implementation
  }
}
```

### 8.2 README Template

Each feature should have a README:

```markdown
# Feature: Products

## Overview
This feature handles product listing, search, and detail views.

## Architecture
- **Domain**: Product entity, ProductRepository interface, Use Cases
- **Data**: API integration, local caching, models
- **Presentation**: BLoC, pages, widgets

## Dependencies
- `dio` for API calls
- `hive` for local caching
- `cached_network_image` for images

## Usage
```dart
// Get product list
context.read<ProductBloc>().add(LoadProducts());

// Navigate to detail
Navigator.pushNamed(context, '/product/${product.slug}');
```

## Testing
```bash
flutter test test/unit/features/products/
```
```

---

## 9. CI/CD Pipeline

### 9.1 GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.x'
          cache: true
      - run: flutter pub get
      - run: flutter analyze

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.x'
          cache: true
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  build-android:
    needs: [analyze, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.x'
          cache: true
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-release
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: [analyze, test]
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.x'
          cache: true
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
```

---

## 10. Dependency Management

### 10.1 Core Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Dependency Injection
  get_it: ^7.6.4
  injectable: ^2.3.2

  # Network
  dio: ^5.4.0
  connectivity_plus: ^5.0.2

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2

  # Navigation
  go_router: ^13.0.1

  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_svg: ^2.0.9

  # Payment
  razorpay_flutter: ^1.3.6

  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.9

  # Utils
  dartz: ^0.10.1
  intl: ^0.18.1
  url_launcher: ^6.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  injectable_generator: ^2.4.1
  hive_generator: ^2.0.1
  mockito: ^5.4.4
  bloc_test: ^9.1.5
```

### 10.2 Version Constraints

- Use caret syntax: `^1.2.3` (allows minor updates)
- Lock major versions for stability
- Update dependencies monthly
- Test thoroughly after updates

---

*Document maintained by: Gongura-Griha Development Team*
