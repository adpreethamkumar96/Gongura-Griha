# Gongura-Griha: Deployment Guide

> **Document Status:** Sacred - Must be followed for all implementation decisions
> **Version:** 1.0.0
> **Last Updated:** December 2024

---

## 1. Deployment Overview

### 1.1 Environments

| Environment | Purpose | URL |
|-------------|---------|-----|
| Development | Local development | localhost |
| Staging | Testing & QA | staging.gongura-griha.com |
| Production | Live application | gongura-griha.com |

### 1.2 Infrastructure Components

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PRODUCTION INFRASTRUCTURE                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌─────────────────┐                                               │
│   │   CloudFlare    │  CDN, DDoS Protection, SSL                    │
│   └────────┬────────┘                                               │
│            │                                                         │
│            ▼                                                         │
│   ┌─────────────────┐                                               │
│   │  Load Balancer  │  AWS ALB / DigitalOcean LB                    │
│   └────────┬────────┘                                               │
│            │                                                         │
│   ┌────────┴────────┐                                               │
│   │                 │                                                │
│   ▼                 ▼                                                │
│ ┌─────────┐   ┌─────────┐   API Servers (Docker containers)         │
│ │ API 1   │   │ API 2   │   Node.js + Express                       │
│ └────┬────┘   └────┬────┘                                           │
│      │             │                                                 │
│      └──────┬──────┘                                                │
│             │                                                        │
│   ┌─────────┴─────────┐                                             │
│   │                   │                                              │
│   ▼                   ▼                                              │
│ ┌─────────┐     ┌─────────┐                                         │
│ │PostgreSQL│    │  Redis  │  Managed services                       │
│ └─────────┘     └─────────┘                                         │
│                                                                      │
│   ┌─────────┐                                                       │
│   │   S3    │  Static assets, product images                        │
│   └─────────┘                                                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Backend Deployment

### 2.1 Docker Configuration

```dockerfile
# Dockerfile
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Production image
FROM node:20-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Copy from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./
COPY --from=builder /app/prisma ./prisma

# Set permissions
RUN chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

ENV NODE_ENV=production

CMD ["node", "src/index.js"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    depends_on:
      - postgres
      - redis
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  postgres:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_NAME}
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

### 2.2 Database Migration

```bash
# Run migrations in production
npx prisma migrate deploy

# Seed initial data (if needed)
npx prisma db seed
```

### 2.3 Health Check Endpoint

```javascript
// src/routes/health.routes.js
router.get('/health', async (req, res) => {
  try {
    // Check database
    await prisma.$queryRaw`SELECT 1`;

    // Check Redis
    await redis.ping();

    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        database: 'connected',
        cache: 'connected',
      },
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message,
    });
  }
});
```

### 2.4 Environment Variables (Production)

```bash
# .env.production
NODE_ENV=production
PORT=3000

# Database
DATABASE_URL=postgresql://user:password@host:5432/gongura_griha?sslmode=require

# Redis
REDIS_URL=redis://user:password@host:6379

# JWT
JWT_ACCESS_SECRET=<32-character-random-string>
JWT_REFRESH_SECRET=<32-character-random-string>

# Razorpay
RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxx
RAZORPAY_WEBHOOK_SECRET=xxxxxxxxxxxxxxxxxxxx

# Encryption
ENCRYPTION_KEY=<64-character-hex-string>

# SMS (MSG91)
MSG91_AUTH_KEY=xxxxxxxxxxxxxxxxxxxx
MSG91_SENDER_ID=GONGRA
MSG91_TEMPLATE_ID=xxxxxxxxxxxxxxxxxxxx

# Email (SendGrid)
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@gongura-griha.com

# Firebase
FIREBASE_SERVICE_ACCOUNT=<base64-encoded-json>

# AWS S3
AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxx
AWS_S3_BUCKET=gongura-griha-assets
AWS_REGION=ap-south-1

# Logging
LOG_LEVEL=info
```

---

## 3. Flutter App Deployment

### 3.1 App Configuration

```dart
// lib/core/config/app_config.dart
enum Environment { development, staging, production }

class AppConfig {
  static late Environment environment;
  static late String apiBaseUrl;
  static late String razorpayKey;

