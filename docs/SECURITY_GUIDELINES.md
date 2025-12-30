# Gongura-Griha: Security Guidelines

> **Document Status:** Sacred - Must be followed for all implementation decisions
> **Version:** 1.0.0
> **Last Updated:** December 2024

---

## 1. Security Overview

### 1.1 Security Principles

1. **Defense in Depth** - Multiple layers of security
2. **Least Privilege** - Minimum permissions necessary
3. **Secure by Default** - Security enabled out of the box
4. **Fail Secure** - Failures should not compromise security
5. **Complete Mediation** - Validate all access attempts

### 1.2 Compliance Requirements

| Standard | Requirement |
|----------|-------------|
| PCI DSS | Payment data handling |
| IT Act 2000 | Indian data protection |
| OWASP Top 10 | Web application security |
| FSSAI | Food safety compliance |

---

## 2. Authentication Security

### 2.1 OTP Authentication

```javascript
// OTP Generation
const crypto = require('crypto');

function generateOTP() {
  // Generate cryptographically secure 6-digit OTP
  const otp = crypto.randomInt(100000, 999999).toString();
  return otp;
}

// OTP Storage
async function storeOTP(phone, otp) {
  const hashedOTP = await bcrypt.hash(otp, 10);
  await redis.setex(
    `otp:${phone}`,
    300, // 5 minutes expiry
    JSON.stringify({
      hash: hashedOTP,
      attempts: 0,
      createdAt: Date.now(),
    })
  );
}

// OTP Verification
async function verifyOTP(phone, inputOTP) {
  const otpData = await redis.get(`otp:${phone}`);

  if (!otpData) {
    throw new Error('OTP expired');
  }

  const { hash, attempts } = JSON.parse(otpData);

  // Rate limiting
  if (attempts >= 3) {
    await redis.del(`otp:${phone}`);
    throw new Error('Too many attempts');
  }

  // Update attempts
  await redis.setex(
    `otp:${phone}`,
    await redis.ttl(`otp:${phone}`),
    JSON.stringify({ ...JSON.parse(otpData), attempts: attempts + 1 })
  );

  // Verify
  const isValid = await bcrypt.compare(inputOTP, hash);

  if (isValid) {
    await redis.del(`otp:${phone}`);
    return true;
  }

  throw new Error('Invalid OTP');
}
```

### 2.2 JWT Token Security

```javascript
// Token Generation
const jwt = require('jsonwebtoken');

function generateTokens(userId) {
  const accessToken = jwt.sign(
    { userId, type: 'access' },
    process.env.JWT_ACCESS_SECRET,
    { expiresIn: '15m' }
  );

  const refreshToken = jwt.sign(
    { userId, type: 'refresh' },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: '7d' }
  );

  return { accessToken, refreshToken };
}

// Token Verification Middleware
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_ACCESS_SECRET);

    if (decoded.type !== 'access') {
      return res.status(401).json({ error: 'Invalid token type' });
    }

    req.userId = decoded.userId;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    return res.status(403).json({ error: 'Invalid token' });
  }
}
```

### 2.3 Token Storage (Flutter)

```dart
// Secure storage for tokens
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
```

---

## 3. API Security

### 3.1 HTTPS/TLS

**Requirements:**
- TLS 1.3 minimum
- Strong cipher suites only
- HSTS enabled
- Certificate pinning for mobile apps

```dart
// Certificate pinning in Flutter
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';

Dio createSecureClient() {
  final dio = Dio();

  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();

    client.badCertificateCallback = (cert, host, port) {
      // In production, validate against known certificate
      final validFingerprints = [
        'AA:BB:CC:DD:EE:FF:...', // SHA-256 fingerprint
      ];

      final certFingerprint = cert.sha256Fingerprint;
      return validFingerprints.contains(certFingerprint);
    };

    return client;
  };

  return dio;
}
```

### 3.2 Rate Limiting

```javascript
// Rate limiting middleware
const rateLimit = require('express-rate-limit');
const RedisStore = require('rate-limit-redis');

// General API rate limit
const apiLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'rl:api:',
  }),
  windowMs: 60 * 1000, // 1 minute
  max: 100, // 100 requests per minute
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many requests, please try again later',
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Strict rate limit for authentication
const authLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'rl:auth:',
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per 15 minutes
  message: {
    success: false,
    error: {
      code: 'AUTH_RATE_LIMIT',
      message: 'Too many login attempts, please try again later',
    },
  },
});

// OTP rate limit
const otpLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'rl:otp:',
  }),
  windowMs: 60 * 1000, // 1 minute
  max: 1, // 1 OTP per minute per IP
  keyGenerator: (req) => req.body.phone || req.ip,
});

app.use('/api/v1', apiLimiter);
app.use('/api/v1/auth/login', authLimiter);
app.use('/api/v1/auth/otp/send', otpLimiter);
```

