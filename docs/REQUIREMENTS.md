# Gongura-Griha: Requirements Document

> **Document Status:** Sacred - Must be followed for all implementation decisions
> **Version:** 1.0.0
> **Last Updated:** December 2024

---

## 1. Functional Requirements

### 1.1 User Management (UM)

#### UM-001: User Registration
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Users must be able to create an account |
| **Acceptance Criteria** | |
| | - Registration via phone number with OTP verification |
| | - Registration via email with password |
| | - Social login (Google, Apple) |
| | - Collect: Name, Phone, Email |
| | - Phone number is mandatory and unique |
| | - Email is optional but unique if provided |

#### UM-002: User Login
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Users must be able to log in to their account |
| **Acceptance Criteria** | |
| | - Login via phone + OTP |
| | - Login via email + password |
| | - Login via Google OAuth |
| | - Login via Apple Sign-In (iOS) |
| | - "Remember me" functionality |
| | - Session management with JWT tokens |

#### UM-003: User Profile
| Attribute | Description |
|-----------|-------------|
| **Priority** | P1 (High) |
| **Description** | Users can view and edit their profile |
| **Acceptance Criteria** | |
| | - View profile information |
| | - Edit name, email, phone |
| | - Change password |
| | - Upload profile picture |
| | - Delete account option |

#### UM-004: Address Management
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Users can manage delivery addresses |
| **Acceptance Criteria** | |
| | - Add multiple addresses |
| | - Edit existing addresses |
| | - Delete addresses |
| | - Set default address |
| | - Address fields: Name, Phone, House/Flat, Street, Landmark, City, State, PIN Code |
| | - Address type: Home, Work, Other |
| | - PIN code validation for serviceability |

#### UM-005: Guest Checkout
| Attribute | Description |
|-----------|-------------|
| **Priority** | P1 (High) |
| **Description** | Users can checkout without creating an account |
| **Acceptance Criteria** | |
| | - Allow order placement without registration |
| | - Collect phone and email for order updates |
| | - Prompt to create account post-order |
| | - Associate order with account if created later |

---

### 1.2 Product Catalog (PC)

#### PC-001: Product Listing
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Display products in categorized lists |
| **Acceptance Criteria** | |
| | - Show products by category |
| | - Display: Image, Name, Price, Rating |
| | - Show discounted price with strike-through |
| | - Indicate out-of-stock items |
| | - Pull-to-refresh functionality |
| | - Infinite scroll or pagination |

#### PC-002: Product Details
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Detailed product information page |
| **Acceptance Criteria** | |
| | - Multiple product images with zoom |
| | - Product name and description |
| | - Price and discounts |
| | - Size/variant selection |
| | - Spice level selection (if applicable) |
| | - Quantity selector |
| | - Add to cart button |
| | - Add to wishlist button |
| | - Ingredients list |
| | - Nutritional information |
| | - Shelf life and storage instructions |
| | - FSSAI license number |
| | - Manufacturing and expiry dates |
| | - Customer reviews and ratings |
| | - "Frequently bought together" section |

#### PC-003: Product Search
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Search products by name/keyword |
| **Acceptance Criteria** | |
| | - Search bar on home and catalog pages |
| | - Real-time suggestions as user types |
| | - Search by product name |
| | - Search by category |
| | - Search by ingredient |
| | - Display recent searches |
| | - Handle no results gracefully |

#### PC-004: Product Filters
| Attribute | Description |
|-----------|-------------|
| **Priority** | P1 (High) |
| **Description** | Filter products by various attributes |
| **Acceptance Criteria** | |
| | - Filter by category |
| | - Filter by price range |
| | - Filter by spice level |
| | - Filter by product type (Veg/Non-Veg) |
| | - Filter by size |
| | - Filter by rating |
| | - Multiple filters simultaneously |
| | - Clear all filters option |

#### PC-005: Product Sorting
| Attribute | Description |
|-----------|-------------|
| **Priority** | P1 (High) |
| **Description** | Sort products by different criteria |
| **Acceptance Criteria** | |
| | - Sort by popularity |
| | - Sort by price (low to high) |
| | - Sort by price (high to low) |
| | - Sort by rating |
| | - Sort by newest first |

#### PC-006: Categories
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Organize products into categories |
| **Acceptance Criteria** | |
| | - Display all categories on home |
| | - Category image and name |
| | - Product count per category |
| | - Subcategories if applicable |
| | - Navigate to category listing |

---

### 1.3 Shopping Cart (SC)

#### SC-001: Add to Cart
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Add products to shopping cart |
| **Acceptance Criteria** | |
| | - Add from product listing |
| | - Add from product details |
| | - Select variant before adding |
| | - Select quantity |
| | - Visual confirmation on add |
| | - Update cart badge count |
| | - Persist cart across sessions |

