# Gongura-Griha: API Specifications

> **Document Status:** Sacred - Must be followed for all implementation decisions
> **Version:** 1.0.0
> **Last Updated:** December 2024

---

## 1. API Overview

### 1.1 Base URL
```
Production:  https://api.gongura-griha.com/v1
Staging:     https://staging-api.gongura-griha.com/v1
Development: http://localhost:3000/v1
```

### 1.2 API Standards
- **Protocol:** HTTPS (TLS 1.3)
- **Format:** JSON
- **Authentication:** Bearer Token (JWT)
- **Versioning:** URL path versioning (`/v1/`)
- **Rate Limiting:** 100 requests/minute per user

### 1.3 Common Headers

**Request Headers:**
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer <access_token>
X-Device-ID: <device_unique_id>
X-App-Version: 1.0.0
X-Platform: android|ios
```

**Response Headers:**
```
Content-Type: application/json
X-Request-ID: <unique_request_id>
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704067200
```

---

## 2. Response Format

### 2.1 Success Response
```json
{
    "success": true,
    "message": "Operation successful",
    "data": {
        // Response data
    },
    "meta": {
        "timestamp": "2024-12-29T10:30:00Z",
        "requestId": "req_abc123xyz"
    }
}
```

### 2.2 Paginated Response
```json
{
    "success": true,
    "message": "Products fetched successfully",
    "data": {
        "items": [...],
        "pagination": {
            "page": 1,
            "limit": 20,
            "total": 150,
            "totalPages": 8,
            "hasNextPage": true,
            "hasPrevPage": false
        }
    }
}
```

### 2.3 Error Response
```json
{
    "success": false,
    "message": "Validation failed",
    "error": {
        "code": "VALIDATION_ERROR",
        "details": [
            {
                "field": "phone",
                "message": "Invalid phone number format"
            }
        ]
    },
    "meta": {
        "timestamp": "2024-12-29T10:30:00Z",
        "requestId": "req_abc123xyz"
    }
}
```

### 2.4 HTTP Status Codes

| Code | Meaning | Usage |
|------|---------|-------|
| 200 | OK | Successful GET, PUT |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Validation errors |
| 401 | Unauthorized | Missing/invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Duplicate resource |
| 422 | Unprocessable Entity | Business logic error |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |

### 2.5 Error Codes

| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Request validation failed |
| `AUTHENTICATION_ERROR` | Invalid credentials |
| `AUTHORIZATION_ERROR` | Insufficient permissions |
| `RESOURCE_NOT_FOUND` | Resource doesn't exist |
| `RESOURCE_EXISTS` | Duplicate resource |
| `RATE_LIMIT_EXCEEDED` | Too many requests |
| `PAYMENT_FAILED` | Payment processing failed |
| `OUT_OF_STOCK` | Product not available |
| `INVALID_COUPON` | Coupon code invalid |
| `INTERNAL_ERROR` | Server error |

---

## 3. Authentication APIs

### 3.1 Send OTP

**Endpoint:** `POST /auth/otp/send`

**Description:** Send OTP to phone number for login/registration.

**Request:**
```json
{
    "phone": "+919876543210",
    "purpose": "login"  // login | register
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "OTP sent successfully",
    "data": {
        "phone": "+919876543210",
        "expiresIn": 300,
        "retryAfter": 30
    }
}
```

**Errors:**
- `400` - Invalid phone format
- `429` - Too many OTP requests

---

### 3.2 Verify OTP

**Endpoint:** `POST /auth/otp/verify`

**Description:** Verify OTP and authenticate user.

**Request:**
```json
{
    "phone": "+919876543210",
    "otp": "123456"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "OTP verified successfully",
    "data": {
        "isNewUser": false,
        "accessToken": "eyJhbGciOiJIUzI1NiIs...",
        "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
        "expiresIn": 900,
        "user": {
            "id": "uuid",
            "name": "Rahul Sharma",
            "phone": "+919876543210",
            "email": "rahul@example.com",
            "avatar": "https://..."
        }
    }
}
```

**Errors:**
- `400` - Invalid OTP
- `400` - OTP expired
- `429` - Too many attempts

---

### 3.3 Register User

**Endpoint:** `POST /auth/register`

**Description:** Complete registration for new users.

**Request:**
```json
{
    "phone": "+919876543210",
    "name": "Rahul Sharma",
    "email": "rahul@example.com"  // optional
}
```

**Headers Required:** `Authorization: Bearer <temp_token_from_otp_verify>`

**Response (201):**
```json
{
    "success": true,
    "message": "Registration successful",
    "data": {
        "accessToken": "eyJhbGciOiJIUzI1NiIs...",
        "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
        "expiresIn": 900,
        "user": {
            "id": "uuid",
            "name": "Rahul Sharma",
            "phone": "+919876543210",
            "email": "rahul@example.com"
        }
    }
}
```

---

### 3.4 Social Login (Google)

**Endpoint:** `POST /auth/social/google`

**Description:** Authenticate via Google OAuth.

**Request:**
```json
{
    "idToken": "google_id_token",
    "phone": "+919876543210"  // optional, for linking
}
```

**Response (200):** Same as OTP verify response.

---

### 3.5 Refresh Token

**Endpoint:** `POST /auth/refresh`

**Description:** Get new access token using refresh token.

**Request:**
```json
{
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "accessToken": "new_access_token",
        "expiresIn": 900
    }
}
```

---

### 3.6 Logout

**Endpoint:** `POST /auth/logout`

**Description:** Invalidate current session.

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
    "success": true,
    "message": "Logged out successfully"
}
```

