# Gongura-Griha: Database Schema

> **Document Status:** Sacred - Must be followed for all implementation decisions
> **Version:** 1.0.0
> **Last Updated:** December 2024

---

## 1. Database Overview

### 1.1 Database: PostgreSQL 15+

### 1.2 Design Principles
- Use UUIDs for primary keys (security, distribution-ready)
- Soft delete where applicable (is_deleted flag)
- Timestamps on all tables (created_at, updated_at)
- Proper indexing for query optimization
- Foreign key constraints for data integrity
- JSONB for flexible data structures

---

## 2. Entity Relationship Diagram

```
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│      users       │       │    addresses     │       │    categories    │
├──────────────────┤       ├──────────────────┤       ├──────────────────┤
│ id (PK)          │──┐    │ id (PK)          │       │ id (PK)          │
│ name             │  │    │ user_id (FK)     │───────│ name             │
│ email            │  │    │ name             │       │ slug             │
│ phone            │  │    │ phone            │       │ description      │
│ password_hash    │  │    │ address_line_1   │       │ image_url        │
│ avatar_url       │  │    │ address_line_2   │       │ parent_id (FK)   │──┐
│ is_verified      │  │    │ landmark         │       │ is_active        │  │
│ role             │  │    │ city             │       │ sort_order       │  │
│ fcm_token        │  │    │ state            │       │ created_at       │  │
│ created_at       │  │    │ pin_code         │       │ updated_at       │  │
│ updated_at       │  │    │ type             │       └──────────────────┘  │
└──────────────────┘  │    │ is_default       │              ▲              │
         │            │    │ created_at       │              │              │
         │            │    │ updated_at       │              │              │
         │            │    └──────────────────┘              │              │
         │            │                                      │              │
         │            └──────────────────────────────────────┼──────────────┘
         │                                                   │
         │            ┌──────────────────┐       ┌──────────────────┐
         │            │     products     │       │ product_variants │
         │            ├──────────────────┤       ├──────────────────┤
         │            │ id (PK)          │──┐    │ id (PK)          │
         │            │ name             │  │    │ product_id (FK)  │───┐
         │            │ slug             │  │    │ name             │   │
         │            │ description      │  │    │ sku              │   │
         │            │ short_desc       │  │    │ size             │   │
         │            │ category_id (FK) │──┘    │ spice_level      │   │
         │            │ base_price       │       │ price            │   │
         │            │ images           │       │ mrp              │   │
         │            │ is_veg           │       │ stock            │   │
         │            │ ingredients      │       │ is_active        │   │
         │            │ nutrition_info   │       │ created_at       │   │
         │            │ shelf_life       │       │ updated_at       │   │
         │            │ storage_info     │       └──────────────────┘   │
         │            │ is_active        │              │               │
         │            │ is_featured      │              │               │
         │            │ created_at       │              │               │
         │            │ updated_at       │              │               │
         │            └──────────────────┘              │               │
         │                     │                        │               │
         │                     │                        │               │
         ▼                     ▼                        ▼               │
┌──────────────────┐  ┌──────────────────┐    ┌──────────────────┐     │
│      carts       │  │     reviews      │    │     orders       │     │
├──────────────────┤  ├──────────────────┤    ├──────────────────┤     │
│ id (PK)          │  │ id (PK)          │    │ id (PK)          │     │
│ user_id (FK)     │  │ user_id (FK)     │    │ order_number     │     │
│ created_at       │  │ product_id (FK)  │    │ user_id (FK)     │     │
│ updated_at       │  │ order_id (FK)    │    │ address_id (FK)  │     │
└──────────────────┘  │ rating           │    │ status           │     │
         │            │ title            │    │ subtotal         │     │
         │            │ comment          │    │ discount         │     │
         ▼            │ images           │    │ delivery_charge  │     │
┌──────────────────┐  │ is_verified      │    │ tax              │     │
│    cart_items    │  │ created_at       │    │ total            │     │
├──────────────────┤  │ updated_at       │    │ coupon_code      │     │
│ id (PK)          │  └──────────────────┘    │ payment_method   │     │
│ cart_id (FK)     │                          │ payment_id       │     │
│ product_id (FK)  │                          │ payment_status   │     │
│ variant_id (FK)  │─────────────────────────>│ notes            │     │
│ quantity         │                          │ created_at       │     │
│ created_at       │                          │ updated_at       │     │
│ updated_at       │                          └──────────────────┘     │
└──────────────────┘                                   │               │
                                                       ▼               │
                                              ┌──────────────────┐     │
                                              │   order_items    │     │
                                              ├──────────────────┤     │
                                              │ id (PK)          │     │
                                              │ order_id (FK)    │     │
                                              │ product_id (FK)  │     │
                                              │ variant_id (FK)  │─────┘
                                              │ quantity         │
                                              │ price            │
                                              │ total            │
                                              │ created_at       │
                                              └──────────────────┘
                                                       │
                                                       ▼
                                              ┌──────────────────┐
                                              │ order_status_    │
                                              │    history       │
                                              ├──────────────────┤
                                              │ id (PK)          │
                                              │ order_id (FK)    │
                                              │ status           │
                                              │ notes            │
                                              │ created_at       │
                                              └──────────────────┘
```