### 3.3 Input Validation

```javascript
// Using Joi for validation
const Joi = require('joi');

const schemas = {
  // Phone validation
  phone: Joi.string()
    .pattern(/^\+91[6-9]\d{9}$/)
    .required()
    .messages({
      'string.pattern.base': 'Invalid Indian phone number',
    }),

  // OTP validation
  otp: Joi.string()
    .length(6)
    .pattern(/^\d+$/)
    .required(),

  // Email validation
  email: Joi.string()
    .email()
    .lowercase()
    .max(255),

  // Name validation
  name: Joi.string()
    .min(2)
    .max(100)
    .pattern(/^[a-zA-Z\s]+$/)
    .trim(),

  // PIN code validation
  pinCode: Joi.string()
    .pattern(/^[1-9][0-9]{5}$/)
    .required(),

  // Quantity validation
  quantity: Joi.number()
    .integer()
    .min(1)
    .max(10)
    .required(),

  // Price validation (for admin)
  price: Joi.number()
    .positive()
    .precision(2)
    .max(99999.99),

  // UUID validation
  uuid: Joi.string()
    .uuid({ version: 'uuidv4' }),
};

// Validation middleware
function validate(schema) {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));

      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          details: errors,
        },
      });
    }

    req.body = value;
    next();
  };
}
```

### 3.4 SQL Injection Prevention

```javascript
// Using Prisma ORM (parameterized queries by default)
const products = await prisma.product.findMany({
  where: {
    name: {
      contains: searchTerm, // Automatically escaped
    },
    category: {
      slug: categorySlug, // Automatically escaped
    },
  },
});

// NEVER do this:
// const query = `SELECT * FROM products WHERE name LIKE '%${searchTerm}%'`;

// For raw queries (avoid if possible)
const result = await prisma.$queryRaw`
  SELECT * FROM products
  WHERE name ILIKE ${`%${searchTerm}%`}
  AND category_id = ${categoryId}
`;
```

### 3.5 XSS Prevention

```javascript
// Sanitize HTML content
const sanitizeHtml = require('sanitize-html');

function sanitizeInput(input) {
  return sanitizeHtml(input, {
    allowedTags: [], // No HTML allowed
    allowedAttributes: {},
  });
}

// Response headers
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; img-src 'self' https://cdn.gongura-griha.com"
  );
  next();
});
```

---

## 4. Data Security

### 4.1 Password Hashing

```javascript
const bcrypt = require('bcrypt');

const SALT_ROUNDS = 12;

async function hashPassword(password) {
  return await bcrypt.hash(password, SALT_ROUNDS);
}

async function verifyPassword(password, hash) {
  return await bcrypt.compare(password, hash);
}
```

### 4.2 Sensitive Data Encryption

```javascript
const crypto = require('crypto');

const ENCRYPTION_KEY = Buffer.from(process.env.ENCRYPTION_KEY, 'hex'); // 32 bytes
const IV_LENGTH = 16;

function encrypt(text) {
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv('aes-256-gcm', ENCRYPTION_KEY, iv);

  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');

  const authTag = cipher.getAuthTag().toString('hex');

  return `${iv.toString('hex')}:${authTag}:${encrypted}`;
}

function decrypt(encryptedText) {
  const [ivHex, authTagHex, encrypted] = encryptedText.split(':');

  const iv = Buffer.from(ivHex, 'hex');
  const authTag = Buffer.from(authTagHex, 'hex');
  const decipher = crypto.createDecipheriv('aes-256-gcm', ENCRYPTION_KEY, iv);

  decipher.setAuthTag(authTag);

  let decrypted = decipher.update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}

// Encrypt sensitive fields before storage
async function storePaymentMethod(userId, cardData) {
  const encryptedCard = encrypt(JSON.stringify({
    last4: cardData.last4,
    expiry: cardData.expiry,
  }));

  await prisma.paymentMethod.create({
    data: {
      userId,
      encryptedData: encryptedCard,
      // Never store full card number
    },
  });
}
```

### 4.3 Data Masking