---

## 4. User APIs

### 4.1 Get Profile

**Endpoint:** `GET /users/profile`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "id": "uuid",
        "name": "Rahul Sharma",
        "phone": "+919876543210",
        "email": "rahul@example.com",
        "avatar": "https://...",
        "isVerified": true,
        "createdAt": "2024-12-01T10:00:00Z"
    }
}
```

---

### 4.2 Update Profile

**Endpoint:** `PUT /users/profile`

**Request:**
```json
{
    "name": "Rahul Kumar Sharma",
    "email": "rahul.new@example.com"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Profile updated successfully",
    "data": {
        "id": "uuid",
        "name": "Rahul Kumar Sharma",
        "email": "rahul.new@example.com",
        ...
    }
}
```

---

### 4.3 Upload Avatar

**Endpoint:** `POST /users/avatar`

**Content-Type:** `multipart/form-data`

**Request:**
```
avatar: <file>
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "avatarUrl": "https://cdn.gongura-griha.com/avatars/uuid.jpg"
    }
}
```

---

## 5. Address APIs

### 5.1 List Addresses

**Endpoint:** `GET /users/addresses`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "addresses": [
            {
                "id": "uuid",
                "name": "Rahul Sharma",
                "phone": "+919876543210",
                "addressLine1": "123, ABC Apartments",
                "addressLine2": "Banjara Hills",
                "landmark": "Near City Center Mall",
                "city": "Hyderabad",
                "state": "Telangana",
                "pinCode": "500034",
                "type": "home",
                "isDefault": true
            }
        ]
    }
}
```

---

### 5.2 Add Address

**Endpoint:** `POST /users/addresses`

**Request:**
```json
{
    "name": "Rahul Sharma",
    "phone": "+919876543210",
    "addressLine1": "456, XYZ Building",
    "addressLine2": "Madhapur",
    "landmark": "Near Inorbit Mall",
    "city": "Hyderabad",
    "state": "Telangana",
    "pinCode": "500081",
    "type": "work",
    "isDefault": false
}
```

**Response (201):** Returns created address object.

---

### 5.3 Update Address

**Endpoint:** `PUT /users/addresses/:id`