---

## 3. Table Definitions

### 3.1 users

```sql
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(255) UNIQUE,
    phone           VARCHAR(15) NOT NULL UNIQUE,
    password_hash   VARCHAR(255),
    avatar_url      VARCHAR(500),
    is_verified     BOOLEAN DEFAULT FALSE,
    role            VARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer', 'admin')),
    fcm_token       VARCHAR(500),
    is_active       BOOLEAN DEFAULT TRUE,
    last_login_at   TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
```

**Field Descriptions:**
| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| name | VARCHAR(100) | User's full name |
| email | VARCHAR(255) | Email address (optional, unique) |
| phone | VARCHAR(15) | Phone number with country code (+91...) |
| password_hash | VARCHAR(255) | Bcrypt hashed password (for email login) |
| avatar_url | VARCHAR(500) | Profile picture URL |
| is_verified | BOOLEAN | Phone/email verification status |
| role | VARCHAR(20) | User role: customer, admin |
| fcm_token | VARCHAR(500) | Firebase Cloud Messaging token |
| is_active | BOOLEAN | Account active status |
| last_login_at | TIMESTAMP | Last login timestamp |

---

### 3.2 addresses

```sql
CREATE TABLE addresses (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(100) NOT NULL,
    phone           VARCHAR(15) NOT NULL,
    address_line_1  VARCHAR(255) NOT NULL,
    address_line_2  VARCHAR(255),
    landmark        VARCHAR(255),
    city            VARCHAR(100) NOT NULL,
    state           VARCHAR(100) NOT NULL,
    pin_code        VARCHAR(10) NOT NULL,
    type            VARCHAR(20) DEFAULT 'home' CHECK (type IN ('home', 'work', 'other')),
    is_default      BOOLEAN DEFAULT FALSE,
    latitude        DECIMAL(10, 8),
    longitude       DECIMAL(11, 8),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_addresses_user_id ON addresses(user_id);
CREATE INDEX idx_addresses_pin_code ON addresses(pin_code);

-- Ensure only one default address per user
CREATE UNIQUE INDEX idx_addresses_default ON addresses(user_id) WHERE is_default = TRUE;
```

**Field Descriptions:**
| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | Reference to user |
| name | VARCHAR(100) | Recipient name |
| phone | VARCHAR(15) | Contact phone |
| address_line_1 | VARCHAR(255) | House/Flat number, Building |
| address_line_2 | VARCHAR(255) | Street, Area |
| landmark | VARCHAR(255) | Nearby landmark |
| city | VARCHAR(100) | City name |
| state | VARCHAR(100) | State name |
| pin_code | VARCHAR(10) | Postal code |
| type | VARCHAR(20) | Address type: home, work, other |
| is_default | BOOLEAN | Default delivery address |