#### SC-002: View Cart
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | View all items in cart |
| **Acceptance Criteria** | |
| | - List all cart items |
| | - Show: Image, Name, Variant, Quantity, Price |
| | - Show individual item total |
| | - Show cart subtotal |
| | - Show savings (if discounted) |
| | - Empty cart message if no items |

#### SC-003: Update Cart
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Modify cart contents |
| **Acceptance Criteria** | |
| | - Increase/decrease quantity |
| | - Remove item from cart |
| | - Update totals in real-time |
| | - Minimum quantity: 1 |
| | - Maximum quantity: based on stock |
| | - "Move to wishlist" option |

#### SC-004: Apply Coupon
| Attribute | Description |
|-----------|-------------|
| **Priority** | P1 (High) |
| **Description** | Apply discount coupons |
| **Acceptance Criteria** | |
| | - Coupon code input field |
| | - Validate coupon |
| | - Show discount amount |
| | - Show error for invalid/expired coupons |
| | - Remove applied coupon |
| | - Only one coupon per order |

---

### 1.4 Wishlist (WL)

#### WL-001: Wishlist Management
| Attribute | Description |
|-----------|-------------|
| **Priority** | P1 (High) |
| **Description** | Save products for later |
| **Acceptance Criteria** | |
| | - Add products to wishlist |
| | - Remove from wishlist |
| | - View all wishlist items |
| | - Move to cart from wishlist |
| | - Wishlist persists across sessions |
| | - Requires user login |

---

### 1.5 Checkout & Orders (CO)

#### CO-001: Checkout Flow
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Complete order placement |
| **Acceptance Criteria** | |
| | - Step 1: Select/Add delivery address |
| | - Step 2: Review order summary |
| | - Step 3: Select payment method |
| | - Step 4: Payment processing |
| | - Step 5: Order confirmation |
| | - Back navigation at each step |
| | - Show order total breakdown |

#### CO-002: Order Summary
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Display order details before payment |
| **Acceptance Criteria** | |
| | - List all items with details |
| | - Subtotal |
| | - Discount (if any) |
| | - Delivery charges |
| | - Taxes (GST) |
| | - Total amount |
| | - Estimated delivery date |
| | - Selected address |

#### CO-003: Payment Processing
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Process payment via Razorpay |
| **Acceptance Criteria** | |
| | - UPI payment |
| | - Credit/Debit card payment |
| | - Net banking |
| | - Wallets (Paytm, PhonePe, etc.) |
| | - Cash on Delivery |
| | - Handle payment success |
| | - Handle payment failure |
| | - Payment retry option |

#### CO-004: Order Confirmation
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Confirm successful order |
| **Acceptance Criteria** | |
| | - Display order ID |
| | - Order summary |
| | - Estimated delivery |
| | - SMS/Email confirmation |
| | - "Continue Shopping" option |
| | - "View Order" option |

#### CO-005: Order History
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | View past orders |
| **Acceptance Criteria** | |
| | - List all orders (newest first) |
| | - Show: Order ID, Date, Status, Total |
| | - Filter by status |
| | - Search by order ID |
| | - Navigate to order details |

#### CO-006: Order Details
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | View single order details |
| **Acceptance Criteria** | |
| | - Order ID and date |
| | - Order status with timeline |
| | - Items ordered |
| | - Delivery address |
| | - Payment method used |
| | - Price breakdown |
| | - Invoice download |
| | - Reorder option |
| | - Cancel order (if eligible) |
| | - Request return (if eligible) |

#### CO-007: Order Tracking
| Attribute | Description |
|-----------|-------------|
| **Priority** | P0 (Critical) |
| **Description** | Track order delivery status |
| **Acceptance Criteria** | |
| | - Order status timeline |
| | - Statuses: Confirmed, Processing, Packed, Shipped, Out for Delivery, Delivered |
| | - Timestamp for each status |
| | - Delivery partner info (if applicable) |
| | - Tracking number (if applicable) |
| | - Push notification on status change |

---

### 1.6 Reviews & Ratings (RR)

#### RR-001: View Reviews
| Attribute | Description |
|-----------|-------------|
| **Priority** | P1 (High) |
| **Description** | View product reviews |
| **Acceptance Criteria** | |
| | - Average rating display |
| | - Rating breakdown (5-star, 4-star, etc.) |
| | - Individual reviews with rating |
| | - Review text and date |
| | - Reviewer name |
| | - Review images (if any) |
| | - Sort by: Recent, Helpful, Rating |

#### RR-002: Write Review
| Attribute | Description |
|-----------|-------------|
| **Priority** | P1 (High) |
| **Description** | Submit product review |
| **Acceptance Criteria** | |
| | - Only for delivered orders |
| | - Star rating (1-5) |
| | - Review text (optional) |
| | - Add photos (optional) |
| | - Edit own review |
| | - Delete own review |

---

### 1.7 Notifications (NT)

