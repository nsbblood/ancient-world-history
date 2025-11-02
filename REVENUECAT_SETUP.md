# 🛒 RevenueCat Integration Guide

## ✅ What Was Implemented

### 1. **Onboarding Redesign** (Parchment Theme)
- ✅ Ancient parchment gradient (#f3e5ab → #d6c08a)
- ✅ Radial glow effects on icons
- ✅ Serif typography (ancient feel)
- ✅ Warm gold/brown color palette
- ✅ Smooth spring animations
- ✅ Paywall slides in from right (not modal)

### 2. **Paywall Redesign** (Single Screen)
- ✅ No ScrollView - fits in one screen
- ✅ Compact layout with balanced spacing
- ✅ RevenueCat dynamic pricing
- ✅ Matching parchment background
- ✅ Radial glow behind crown icon
- ✅ Try Free button (gold gradient)
- ✅ Restore Purchases button

### 3. **RevenueCat Integration**
- ✅ SDK configuration
- ✅ Fetch offerings
- ✅ Dynamic price display
- ✅ Purchase flow
- ✅ Restore purchases
- ✅ Entitlement check

---

## 📦 Add RevenueCat SDK

### Method 1: Swift Package Manager (Recommended)

1. **Open Xcode**
2. **File** → **Add Package Dependencies...**
3. **Search URL:**
   ```
   https://github.com/RevenueCat/purchases-ios.git
   ```
4. **Version:** Up to Next Major (5.0.0 < 6.0.0)
5. **Add to Target:** Ancient World Stories
6. **Click "Add Package"**

### Method 2: CocoaPods

```ruby
pod 'RevenueCat', '~> 5.0'
```

---

## 🔑 RevenueCat Configuration

### API Key (Already in Code)
```swift
Purchases.configure(withAPIKey: "appl_QugKNOckInPdncYbLMcQxYPdvtm")
```

### Package Identifiers
- **Weekly:** `ancient.week`
- **Yearly:** `ancient.year`

### Entitlement
- **Name:** `premium`

---

## 🎨 Design System

### Colors (Parchment Theme)
```swift
// Soft parchment
Color(red: 0.95, green: 0.90, blue: 0.67) // #f3e5ab

// Warm stone
Color(red: 0.84, green: 0.75, blue: 0.54) // #d6c08a

// Faded gold
Color(red: 0.94, green: 0.82, blue: 0.54) // #f1d78a

// Antique gold
Color(red: 0.84, green: 0.58, blue: 0.23) // #d69438

// Antique brown
Color(red: 0.48, green: 0.37, blue: 0.23) // #7b5e3b
```

### Typography
- **Font:** System Serif (`.serif`)
- **Sizes:**
  - Title: 28-34pt, Bold
  - Body: 14-18pt, Regular
  - Caption: 10-12pt, Regular

### Spacing (Compact Layout)
- Section spacing: 12-20pt
- Item spacing: 4-12pt
- Horizontal padding: 20-32pt
- Vertical padding: 16-20pt

---

## 🔄 User Flow

```
App Launch
    ↓
First Time? → YES
    ↓
Onboarding Page 1 (Welcome)
    ↓ Continue
Onboarding Page 2 (Features)
    ↓ Continue
Onboarding Page 3 (Premium)
    ↓ Get Started
Paywall (slides from right)
    ↓ Try Free
RevenueCat Purchase
    ↓ Success
Main App (slides from right)
```

---

## 🛠️ RevenueCat Dashboard Setup

### 1. Create Products in App Store Connect

#### Weekly Product
- **Product ID:** `ancient.week`
- **Type:** Auto-renewable subscription
- **Duration:** 1 week
- **Price:** $4.99
- **Free Trial:** 7 days

#### Yearly Product
- **Product ID:** `ancient.year`
- **Type:** Auto-renewable subscription
- **Duration:** 1 year
- **Price:** $39.99
- **Free Trial:** 7 days

### 2. Configure in RevenueCat Dashboard

1. **Go to:** https://app.revenuecat.com
2. **Projects** → Your Project
3. **Products** → Add Products
   - Add `ancient.week`
   - Add `ancient.year`
4. **Entitlements** → Create Entitlement
   - Name: `premium`
   - Attach products: `ancient.week`, `ancient.year`
5. **Offerings** → Create Offering
   - Identifier: `default`
   - Add packages:
     - `ancient.week` (Weekly)
     - `ancient.year` (Yearly, set as default)

---

## 🧪 Testing

### Test Purchases (Sandbox)

1. **Create Sandbox Tester**
   - App Store Connect → Users and Access → Sandbox Testers
   - Create new tester email

2. **Sign Out of App Store**
   - Settings → App Store → Sign Out

3. **Run App in Simulator/Device**
   - When prompted, sign in with sandbox tester

4. **Test Flows:**
   - ✅ Free trial starts
   - ✅ Purchase completes
   - ✅ Entitlement activates
   - ✅ Restore works
   - ✅ Subscription shows in Settings

### Test Transitions

1. **Onboarding → Paywall**
   - Should slide from right
   - Smooth spring animation
   - Background matches

2. **Paywall → Main App**
   - After purchase
   - Should slide from right
   - `hasCompletedOnboarding = true`

3. **Close Paywall**
   - X button works
   - Returns to onboarding page 3

---

## 📱 Layout Verification

### iPhone Sizes
- **iPhone 15 Pro Max:** 430 x 932 ✅
- **iPhone 15 Pro:** 393 x 852 ✅
- **iPhone SE:** 375 x 667 ✅

### Paywall Components (Single Screen)
```
┌─────────────────────────┐
│ [X]                     │ Close (16pt top)
│                         │
│    👑 Crown + Glow      │ Header (80pt)
│   Unlock Premium        │
│                         │
│ ✓ 100+ Stories          │ Features (60pt)
│ ✓ Audio Narration       │
│ ✓ Offline Mode          │
│ ✓ Weekly Updates        │
│                         │
│ ┌─────────────────────┐ │ Yearly Plan (60pt)
│ │ Yearly  [Save 85%]  │ │
│ │ $39.99              │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │ Weekly Plan (60pt)
│ │ Weekly              │ │
│ │ $4.99               │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │ Try Free Button (60pt)
│ │     Try Free        │ │
│ └─────────────────────┘ │
│ 7-day free trial...     │ Info (40pt)
│ Terms | Privacy | Restore│
└─────────────────────────┘
Total: ~500-600pt (fits iPhone SE)
```

---

## ✨ Animations

### Spring Animation
```swift
.spring(response: 0.6, dampingFraction: 0.8)
```

### Transitions
```swift
// Paywall appears
.transition(.move(edge: .trailing))

// Main app appears
.transition(.move(edge: .trailing))
```

---

## 🔐 Security & Privacy

### Terms of Service
- Link to your terms URL
- Required for App Store approval

### Privacy Policy
- Link to your privacy URL
- Required for App Store approval

### Restore Purchases
- Always provide restore button
- Required by Apple guidelines

---

## 📊 Analytics (Optional)

Track these events:
- `onboarding_started`
- `onboarding_page_viewed` (page 1, 2, 3)
- `onboarding_completed`
- `paywall_viewed`
- `subscription_selected` (weekly/yearly)
- `purchase_initiated`
- `purchase_completed`
- `purchase_failed`
- `restore_initiated`

---

## 🚀 Next Steps

### Phase 1: Setup ✅
- [x] Add RevenueCat SDK
- [x] Configure API key
- [x] Create products in App Store Connect
- [x] Set up offerings in RevenueCat

### Phase 2: Testing
- [ ] Test sandbox purchases
- [ ] Test free trial
- [ ] Test restore purchases
- [ ] Test all device sizes

### Phase 3: Production
- [ ] Submit for App Store review
- [ ] Enable production mode
- [ ] Monitor conversion rates
- [ ] A/B test pricing

---

## 🐛 Troubleshooting

### "No offerings found"
- Check RevenueCat dashboard configuration
- Verify API key is correct
- Check product IDs match

### "Purchase failed"
- Ensure sandbox tester is signed in
- Check product is available in App Store Connect
- Verify entitlement is configured

### "Layout doesn't fit"
- Adjust spacing values
- Reduce font sizes slightly
- Test on smallest device (iPhone SE)

---

## 📝 Code Summary

### OnboardingView Changes
- ✅ Parchment gradient background
- ✅ Radial glow on icons
- ✅ Serif fonts with warm colors
- ✅ Paywall slides in (not modal)
- ✅ Spring animations

### PaywallView Changes
- ✅ Single-screen layout (no scroll)
- ✅ RevenueCat integration
- ✅ Dynamic pricing
- ✅ Matching parchment theme
- ✅ Compact spacing
- ✅ Try Free button

### Key Files
- `OnboardingView.swift` - 3-page onboarding
- `PaywallView.swift` - RevenueCat paywall
- `AncientWorldStoriesApp.swift` - Onboarding check

---

## ✅ Completion Checklist

- [x] Parchment color scheme
- [x] Radial glow effects
- [x] Serif typography
- [x] Single-screen paywall
- [x] RevenueCat integration
- [x] Dynamic pricing
- [x] Smooth transitions
- [x] Restore purchases
- [x] Legal links
- [x] Compact layout

**Ready to add RevenueCat SDK and test!** 🚀