```javascript
// Mask phone number
function maskPhone(phone) {
  // +919876543210 -> +91****543210
  return phone.replace(/(\+91)(\d{4})(\d{6})/, '$1****$3');
}

// Mask email
function maskEmail(email) {
  // user@example.com -> u***@example.com
  const [local, domain] = email.split('@');
  return `${local[0]}***@${domain}`;
}

// Mask card number
function maskCard(cardNumber) {
  // 4111111111111111 -> ****1111
  return `****${cardNumber.slice(-4)}`;
}
```

### 4.4 Secure Logging

```javascript
// Sanitize logs to remove sensitive data
function sanitizeForLogging(data) {
  const sensitiveFields = [
    'password',
    'otp',
    'accessToken',
    'refreshToken',
    'cardNumber',
    'cvv',
  ];

  const sanitized = { ...data };

  for (const field of sensitiveFields) {
    if (sanitized[field]) {
      sanitized[field] = '[REDACTED]';
    }
  }

  // Mask phone and email
  if (sanitized.phone) {
    sanitized.phone = maskPhone(sanitized.phone);
  }
  if (sanitized.email) {
    sanitized.email = maskEmail(sanitized.email);
  }

  return sanitized;
}

// Usage
logger.info('User login attempt', sanitizeForLogging(requestBody));
```

---

## 5. Payment Security

### 5.1 PCI DSS Compliance

**Key Requirements:**
- Never store full card numbers
- Never store CVV
- Use tokenization (Razorpay handles this)
- Verify payment signatures server-side
- Use HTTPS for all payment communications

### 5.2 Payment Verification

```javascript
// ALWAYS verify payment server-side
async function verifyPayment(orderId, paymentData) {
  const { razorpayPaymentId, razorpayOrderId, razorpaySignature } = paymentData;

  // 1. Verify signature
  const body = razorpayOrderId + '|' + razorpayPaymentId;
  const expectedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(body)
    .digest('hex');

  if (expectedSignature !== razorpaySignature) {
    throw new SecurityError('Invalid payment signature');
  }

  // 2. Verify with Razorpay API
  const payment = await razorpay.payments.fetch(razorpayPaymentId);

  if (payment.status !== 'captured') {
    throw new SecurityError('Payment not captured');
  }

  // 3. Verify amount matches order
  const order = await getOrder(orderId);
  if (payment.amount !== order.total * 100) {
    throw new SecurityError('Payment amount mismatch');
  }

  // 4. Update order
  await updateOrderPayment(orderId, {
    paymentStatus: 'paid',
    razorpayPaymentId,
  });
}
```

### 5.3 Refund Security

```javascript
// Secure refund process
async function processRefund(orderId, adminUserId) {
  // 1. Verify admin authorization
  const admin = await verifyAdminPermission(adminUserId, 'process_refund');

  // 2. Verify order is eligible for refund
  const order = await getOrder(orderId);

  if (order.paymentStatus !== 'paid') {
    throw new Error('Order not paid');
  }

  if (order.status === 'refunded') {
    throw new Error('Already refunded');
  }

  // 3. Process refund via Razorpay
  const refund = await razorpay.payments.refund(order.razorpayPaymentId, {
    amount: order.total * 100,
    notes: {
      orderId,
      processedBy: adminUserId,
    },
  });

  // 4. Log refund action
  await auditLog.create({
    action: 'REFUND_PROCESSED',
    orderId,
    adminUserId,
    amount: order.total,
    refundId: refund.id,
  });

  return refund;
}
```

---

## 6. Mobile App Security

### 6.1 Secure Storage

```dart
// Never store sensitive data in SharedPreferences
// Use flutter_secure_storage instead

// BAD - Insecure
SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setString('auth_token', token); // Don't do this!

// GOOD - Secure
const storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);
```

### 6.2 Root/Jailbreak Detection

```dart
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

Future<bool> isDeviceSecure() async {
  final isJailbroken = await FlutterJailbreakDetection.jailbroken;
  final isDeveloperMode = await FlutterJailbreakDetection.developerMode;

  if (isJailbroken) {
    // Log security event
    // Optionally restrict functionality
    return false;
  }

  return true;
}
```

### 6.3 Obfuscation

```yaml
# android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

```bash
# Build with obfuscation
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

### 6.4 Secure Network Configuration

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    <domain-config>
        <domain includeSubdomains="true">api.gongura-griha.com</domain>
        <pin-set>
            <pin digest="SHA-256">XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=</pin>
            <pin digest="SHA-256">YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY=</pin>
        </pin-set>
    </domain-config>
