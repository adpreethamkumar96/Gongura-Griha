# Store Submission Guide

Step-by-step guide to submit Gongura Griha app to Google Play Store and Apple App Store.

---

## Phase 1: Firebase Deployment (Do This First)

### Step 1: Deploy Firestore Indexes
```bash
cd /Users/rashmisheoran/Downloads/Gongura-Griha
firebase deploy --only firestore:indexes
```
This ensures your database queries work properly.

### Step 2: Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Step 3: Deploy Storage Rules
```bash
firebase deploy --only storage
```

### Step 4: Deploy Cloud Functions
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

> **Note:** If using production Razorpay, set the secret key:
> ```bash
> firebase functions:secrets:set RAZORPAY_KEY_SECRET
> ```

---

## Phase 2: Android (Play Store)

### Step 1: Create Signing Keystore

Run this command in terminal:
```bash
keytool -genkey -v -keystore ~/gongura-griha-release.keystore -alias gongura-griha -keyalg RSA -keysize 2048 -validity 10000
```

It will ask you:
- **Keystore password:** Choose a strong password (save it!)
- **Key password:** Can be same as keystore password
- **First and last name:** Your name
- **Organization unit:** Your team name
- **Organization:** Gongura Griha
- **City:** Hyderabad
- **State:** Telangana
- **Country code:** IN

### Step 2: Create key.properties File

Create file at `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=gongura-griha
storeFile=/Users/rashmisheoran/gongura-griha-release.keystore
```

### Step 3: Build Release AAB

**With Test Razorpay Key (for store approval):**
```bash
cd /Users/rashmisheoran/Downloads/Gongura-Griha
flutter build appbundle --release
```

**With Production Razorpay Key (for live payments):**
```bash
flutter build appbundle --release --dart-define=RAZORPAY_KEY=rzp_live_YOUR_KEY_HERE
```

Output file location:
```
build/app/outputs/bundle/release/app-release.aab
```

### Step 4: Create Play Store Listing

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app → Enter app details
3. Upload your `.aab` file
4. Fill in:
   - **App name:** Gongura Griha
   - **Short description:** Authentic Andhra Gongura Pickles delivered to your doorstep
   - **Full description:** (Describe your products and service)
   - **Screenshots:** (Take from your phone/emulator - minimum 2)
   - **App icon:** 512x512 PNG
   - **Feature graphic:** 1024x500 PNG
5. Complete content rating questionnaire
6. Set pricing (Free)
7. Select countries for distribution
8. Submit for review

### Play Store Requirements Checklist
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Phone screenshots (minimum 2)
- [ ] Tablet screenshots (if supporting tablets)
- [ ] Short description (80 characters max)
- [ ] Full description (4000 characters max)
- [ ] Privacy policy URL
- [ ] Content rating completed
- [ ] Target audience selected
- [ ] App category selected

---

## Phase 3: iOS (App Store)