**Request:** Same as Add Address.

**Response (200):** Returns updated address object.

---

### 5.4 Delete Address

**Endpoint:** `DELETE /users/addresses/:id`

**Response (204):** No content.

---

### 5.5 Check Serviceability

**Endpoint:** `GET /delivery/check?pinCode=500034`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "serviceable": true,
        "estimatedDays": 3,
        "deliveryCharge": 0,
        "freeDeliveryAbove": 499,
        "codAvailable": true
    }
}
```

---

## 6. Category APIs

### 6.1 List Categories

**Endpoint:** `GET /categories`

**Query Parameters:**
- `active` (boolean) - Filter active only

**Response (200):**
```json
{
    "success": true,
    "data": {
        "categories": [
            {
                "id": "uuid",
                "name": "Pickles",
                "slug": "pickles",
                "description": "Traditional gongura pickles",
                "imageUrl": "https://...",
                "productCount": 15,
                "subcategories": [
                    {
                        "id": "uuid",
                        "name": "Vegetarian",
                        "slug": "vegetarian-pickles",
                        "productCount": 8
                    }
                ]
            }
        ]
    }
}
```

---

## 7. Product APIs

### 7.1 List Products

**Endpoint:** `GET /products`

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | int | Page number (default: 1) |
| `limit` | int | Items per page (default: 20, max: 50) |
| `category` | string | Category slug |
| `search` | string | Search keyword |
| `minPrice` | number | Minimum price |
| `maxPrice` | number | Maximum price |
| `isVeg` | boolean | Vegetarian filter |
| `spiceLevel` | string | mild, medium, hot, extra_hot |
| `sort` | string | popularity, price_asc, price_desc, rating, newest |
| `featured` | boolean | Featured products only |

**Example:** `GET /products?category=pickles&isVeg=true&sort=price_asc&page=1`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "products": [
            {
                "id": "uuid",
                "name": "Gongura Classic Pickle",
                "slug": "gongura-classic-pickle",
                "shortDesc": "Traditional Andhra-style pickle",
                "basePrice": 199.00,
                "images": ["https://..."],
                "isVeg": true,
                "avgRating": 4.5,
                "reviewCount": 120,
                "category": {
                    "id": "uuid",
                    "name": "Pickles",
                    "slug": "pickles"
                },
                "variants": [
                    {
                        "id": "uuid",
                        "name": "250g - Medium",
                        "size": "250g",
                        "spiceLevel": "medium",
                        "price": 199.00,
                        "mrp": 249.00,
                        "inStock": true
                    }
                ],
                "inStock": true
            }
        ],
        "pagination": {
            "page": 1,
            "limit": 20,
            "total": 45,
            "totalPages": 3
        }
    }
}
```

---

### 7.2 Get Product Details