#### NT-001: Push Notifications
| Attribute | Description |
|-----------|-------------|
| **Priority** | P1 (High) |
| **Description** | Send push notifications |
| **Acceptance Criteria** | |
| | - Order status updates |
| | - Promotional offers |
| | - Abandoned cart reminders |
| | - New product alerts |
| | - User can enable/disable |
| | - Notification history in app |

---

### 1.8 Support (SP)

#### SP-001: Help Center
| Attribute | Description |
|-----------|-------------|
| **Priority** | P2 (Medium) |
| **Description** | Self-service help |
| **Acceptance Criteria** | |
| | - FAQ section |
| | - Order-related help |
| | - Payment-related help |
| | - Return/refund policy |
| | - Contact information |

#### SP-002: Contact Support
| Attribute | Description |
|-----------|-------------|
| **Priority** | P1 (High) |
| **Description** | Contact customer support |
| **Acceptance Criteria** | |
| | - WhatsApp chat integration |
| | - Email support |
| | - Phone number display |
| | - In-app chat (future) |

---

## 2. Non-Functional Requirements

### 2.1 Performance (NFR-P)

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-P001 | App launch time | < 3 seconds |
| NFR-P002 | Screen load time | < 2 seconds |
| NFR-P003 | Image load time | < 1 second |
| NFR-P004 | API response time | < 500ms (p95) |
| NFR-P005 | Search results | < 1 second |
| NFR-P006 | Frame rate | 60 FPS minimum |
| NFR-P007 | App size | < 50 MB |

### 2.2 Scalability (NFR-S)

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-S001 | Concurrent users | 10,000+ |
| NFR-S002 | Daily orders | 5,000+ |
| NFR-S003 | Product catalog | 500+ products |
| NFR-S004 | User base | 100,000+ |

### 2.3 Availability (NFR-A)

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-A001 | Uptime | 99.9% |
| NFR-A002 | Planned maintenance | < 4 hours/month |
| NFR-A003 | Recovery time | < 1 hour |
| NFR-A004 | Data backup | Daily |

### 2.4 Security (NFR-SEC)

| ID | Requirement |
|----|-------------|
| NFR-SEC001 | All API calls over HTTPS |
| NFR-SEC002 | JWT token-based authentication |
| NFR-SEC003 | Secure password storage (bcrypt) |
| NFR-SEC004 | PCI DSS compliance for payments |
| NFR-SEC005 | Input validation on all fields |
| NFR-SEC006 | Rate limiting on APIs |
| NFR-SEC007 | SQL injection prevention |
| NFR-SEC008 | XSS prevention |

### 2.5 Compatibility (NFR-C)

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-C001 | Android version | 6.0 (API 23) and above |
| NFR-C002 | iOS version | iOS 12 and above |
| NFR-C003 | Screen sizes | All standard sizes |
| NFR-C004 | Orientations | Portrait only |

### 2.6 Usability (NFR-U)

| ID | Requirement |
|----|-------------|
| NFR-U001 | Intuitive navigation (< 3 taps to any feature) |
| NFR-U002 | Consistent UI patterns |
| NFR-U003 | Error messages in user-friendly language |
| NFR-U004 | Loading states for all async operations |
| NFR-U005 | Offline mode for browsing (cached data) |
| NFR-U006 | Accessibility compliance (WCAG 2.1 AA) |

### 2.7 Localization (NFR-L)

| ID | Requirement | Phase |
|----|-------------|-------|
| NFR-L001 | English language | MVP |
| NFR-L002 | Telugu language | Phase 2 |
| NFR-L003 | Hindi language | Phase 2 |
| NFR-L004 | INR currency | MVP |

---

## 3. Constraints

### 3.1 Technical Constraints
- Flutter framework for mobile development
- Razorpay for payment processing
- Firebase for notifications and analytics
- Must work on 4G networks efficiently

### 3.2 Business Constraints
- FSSAI compliance required
- GST compliance for invoicing
- India-only shipping initially
- COD limit of ₹5,000

### 3.3 Regulatory Constraints
- Consumer protection laws
- Data privacy (IT Act 2000)
- Food safety regulations
- E-commerce guidelines (Consumer Protection Act 2019)

---

## 4. Assumptions

1. Users have smartphones with camera access
2. Users have stable internet connectivity
3. Products will be managed via admin dashboard
4. Inventory is centralized (single warehouse)
5. Delivery is handled by third-party logistics
6. Customer support is available during business hours

---

## 5. Dependencies

| Dependency | Type | Impact |
|------------|------|--------|
| Razorpay API | External | Payment processing |
| Firebase | External | Notifications, Analytics |
| SMS Gateway | External | OTP delivery |
| Email Service | External | Transactional emails |
| Logistics Partner | External | Order delivery |
| Cloud Hosting | External | Backend services |

---

## 6. Requirement Traceability

All requirements in this document are traceable to:
- PROJECT_OVERVIEW.md (Business goals)
- FEATURE_SPECIFICATIONS.md (Detailed specs)
- TEST_CASES.md (Verification)

---

*Document maintained by: Gongura-Griha Development Team*