### Step 1: Prerequisites
- Apple Developer Account ($99/year) - [developer.apple.com](https://developer.apple.com)
- Xcode installed on your Mac
- Valid Apple ID signed into Xcode

### Step 2: Configure Signing in Xcode

1. Open iOS project in Xcode:
```bash
open ios/Runner.xcworkspace
```

2. In Xcode:
   - Select **Runner** in the left sidebar
   - Select **Runner** target
   - Go to **Signing & Capabilities** tab
   - Check **Automatically manage signing**
   - Select your **Team** (Apple Developer account)
   - Bundle Identifier: `com.gongura.gonguraGriha`

### Step 3: Build iOS Release

**With Test Razorpay Key:**
```bash
cd /Users/rashmisheoran/Downloads/Gongura-Griha
flutter build ios --release
```

**With Production Razorpay Key:**
```bash
flutter build ios --release --dart-define=RAZORPAY_KEY=rzp_live_YOUR_KEY_HERE
```

### Step 4: Create Archive in Xcode

1. In Xcode menu: **Product → Archive**
2. Wait for archive to complete
3. **Organizer** window opens automatically
4. Select your archive
5. Click **Distribute App**
6. Select **App Store Connect** → **Upload**
7. Follow prompts to upload

### Step 5: Create App Store Listing

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Fill in app information:
   - **Platform:** iOS
   - **Name:** Gongura Griha
   - **Primary language:** English
   - **Bundle ID:** com.gongura.gonguraGriha
   - **SKU:** gongura-griha-ios

4. Complete App Information:
   - **Subtitle:** Authentic Andhra Pickles
   - **Category:** Food & Drink
   - **Description:** (Your app description)
   - **Keywords:** gongura, pickle, andhra, telugu, indian food
   - **Support URL:** (Your support website/email)
   - **Privacy Policy URL:** (Required - must be publicly accessible)

5. Add Screenshots:
   - iPhone 6.7" (1290 x 2796 or 1284 x 2778)
   - iPhone 6.5" (1242 x 2688 or 1284 x 2778)
   - iPhone 5.5" (1242 x 2208)
   - iPad Pro 12.9" (2048 x 2732) - if supporting iPad

6. Select your uploaded build
7. Complete App Privacy questionnaire
8. Submit for review

### App Store Requirements Checklist
- [ ] App icon (1024x1024 PNG, no alpha)
- [ ] iPhone screenshots (minimum 3 sizes)
- [ ] iPad screenshots (if supporting iPad)
- [ ] App description
- [ ] Keywords
- [ ] Support URL
- [ ] Privacy Policy URL (publicly hosted)
- [ ] App Privacy questionnaire completed
- [ ] Age rating completed
- [ ] Build uploaded and selected

---

## Quick Reference: Build Commands

| Platform | Test Mode | Production Mode |
|----------|-----------|-----------------|
| Android AAB | `flutter build appbundle --release` | `flutter build appbundle --release --dart-define=RAZORPAY_KEY=rzp_live_xxx` |
| Android APK | `flutter build apk --release` | `flutter build apk --release --dart-define=RAZORPAY_KEY=rzp_live_xxx` |
| iOS | `flutter build ios --release` | `flutter build ios --release --dart-define=RAZORPAY_KEY=rzp_live_xxx` |

---

## Output File Locations

| Build Type | Location |
|------------|----------|
| Android AAB | `build/app/outputs/bundle/release/app-release.aab` |
| Android APK | `build/app/outputs/flutter-apk/app-release.apk` |
| iOS | `build/ios/iphoneos/Runner.app` |

---

## Important Warnings

### Keystore Security
⚠️ **CRITICAL:** Save your keystore file and passwords securely!
- Store keystore file in a safe location (not in git)
- Save passwords in a password manager
- If lost, you CANNOT update your app on Play Store

### Razorpay Keys
- **Test Key:** App works, but no real money is processed
- **Live Key:** Required for actual payments
- Switch to live key before accepting real orders

### Privacy Policy
Both stores require a publicly accessible privacy policy URL:
- Host on your website, or
- Use a service like Termly, Iubenda, or GitHub Pages

---

## Submission Timeline

| Store | Review Time | Notes |
|-------|-------------|-------|
| Google Play | 1-3 days | First submission may take longer |
| App Store | 1-7 days | More thorough review process |

---

## Post-Submission Checklist

After approval:
- [ ] Test the live app download
- [ ] Verify all features work
- [ ] Switch to production Razorpay key (when ready for real payments)
- [ ] Monitor Crashlytics for any issues
- [ ] Respond to user reviews

---

## Updating the App

For future updates:

1. Update version in `pubspec.yaml`:
```yaml
version: 1.0.1+2  # version: major.minor.patch+buildNumber
```

2. Build new release (same commands as above)

3. Upload to respective store consoles

4. Submit for review

---

## Support

- Firebase Console: https://console.firebase.google.com/project/gongura-griha
- Play Console: https://play.google.com/console
- App Store Connect: https://appstoreconnect.apple.com
- Razorpay Dashboard: https://dashboard.razorpay.com

---

*Last Updated: January 2025*