---

### 3.3 categories

```sql
CREATE TABLE categories (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL,
    slug            VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT,
    image_url       VARCHAR(500),
    parent_id       UUID REFERENCES categories(id) ON DELETE SET NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    sort_order      INTEGER DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_active ON categories(is_active) WHERE is_active = TRUE;
```

**Field Descriptions:**
| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| name | VARCHAR(100) | Category display name |
| slug | VARCHAR(100) | URL-friendly identifier |
| description | TEXT | Category description |
| image_url | VARCHAR(500) | Category image |
| parent_id | UUID | Parent category (for subcategories) |
| is_active | BOOLEAN | Active/visible status |
| sort_order | INTEGER | Display order |

**Sample Data:**
| name | slug | parent_id |
|------|------|-----------|
| Pickles | pickles | NULL |
| Chutneys | chutneys | NULL |
| Powders | powders | NULL |
| Combo Packs | combo-packs | NULL |
| Vegetarian Pickles | vegetarian-pickles | (pickles id) |
| Non-Veg Pickles | non-veg-pickles | (pickles id) |

---

### 3.4 products

```sql
CREATE TABLE products (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(255) NOT NULL,
    slug            VARCHAR(255) NOT NULL UNIQUE,
    description     TEXT,
    short_desc      VARCHAR(500),
    category_id     UUID NOT NULL REFERENCES categories(id),
    base_price      DECIMAL(10, 2) NOT NULL,
    images          JSONB DEFAULT '[]',
    is_veg          BOOLEAN DEFAULT TRUE,
    ingredients     TEXT[],
    nutrition_info  JSONB,
    shelf_life      VARCHAR(100),
    storage_info    VARCHAR(255),
    fssai_license   VARCHAR(50),
    is_active       BOOLEAN DEFAULT TRUE,
    is_featured     BOOLEAN DEFAULT FALSE,
    avg_rating      DECIMAL(2, 1) DEFAULT 0,
    review_count    INTEGER DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_products_slug ON products(slug);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_products_featured ON products(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_products_rating ON products(avg_rating DESC);

-- Full-text search
CREATE INDEX idx_products_search ON products USING GIN (to_tsvector('english', name || ' ' || COALESCE(description, '')));
```

**Field Descriptions:**
| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| name | VARCHAR(255) | Product name |
| slug | VARCHAR(255) | URL-friendly identifier |
| description | TEXT | Full product description |
| short_desc | VARCHAR(500) | Short description for listings |
| category_id | UUID | Reference to category |
| base_price | DECIMAL | Starting price |
| images | JSONB | Array of image URLs |
| is_veg | BOOLEAN | Vegetarian indicator |
| ingredients | TEXT[] | List of ingredients |
| nutrition_info | JSONB | Nutritional information |
| shelf_life | VARCHAR(100) | Product shelf life |
| storage_info | VARCHAR(255) | Storage instructions |
| fssai_license | VARCHAR(50) | FSSAI license number |
| is_active | BOOLEAN | Product availability |
| is_featured | BOOLEAN | Featured on home |
| avg_rating | DECIMAL | Average customer rating |
| review_count | INTEGER | Number of reviews |

**JSONB Structures:**

```json
// images
[
    "https://cdn.gongura-griha.com/products/pickle1-main.jpg",
    "https://cdn.gongura-griha.com/products/pickle1-side1.jpg",
    "https://cdn.gongura-griha.com/products/pickle1-side2.jpg"
]

// nutrition_info
{
    "serving_size": "30g",
    "calories": 45,
    "total_fat": "3.5g",
    "saturated_fat": "0.5g",
    "sodium": "450mg",
    "total_carbs": "2g",
    "protein": "1g"
}
```

---

### 3.5 product_variants