**Endpoint:** `GET /products/:slug`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "id": "uuid",
        "name": "Gongura Classic Pickle",
        "slug": "gongura-classic-pickle",
        "description": "Full product description...",
        "shortDesc": "Traditional Andhra-style pickle",
        "basePrice": 199.00,
        "images": [
            "https://cdn.../main.jpg",
            "https://cdn.../side1.jpg"
        ],
        "isVeg": true,
        "ingredients": [
            "Gongura leaves",
            "Red chilies",
            "Garlic"
        ],
        "nutritionInfo": {
            "servingSize": "30g",
            "calories": 45,
            "totalFat": "3.5g"
        },
        "shelfLife": "6 months",
        "storageInfo": "Store in cool, dry place",
        "fssaiLicense": "12345678901234",
        "avgRating": 4.5,
        "reviewCount": 120,
        "category": {
            "id": "uuid",
            "name": "Pickles",
            "slug": "pickles"
        },
        "variants": [
            {
                "id": "uuid",
                "name": "250g - Medium",
                "sku": "GC-250-MED",
                "size": "250g",
                "spiceLevel": "medium",
                "price": 199.00,
                "mrp": 249.00,
                "stock": 50,
                "inStock": true
            },
            {
                "id": "uuid",
                "name": "500g - Hot",
                "sku": "GC-500-HOT",
                "size": "500g",
                "spiceLevel": "hot",
                "price": 349.00,
                "mrp": 449.00,
                "stock": 25,
                "inStock": true
            }
        ],
        "relatedProducts": [...],
        "frequentlyBoughtTogether": [...]
    }
}
```

---

### 7.3 Search Products

**Endpoint:** `GET /products/search?q=gongura+chicken`

**Response:** Same as List Products.

---

## 8. Cart APIs

### 8.1 Get Cart

**Endpoint:** `GET /cart`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "id": "cart_uuid",
        "items": [
            {
                "id": "cart_item_uuid",
                "product": {
                    "id": "uuid",
                    "name": "Gongura Classic Pickle",
                    "slug": "gongura-classic-pickle",
                    "image": "https://..."
                },
                "variant": {
                    "id": "uuid",
                    "name": "500g - Medium",
                    "size": "500g",
                    "spiceLevel": "medium",
                    "price": 349.00,
                    "mrp": 449.00
                },
                "quantity": 2,
                "lineTotal": 698.00
            }
        ],
        "itemCount": 3,
        "subtotal": 1097.00,
        "discount": 0,
        "deliveryCharge": 0,
        "total": 1097.00
    }
}
```

---

### 8.2 Add to Cart

**Endpoint:** `POST /cart/items`

**Request:**
```json
{
    "productId": "uuid",
    "variantId": "uuid",
    "quantity": 1
}
```

**Response (201):** Returns updated cart.

---

### 8.3 Update Cart Item

**Endpoint:** `PUT /cart/items/:itemId`

**Request:**
```json
{
    "quantity": 3
}
```

**Response (200):** Returns updated cart.

---

### 8.4 Remove from Cart

**Endpoint:** `DELETE /cart/items/:itemId`

**Response (200):** Returns updated cart.

---

### 8.5 Apply Coupon

**Endpoint:** `POST /cart/coupon`

**Request:**
```json
{
    "code": "FIRST100"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Coupon applied successfully",
    "data": {
        "coupon": {
            "code": "FIRST100",
            "discountType": "fixed",
            "discountValue": 100.00
        },
        "cart": {
            "subtotal": 1097.00,
            "discount": 100.00,
            "total": 997.00
        }
    }
}
```

---

### 8.6 Remove Coupon

**Endpoint:** `DELETE /cart/coupon`

**Response (200):** Returns updated cart.

---

## 9. Wishlist APIs

### 9.1 Get Wishlist