  static void init(Environment env) {
    environment = env;

    switch (env) {
      case Environment.development:
        apiBaseUrl = 'http://localhost:3000/v1';
        razorpayKey = 'rzp_test_xxxxxxxxxxxx';
        break;
      case Environment.staging:
        apiBaseUrl = 'https://staging-api.gongura-griha.com/v1';
        razorpayKey = 'rzp_test_xxxxxxxxxxxx';
        break;
      case Environment.production:
        apiBaseUrl = 'https://api.gongura-griha.com/v1';
        razorpayKey = 'rzp_live_xxxxxxxxxxxx';
        break;
    }
  }
}
```

```dart
// lib/main_production.dart
void main() {
  AppConfig.init(Environment.production);
  runApp(const GonguraGrihaApp());
}
```

### 3.2 Android Build

#### Signing Configuration

```bash
# Generate keystore (one time)
keytool -genkey -v -keystore gongura-griha.keystore -alias gongura-griha -keyalg RSA -keysize 2048 -validity 10000
```

```groovy
// android/app/build.gradle
android {
    signingConfigs {
        release {
            storeFile file('../keystores/gongura-griha.keystore')
            storePassword System.getenv('KEYSTORE_PASSWORD')
            keyAlias 'gongura-griha'
            keyPassword System.getenv('KEY_PASSWORD')
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    flavorDimensions "environment"
    productFlavors {
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
        }
        production {
            dimension "environment"
        }
    }
}
```

#### Build Commands

```bash
# Build staging APK
flutter build apk --flavor staging --target lib/main_staging.dart

# Build production APK
flutter build apk --flavor production --target lib/main_production.dart --obfuscate --split-debug-info=./debug-info

# Build production App Bundle (for Play Store)
flutter build appbundle --flavor production --target lib/main_production.dart --obfuscate --split-debug-info=./debug-info
```

### 3.3 iOS Build

#### Signing Configuration

1. Create App ID in Apple Developer Portal
2. Create Distribution Certificate
3. Create Provisioning Profile
4. Configure in Xcode

```bash
# Open Xcode
open ios/Runner.xcworkspace
```

Configure signing in Xcode:
- Select Runner project
- Select Runner target
- Signing & Capabilities
- Select Team
- Select Bundle Identifier

#### Build Commands

```bash
# Build staging IPA
flutter build ipa --flavor staging --target lib/main_staging.dart

# Build production IPA
flutter build ipa --flavor production --target lib/main_production.dart --obfuscate --split-debug-info=./debug-info
```

### 3.4 Version Management

```yaml
# pubspec.yaml
name: gongura_griha
version: 1.0.0+1  # version_name+version_code

# Version format:
# MAJOR.MINOR.PATCH+BUILD
# 1.0.0+1 -> First release
# 1.0.1+2 -> Bug fix
# 1.1.0+3 -> New feature
# 2.0.0+4 -> Major update
```

---

## 4. App Store Deployment

### 4.1 Google Play Store

#### Store Listing Requirements

| Asset | Specification |
|-------|---------------|
| App Icon | 512x512 PNG |
| Feature Graphic | 1024x500 PNG |
| Screenshots (Phone) | Min 2, 16:9 or 9:16 |
| Screenshots (Tablet) | Optional, 16:9 or 9:16 |
| Short Description | Max 80 characters |
| Full Description | Max 4000 characters |
| Privacy Policy URL | Required |

#### Deployment Checklist

- [ ] App Bundle (.aab) generated
- [ ] Version code incremented
- [ ] Release notes prepared
- [ ] Screenshots updated (if UI changes)
- [ ] Privacy policy updated
- [ ] Content rating questionnaire completed
- [ ] Target API level meets requirements (API 33+)

#### Play Console Steps

1. Go to Google Play Console
2. Select App → Production → Create new release
3. Upload App Bundle
4. Add release notes
5. Review and rollout

### 4.2 Apple App Store

#### Store Listing Requirements

| Asset | Specification |
|-------|---------------|
| App Icon | 1024x1024 PNG (no alpha) |
| Screenshots (6.7") | 1290x2796 or 2796x1290 |
| Screenshots (6.5") | 1284x2778 or 2778x1284 |
| Screenshots (5.5") | 1242x2208 or 2208x1242 |
| Screenshots (12.9" iPad) | Optional |
| App Preview Video | Optional |
| Description | Max 4000 characters |
| Keywords | Max 100 characters |
| Privacy Policy URL | Required |

#### Deployment Checklist

- [ ] IPA built and validated
- [ ] Build number incremented
- [ ] Screenshots captured
- [ ] App description updated
- [ ] Privacy policy updated
- [ ] Export compliance answered
- [ ] App Review Information provided

#### App Store Connect Steps

1. Open App Store Connect
2. Select App → App Store → Version
3. Upload build via Xcode or Transporter
4. Fill in version information
5. Submit for review

---

## 5. CI/CD Pipeline

### 5.1 GitHub Actions - Backend

```yaml
# .github/workflows/backend-deploy.yml
name: Deploy Backend

on:
  push:
    branches: [main]
    paths:
      - 'backend/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json
      - run: cd backend && npm ci
      - run: cd backend && npm test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: gongura-griha/api:latest,${{ github.sha }}

      - name: Deploy to server
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /app
            docker-compose pull
            docker-compose up -d
            docker system prune -f
```

### 5.2 GitHub Actions - Flutter

```yaml
# .github/workflows/flutter-release.yml
name: Flutter Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.x'
          cache: true

      - name: Decode Keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks

      - name: Build APK
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
        run: |
          flutter pub get
          flutter build apk --release --flavor production --target lib/main_production.dart

      - name: Build App Bundle
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
        run: flutter build appbundle --release --flavor production --target lib/main_production.dart

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.gongura.griha
          releaseFiles: build/app/outputs/bundle/productionRelease/app-production-release.aab
          track: internal  # internal -> alpha -> beta -> production

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.x'
          cache: true

      - name: Install CocoaPods
        run: cd ios && pod install

      - name: Build IPA
        run: flutter build ipa --release --flavor production --target lib/main_production.dart

      - name: Upload to App Store
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: build/ios/ipa/*.ipa
          issuer-id: ${{ secrets.APPLE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPLE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPLE_API_PRIVATE_KEY }}
```

---

## 6. Monitoring & Logging

### 6.1 Application Monitoring

```javascript
// Backend - New Relic / Datadog
const newrelic = require('newrelic');

// Or use custom metrics
const prometheus = require('prom-client');

const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.5, 1, 2, 5],
});

app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });
  next();
});
```

### 6.2 Error Tracking

```dart
// Flutter - Firebase Crashlytics
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const GonguraGrihaApp());
}
```

### 6.3 Log Aggregation

```javascript
// Structured logging
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  defaultMeta: { service: 'gongura-griha-api' },
  transports: [
    new winston.transports.Console(),
    // Add CloudWatch, Datadog, etc.
  ],
});

// Usage
logger.info('Order created', {
  orderId: order.id,
  userId: user.id,
  total: order.total,
});
```

---

## 7. Rollback Procedures

### 7.1 Backend Rollback

```bash
# Docker rollback to previous version
docker-compose pull gongura-griha/api:previous-tag
docker-compose up -d

# Or using specific commit
docker pull gongura-griha/api:abc123
docker-compose up -d
```

### 7.2 Database Rollback

```bash
# Prisma migration rollback
npx prisma migrate resolve --rolled-back 20241229000000_migration_name

# Or restore from backup
pg_restore -d gongura_griha backup_20241228.dump
```

### 7.3 Mobile App Rollback

**Android:**
- Upload previous version APK/AAB to Play Console
- Create new release with previous version
- Staged rollout to ensure stability

**iOS:**
- Cannot directly rollback on App Store
- Submit previous version as new build
- Request expedited review if critical

---

## 8. Backup & Recovery

### 8.1 Database Backups

```bash
# Automated daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="gongura_griha_${DATE}.dump"

# Create backup
pg_dump -Fc $DATABASE_URL > /backups/$BACKUP_FILE

# Upload to S3
aws s3 cp /backups/$BACKUP_FILE s3://gongura-griha-backups/database/

# Cleanup old local backups (keep 7 days)
find /backups -name "*.dump" -mtime +7 -delete

# Cleanup old S3 backups (keep 30 days) - via S3 lifecycle policy
```

### 8.2 Recovery Procedure

```bash
# 1. Stop application
docker-compose down

# 2. Download backup
aws s3 cp s3://gongura-griha-backups/database/gongura_griha_20241228.dump .

# 3. Restore database
pg_restore -d gongura_griha gongura_griha_20241228.dump

# 4. Restart application
docker-compose up -d

# 5. Verify
curl https://api.gongura-griha.com/health
```

---

## 9. Deployment Checklist

### 9.1 Pre-Deployment

- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Security scan completed
- [ ] Performance tested
- [ ] Database migrations tested
- [ ] Environment variables configured
- [ ] Backup created

### 9.2 Deployment

- [ ] Deploy to staging
- [ ] Smoke tests on staging
- [ ] Deploy to production
- [ ] Monitor logs and metrics
- [ ] Verify health endpoints

### 9.3 Post-Deployment

- [ ] Verify all features working
- [ ] Check error rates
- [ ] Monitor performance metrics
- [ ] Update documentation
- [ ] Notify stakeholders

---

## 10. Emergency Contacts

| Role | Contact |
|------|---------|
| DevOps Lead | devops@gongura-griha.com |
| Backend Lead | backend@gongura-griha.com |
| On-Call | oncall@gongura-griha.com |

---

*Document maintained by: Gongura-Griha Development Team*