```sql
CREATE TABLE product_variants (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id      UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    name            VARCHAR(100) NOT NULL,
    sku             VARCHAR(50) NOT NULL UNIQUE,
    size            VARCHAR(50),
    spice_level     VARCHAR(20) CHECK (spice_level IN ('mild', 'medium', 'hot', 'extra_hot')),
    price           DECIMAL(10, 2) NOT NULL,
    mrp             DECIMAL(10, 2),
    stock           INTEGER DEFAULT 0,
    low_stock_alert INTEGER DEFAULT 10,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_variants_product ON product_variants(product_id);
CREATE INDEX idx_variants_sku ON product_variants(sku);
CREATE INDEX idx_variants_stock ON product_variants(stock) WHERE stock <= low_stock_alert;
```

**Field Descriptions:**
| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| product_id | UUID | Reference to product |
| name | VARCHAR(100) | Variant display name (e.g., "500g - Medium") |
| sku | VARCHAR(50) | Stock Keeping Unit |
| size | VARCHAR(50) | Size (250g, 500g, 1kg) |
| spice_level | VARCHAR(20) | Spice level option |
| price | DECIMAL | Selling price |
| mrp | DECIMAL | Maximum retail price (for showing discounts) |
| stock | INTEGER | Current stock quantity |
| low_stock_alert | INTEGER | Threshold for low stock notification |
| is_active | BOOLEAN | Variant availability |

**Sample Data:**
| product_id | name | sku | size | spice_level | price | mrp | stock |
|------------|------|-----|------|-------------|-------|-----|-------|
| (gongura-classic) | 250g - Medium | GC-250-MED | 250g | medium | 199 | 249 | 100 |
| (gongura-classic) | 500g - Medium | GC-500-MED | 500g | medium | 349 | 449 | 75 |
| (gongura-classic) | 500g - Hot | GC-500-HOT | 500g | hot | 349 | 449 | 50 |

---

### 3.6 carts

```sql
CREATE TABLE carts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
    session_id      VARCHAR(255),  -- For guest carts
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Either user_id or session_id must be present
    CONSTRAINT cart_owner CHECK (user_id IS NOT NULL OR session_id IS NOT NULL)
);

-- Indexes
CREATE UNIQUE INDEX idx_carts_user ON carts(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_carts_session ON carts(session_id) WHERE session_id IS NOT NULL;
```

---

### 3.7 cart_items

```sql
CREATE TABLE cart_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id         UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id      UUID NOT NULL REFERENCES products(id),
    variant_id      UUID NOT NULL REFERENCES product_variants(id),
    quantity        INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0 AND quantity <= 10),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Unique constraint: same variant can't be added twice
    UNIQUE(cart_id, variant_id)
);

-- Indexes
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
```

---

### 3.8 wishlists

```sql
CREATE TABLE wishlists (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id      UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, product_id)
);

-- Indexes
CREATE INDEX idx_wishlists_user ON wishlists(user_id);
```

---

### 3.9 coupons

```sql
CREATE TABLE coupons (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(50) NOT NULL UNIQUE,
    description     VARCHAR(255),
    discount_type   VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value  DECIMAL(10, 2) NOT NULL,
    min_order_value DECIMAL(10, 2) DEFAULT 0,
    max_discount    DECIMAL(10, 2),
    usage_limit     INTEGER,
    used_count      INTEGER DEFAULT 0,
    user_limit      INTEGER DEFAULT 1,
    valid_from      TIMESTAMP WITH TIME ZONE NOT NULL,
    valid_until     TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_coupons_code ON coupons(code);
CREATE INDEX idx_coupons_active ON coupons(is_active, valid_from, valid_until);
```

---

### 3.10 orders