**Endpoint:** `GET /wishlist`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "items": [
            {
                "id": "uuid",
                "product": {
                    "id": "uuid",
                    "name": "Mutton Gongura",
                    "slug": "mutton-gongura",
                    "image": "https://...",
                    "basePrice": 399.00,
                    "inStock": true
                },
                "addedAt": "2024-12-28T10:00:00Z"
            }
        ]
    }
}
```

---

### 9.2 Add to Wishlist

**Endpoint:** `POST /wishlist`

**Request:**
```json
{
    "productId": "uuid"
}
```

**Response (201):** Returns added wishlist item.

---

### 9.3 Remove from Wishlist

**Endpoint:** `DELETE /wishlist/:productId`

**Response (204):** No content.

---

## 10. Order APIs

### 10.1 Create Order

**Endpoint:** `POST /orders`

**Request:**
```json
{
    "addressId": "uuid",
    "paymentMethod": "upi",  // upi, card, netbanking, wallet, cod
    "couponCode": "FIRST100",
    "notes": "Please deliver in the morning"
}
```

**Response (201):**
```json
{
    "success": true,
    "data": {
        "order": {
            "id": "uuid",
            "orderNumber": "GG20241229A1B2C",
            "status": "pending",
            "total": 1047.00
        },
        "payment": {
            "razorpayOrderId": "order_abc123",
            "amount": 104700,  // In paise
            "currency": "INR",
            "key": "rzp_live_xxx"
        }
    }
}
```

---

### 10.2 Verify Payment

**Endpoint:** `POST /orders/:orderId/verify-payment`

**Request:**
```json
{
    "razorpayPaymentId": "pay_abc123",
    "razorpayOrderId": "order_abc123",
    "razorpaySignature": "signature_xyz"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Payment verified successfully",
    "data": {
        "order": {
            "id": "uuid",
            "orderNumber": "GG20241229A1B2C",
            "status": "confirmed",
            "paymentStatus": "paid"
        }
    }
}
```

---

### 10.3 List Orders

**Endpoint:** `GET /orders`

**Query Parameters:**
- `status` - Filter by status
- `page`, `limit` - Pagination

**Response (200):**
```json
{
    "success": true,
    "data": {
        "orders": [
            {
                "id": "uuid",
                "orderNumber": "GG20241229A1B2C",
                "status": "shipped",
                "paymentStatus": "paid",
                "total": 1047.00,
                "itemCount": 3,
                "items": [
                    {
                        "productName": "Gongura Classic",
                        "variantName": "500g - Medium",
                        "quantity": 2,
                        "image": "https://..."
                    }
                ],
                "estimatedDelivery": "2025-01-05",
                "createdAt": "2024-12-29T10:00:00Z"
            }
        ],
        "pagination": {...}
    }
}
```

---

### 10.4 Get Order Details

**Endpoint:** `GET /orders/:orderNumber`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "id": "uuid",
        "orderNumber": "GG20241229A1B2C",
        "status": "shipped",
        "paymentStatus": "paid",
        "paymentMethod": "upi",

        "items": [
            {
                "productId": "uuid",
                "productName": "Gongura Classic Pickle",
                "variantName": "500g - Medium",
                "productImage": "https://...",
                "quantity": 2,
                "price": 349.00,
                "total": 698.00
            }
        ],

        "shippingAddress": {
            "name": "Rahul Sharma",
            "phone": "+919876543210",
            "addressLine1": "123, ABC Apartments",
            "city": "Hyderabad",
            "state": "Telangana",
            "pinCode": "500034"
        },

        "subtotal": 1097.00,
        "discount": 100.00,
        "couponCode": "FIRST100",
        "deliveryCharge": 0,
        "tax": 50.00,
        "total": 1047.00,

        "trackingNumber": "DELHIVERY123456",
        "deliveryPartner": "Delhivery",
        "estimatedDelivery": "2025-01-05",

        "statusHistory": [
            {
                "status": "confirmed",
                "timestamp": "2024-12-29T10:30:00Z"
            },
            {
                "status": "processing",
                "timestamp": "2024-12-29T11:00:00Z"
            },
            {
                "status": "packed",
                "timestamp": "2024-12-29T15:00:00Z"
            },
            {
                "status": "shipped",
                "timestamp": "2024-12-30T09:00:00Z",
                "notes": "Tracking: DELHIVERY123456"
            }
        ],

        "createdAt": "2024-12-29T10:00:00Z"
    }
}
```

---

### 10.5 Cancel Order

**Endpoint:** `POST /orders/:orderNumber/cancel`

**Request:**
```json
{
    "reason": "Changed my mind"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Order cancelled successfully",
    "data": {
        "refundStatus": "initiated",
        "refundAmount": 1047.00,
        "estimatedRefundDays": 5
    }
}
```

---

### 10.6 Reorder

**Endpoint:** `POST /orders/:orderNumber/reorder`

**Response (201):** Returns new cart with items from previous order.

---

## 11. Review APIs

### 11.1 List Product Reviews

**Endpoint:** `GET /products/:productId/reviews`