</network-security-config>
```

---

## 7. Environment Security

### 7.1 Secret Management

```bash
# .env.example (commit this)
DATABASE_URL=
REDIS_URL=
JWT_ACCESS_SECRET=
JWT_REFRESH_SECRET=
RAZORPAY_KEY_ID=
RAZORPAY_KEY_SECRET=
ENCRYPTION_KEY=

# .env (never commit)
DATABASE_URL=postgresql://user:pass@host:5432/db
# ... actual values
```

### 7.2 Environment Variables

```javascript
// Validate required environment variables at startup
const requiredEnvVars = [
  'DATABASE_URL',
  'REDIS_URL',
  'JWT_ACCESS_SECRET',
  'JWT_REFRESH_SECRET',
  'RAZORPAY_KEY_ID',
  'RAZORPAY_KEY_SECRET',
  'ENCRYPTION_KEY',
];

for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    console.error(`Missing required environment variable: ${envVar}`);
    process.exit(1);
  }
}
```

### 7.3 Secret Rotation

**Rotation Schedule:**
| Secret | Rotation Frequency |
|--------|-------------------|
| JWT Access Secret | 90 days |
| JWT Refresh Secret | 90 days |
| Encryption Key | 180 days |
| API Keys | 90 days |
| Database Password | 90 days |

---

## 8. Audit & Monitoring

### 8.1 Security Audit Logging

```javascript
// Audit log for security events
async function auditLog(event) {
  await prisma.auditLog.create({
    data: {
      timestamp: new Date(),
      eventType: event.type,
      userId: event.userId,
      ipAddress: event.ip,
      userAgent: event.userAgent,
      resource: event.resource,
      action: event.action,
      status: event.status,
      details: event.details,
    },
  });
}

// Log security events
auditLog({
  type: 'AUTH_SUCCESS',
  userId: user.id,
  ip: req.ip,
  userAgent: req.headers['user-agent'],
  resource: 'auth',
  action: 'login',
  status: 'success',
});

auditLog({
  type: 'AUTH_FAILURE',
  ip: req.ip,
  userAgent: req.headers['user-agent'],
  resource: 'auth',
  action: 'login',
  status: 'failure',
  details: { reason: 'invalid_otp' },
});
```

### 8.2 Security Alerts

**Alert Triggers:**
- Multiple failed login attempts (>5 in 15 min)
- Unusual payment patterns
- API rate limit breaches
- Unauthorized access attempts
- Database query anomalies

### 8.3 Security Headers Check

```javascript
// Verify security headers in responses
const securityHeaders = {
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block',
  'Content-Security-Policy': "default-src 'self'",
  'Referrer-Policy': 'strict-origin-when-cross-origin',
};

app.use((req, res, next) => {
  Object.entries(securityHeaders).forEach(([header, value]) => {
    res.setHeader(header, value);
  });
  next();
});
```

---

## 9. Security Checklist

### 9.1 Pre-Launch Checklist

**Authentication:**
- [ ] OTP rate limiting implemented
- [ ] JWT tokens properly signed and verified
- [ ] Refresh token rotation working
- [ ] Session management secure
- [ ] Password hashing with bcrypt (salt rounds ≥12)

**API Security:**
- [ ] HTTPS enforced (TLS 1.3)
- [ ] Rate limiting on all endpoints
- [ ] Input validation on all inputs
- [ ] SQL injection prevention verified
- [ ] XSS prevention verified
- [ ] CORS properly configured

**Payment:**
- [ ] Payment signature verification implemented
- [ ] No sensitive card data stored
- [ ] Webhook signature verification
- [ ] Amount verification on server-side

**Data:**
- [ ] Sensitive data encrypted at rest
- [ ] Database credentials secured
- [ ] Logs sanitized of sensitive data
- [ ] Backups encrypted

**Mobile:**
- [ ] Secure storage for tokens
- [ ] Certificate pinning enabled
- [ ] Obfuscation enabled for release
- [ ] Root/jailbreak detection (optional)

**Infrastructure:**
- [ ] Environment variables secured
- [ ] Secrets not in code repository
- [ ] Security headers configured
- [ ] Error messages don't leak info

---

## 10. Incident Response

### 10.1 Security Incident Procedure

1. **Identify** - Detect and confirm the incident
2. **Contain** - Limit the damage
3. **Eradicate** - Remove the threat
4. **Recover** - Restore normal operations
5. **Learn** - Document and improve

### 10.2 Contact Information

**Security Team:** security@gongura-griha.com
**Emergency:** [Phone number]

---

*Document maintained by: Gongura-Griha Development Team*