```sql
CREATE TABLE orders (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number    VARCHAR(20) NOT NULL UNIQUE,
    user_id         UUID REFERENCES users(id),

    -- Guest order info
    guest_name      VARCHAR(100),
    guest_email     VARCHAR(255),
    guest_phone     VARCHAR(15),

    -- Shipping address (denormalized for historical accuracy)
    shipping_name   VARCHAR(100) NOT NULL,
    shipping_phone  VARCHAR(15) NOT NULL,
    shipping_address_line_1 VARCHAR(255) NOT NULL,
    shipping_address_line_2 VARCHAR(255),
    shipping_landmark VARCHAR(255),
    shipping_city   VARCHAR(100) NOT NULL,
    shipping_state  VARCHAR(100) NOT NULL,
    shipping_pin_code VARCHAR(10) NOT NULL,

    -- Order totals
    subtotal        DECIMAL(10, 2) NOT NULL,
    discount        DECIMAL(10, 2) DEFAULT 0,
    coupon_code     VARCHAR(50),
    delivery_charge DECIMAL(10, 2) DEFAULT 0,
    tax             DECIMAL(10, 2) DEFAULT 0,
    total           DECIMAL(10, 2) NOT NULL,

    -- Status
    status          VARCHAR(30) DEFAULT 'pending' CHECK (status IN (
                        'pending', 'confirmed', 'processing', 'packed',
                        'shipped', 'out_for_delivery', 'delivered',
                        'cancelled', 'returned'
                    )),

    -- Payment
    payment_method  VARCHAR(30) CHECK (payment_method IN (
                        'upi', 'card', 'netbanking', 'wallet', 'cod'
                    )),
    payment_status  VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN (
                        'pending', 'paid', 'failed', 'refunded'
                    )),
    razorpay_order_id   VARCHAR(100),
    razorpay_payment_id VARCHAR(100),
    razorpay_signature  VARCHAR(255),

    -- Delivery
    tracking_number VARCHAR(100),
    delivery_partner VARCHAR(50),
    estimated_delivery DATE,
    delivered_at    TIMESTAMP WITH TIME ZONE,

    -- Notes
    customer_notes  TEXT,
    admin_notes     TEXT,

    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_number ON orders(order_number);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_created ON orders(created_at DESC);
```

**Order Number Format:** `GG` + `YYYYMMDD` + `XXXXX` (random)
Example: `GG20241229A1B2C`

---

### 3.11 order_items

```sql
CREATE TABLE order_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id        UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id      UUID NOT NULL REFERENCES products(id),
    variant_id      UUID NOT NULL REFERENCES product_variants(id),

    -- Denormalized for historical accuracy
    product_name    VARCHAR(255) NOT NULL,
    variant_name    VARCHAR(100) NOT NULL,
    product_image   VARCHAR(500),

    quantity        INTEGER NOT NULL,
    price           DECIMAL(10, 2) NOT NULL,  -- Unit price at time of order
    total           DECIMAL(10, 2) NOT NULL,  -- quantity * price

    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_order_items_order ON order_items(order_id);
```

---

### 3.12 order_status_history

```sql
CREATE TABLE order_status_history (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id        UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status          VARCHAR(30) NOT NULL,
    notes           TEXT,
    created_by      UUID REFERENCES users(id),  -- Admin who changed status
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_order_history_order ON order_status_history(order_id);
CREATE INDEX idx_order_history_created ON order_status_history(created_at);
```

---

### 3.13 reviews

```sql
CREATE TABLE reviews (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    product_id      UUID NOT NULL REFERENCES products(id),
    order_id        UUID REFERENCES orders(id),
    rating          INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title           VARCHAR(255),
    comment         TEXT,
    images          JSONB DEFAULT '[]',
    is_verified     BOOLEAN DEFAULT FALSE,  -- Purchased & delivered
    is_approved     BOOLEAN DEFAULT TRUE,   -- Moderation status
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- One review per product per user
    UNIQUE(user_id, product_id)
);

-- Indexes
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_verified ON reviews(is_verified) WHERE is_verified = TRUE;
```

---

### 3.14 otp_codes