**Query Parameters:**
- `page`, `limit`
- `sort` - recent, rating_high, rating_low, helpful

**Response (200):**
```json
{
    "success": true,
    "data": {
        "summary": {
            "avgRating": 4.5,
            "totalReviews": 120,
            "ratingDistribution": {
                "5": 80,
                "4": 25,
                "3": 10,
                "2": 3,
                "1": 2
            }
        },
        "reviews": [
            {
                "id": "uuid",
                "user": {
                    "name": "Rahul S.",
                    "avatar": "https://..."
                },
                "rating": 5,
                "title": "Authentic taste!",
                "comment": "Reminds me of my grandmother's pickle...",
                "images": ["https://..."],
                "isVerified": true,
                "createdAt": "2024-12-25T10:00:00Z"
            }
        ],
        "pagination": {...}
    }
}
```

---

### 11.2 Add Review

**Endpoint:** `POST /products/:productId/reviews`

**Request:**
```json
{
    "orderId": "uuid",  // For verified purchase badge
    "rating": 5,
    "title": "Amazing product!",
    "comment": "Best gongura pickle I've ever had."
}
```

**Response (201):** Returns created review.

---

### 11.3 Update Review

**Endpoint:** `PUT /reviews/:reviewId`

**Response (200):** Returns updated review.

---

### 11.4 Delete Review

**Endpoint:** `DELETE /reviews/:reviewId`

**Response (204):** No content.

---

## 12. Notification APIs

### 12.1 List Notifications

**Endpoint:** `GET /notifications`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "unreadCount": 3,
        "notifications": [
            {
                "id": "uuid",
                "title": "Order Shipped",
                "body": "Your order #GG20241229A1B2C has been shipped!",
                "type": "order_update",
                "data": {
                    "orderNumber": "GG20241229A1B2C"
                },
                "isRead": false,
                "createdAt": "2024-12-30T09:00:00Z"
            }
        ]
    }
}
```

---

### 12.2 Mark as Read

**Endpoint:** `PUT /notifications/:id/read`

**Response (200):** Success.

---

### 12.3 Mark All as Read

**Endpoint:** `PUT /notifications/read-all`

**Response (200):** Success.

---

### 12.4 Update FCM Token

**Endpoint:** `PUT /users/fcm-token`

**Request:**
```json
{
    "token": "fcm_token_string"
}
```

**Response (200):** Success.

---

## 13. Miscellaneous APIs

### 13.1 Get Home Data

**Endpoint:** `GET /home`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "banners": [...],
        "categories": [...],
        "featuredProducts": [...],
        "newArrivals": [...],
        "bestSellers": [...]
    }
}
```

---

### 13.2 Get App Config

**Endpoint:** `GET /config`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "minAppVersion": "1.0.0",
        "latestAppVersion": "1.2.0",
        "forceUpdate": false,
        "maintenanceMode": false,
        "supportPhone": "+919876543210",
        "supportEmail": "support@gongura-griha.com",
        "socialLinks": {
            "instagram": "https://...",
            "facebook": "https://..."
        },
        "policies": {
            "termsUrl": "https://...",
            "privacyUrl": "https://...",
            "refundUrl": "https://..."
        }
    }
}
```

---

### 13.3 Contact Support

**Endpoint:** `POST /support/contact`

**Request:**
```json
{
    "subject": "Order Issue",
    "message": "I have a problem with my order...",
    "orderNumber": "GG20241229A1B2C"  // optional
}
```

**Response (201):**
```json
{
    "success": true,
    "message": "Support ticket created",
    "data": {
        "ticketId": "TICKET123"
    }
}
```

---

## 14. Webhooks (Backend)

### 14.1 Razorpay Payment Webhook

**Endpoint:** `POST /webhooks/razorpay`

**Events Handled:**
- `payment.captured`
- `payment.failed`
- `refund.processed`

---

*Document maintained by: Gongura-Griha Development Team*