```sql
CREATE TABLE otp_codes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone           VARCHAR(15) NOT NULL,
    code            VARCHAR(6) NOT NULL,
    purpose         VARCHAR(20) NOT NULL CHECK (purpose IN ('login', 'register', 'reset_password')),
    attempts        INTEGER DEFAULT 0,
    is_used         BOOLEAN DEFAULT FALSE,
    expires_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_otp_phone ON otp_codes(phone);
CREATE INDEX idx_otp_expires ON otp_codes(expires_at);

-- Auto-cleanup old OTPs
-- (Implement via cron job or database trigger)
```

---

### 3.15 notifications

```sql
CREATE TABLE notifications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
    title           VARCHAR(255) NOT NULL,
    body            TEXT NOT NULL,
    type            VARCHAR(30) CHECK (type IN (
                        'order_update', 'promotional', 'system', 'reminder'
                    )),
    data            JSONB,
    is_read         BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
```

---

### 3.16 banners

```sql
CREATE TABLE banners (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title           VARCHAR(255),
    image_url       VARCHAR(500) NOT NULL,
    link_type       VARCHAR(20) CHECK (link_type IN ('product', 'category', 'external', 'none')),
    link_value      VARCHAR(500),
    position        VARCHAR(20) DEFAULT 'home' CHECK (position IN ('home', 'category', 'checkout')),
    sort_order      INTEGER DEFAULT 0,
    is_active       BOOLEAN DEFAULT TRUE,
    starts_at       TIMESTAMP WITH TIME ZONE,
    ends_at         TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_banners_active ON banners(is_active, position);
```

---

## 4. Database Functions & Triggers

### 4.1 Update Timestamp Trigger

```sql
-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ... (apply to other tables)
```

### 4.2 Update Product Rating

```sql
-- Function to update product average rating
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET
        avg_rating = (SELECT COALESCE(AVG(rating), 0) FROM reviews WHERE product_id = NEW.product_id AND is_approved = TRUE),
        review_count = (SELECT COUNT(*) FROM reviews WHERE product_id = NEW.product_id AND is_approved = TRUE)
    WHERE id = NEW.product_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_rating_on_review AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_product_rating();
```

### 4.3 Generate Order Number

```sql
-- Function to generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number = 'GG' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') ||
                       UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 5));
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER set_order_number BEFORE INSERT ON orders
    FOR EACH ROW EXECUTE FUNCTION generate_order_number();
```

---

## 5. Sample Seed Data

```sql
-- Categories
INSERT INTO categories (name, slug, description, sort_order) VALUES
('Pickles', 'pickles', 'Traditional gongura pickles', 1),
('Chutneys', 'chutneys', 'Fresh gongura chutneys', 2),
('Powders', 'powders', 'Gongura spice powders', 3),
('Combo Packs', 'combo-packs', 'Value combo packs', 4);

-- Sample Product
INSERT INTO products (name, slug, description, short_desc, category_id, base_price, is_veg, ingredients, shelf_life, storage_info)
VALUES (
    'Gongura Classic Pickle',
    'gongura-classic-pickle',
    'Our signature gongura pickle made with fresh gongura leaves, traditional spices, and pure cold-pressed oil. A perfect blend of tangy and spicy flavors that brings back the authentic taste of Andhra cuisine.',
    'Traditional Andhra-style gongura pickle with authentic spices',
    (SELECT id FROM categories WHERE slug = 'pickles'),
    199.00,
    TRUE,
    ARRAY['Gongura leaves', 'Red chilies', 'Garlic', 'Mustard seeds', 'Fenugreek seeds', 'Cold-pressed oil', 'Salt'],
    '6 months',
    'Store in a cool, dry place. Refrigerate after opening.'
);
```

---

## 6. Backup & Recovery

### 6.1 Backup Schedule
- **Full backup:** Daily at 2:00 AM IST
- **Incremental backup:** Every 6 hours
- **Retention:** 30 days

### 6.2 Backup Commands
```bash
# Full backup
pg_dump -Fc gongura_griha > backup_$(date +%Y%m%d).dump

# Restore
pg_restore -d gongura_griha backup_20241229.dump
```

---

*Document maintained by: Gongura-Griha Development Team*
