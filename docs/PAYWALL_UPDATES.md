# 🎨 Paywall & Onboarding Updates

## ✅ Changes Made

### 1. **Onboarding - More Visible**
- ✅ Page indicators now use darker gold color
- ✅ Active: `#d69438` (antique gold)
- ✅ Inactive: Brown with 30% opacity
- ✅ More contrast against parchment background

### 2. **Paywall - Brighter & More Engaging**
- ✅ Larger, bolder text
- ✅ Features with bigger icons (36x36)
- ✅ Stronger background opacity (0.4 instead of 0.3)
- ✅ Thicker borders (2.5px when selected)
- ✅ Gradient badge for "Save 85%"

### 3. **Try Free Button - Top Right**
- ✅ Only appears when **Weekly** is selected
- ✅ Located in top-right corner
- ✅ Gold gradient button
- ✅ Starts 3-day trial immediately

### 4. **Yearly Plan - Default Selection**
- ✅ Opens with Yearly selected
- ✅ Button says **"Continue"** (not "Try Free")
- ✅ Info text: "Then $39.99/year"
- ✅ No trial for yearly

### 5. **Weekly Plan - 3-Day Trial**
- ✅ When selected, "Try Free" button appears top-right
- ✅ Info text: "3-day free trial, then $4.99/week"
- ✅ Charges after 3 days

### 6. **RevenueCat Dynamic Pricing**
- ✅ Fetches offerings on appear
- ✅ Uses `package.storeProduct.localizedPriceString`
- ✅ Falls back to static prices if loading
- ✅ Product IDs: `ancient.year`, `ancient.week`

---

## 🎯 User Flow

### Yearly Plan (Default)
```
App Opens → Paywall
    ↓
Yearly Selected (default)
    ↓
Bottom: "Continue" button
    ↓
Info: "Then $39.99/year"
    ↓
Tap Continue → Subscribe
```

### Weekly Plan
```
App Opens → Paywall
    ↓
Tap Weekly Plan
    ↓
Top-Right: "Try Free" button appears
    ↓
Info: "3-day free trial, then $4.99/week"
    ↓
Tap Try Free → Start Trial
```

---

## 🎨 Visual Improvements

### Onboarding
**Before:**
- Page dots: White with low opacity (hard to see)

**After:**
- Active: Antique gold (#d69438) - bold
- Inactive: Brown with 30% opacity - visible

### Paywall
**Before:**
- Muted colors
- Small text
- Low contrast

**After:**
- Title: 30pt (was 28pt)
- Subtitle: 15pt (was 14pt)
- Features: 15pt semibold (was 14pt medium)
- Icons: 36x36 (was 32x32)
- Badge: Gold gradient (was flat)
- Borders: 2.5px (was 2px)
- Background: 40% opacity (was 30%)

---

## 💰 Pricing Logic

### RevenueCat Integration
```swift
// Fetch offerings
Task {
    let offerings = try await Purchases.shared.offerings()
    self.offerings = offerings
}

// Get price
package.storeProduct.localizedPriceString
// Returns: "$39.99" or "₺399,99" (localized)
```

### Trial Info
```swift
// Yearly
"Then $39.99/year"

// Weekly
"3-day free trial, then $4.99/week"
```

---

## 🔧 Technical Details

### Button Logic
```swift
// Button text changes based on selection
private var buttonText: String {
    selectedPlan == "ancient.year" ? "Continue" : "Try Free"
}

// Button location
- Yearly: Bottom (full width)
- Weekly: Top-right (compact)
```

### Trial Configuration
- **Yearly:** No trial, immediate charge
- **Weekly:** 3-day trial, then charge

### Product IDs
- **Yearly:** `ancient.year`
- **Weekly:** `ancient.week`

---

## 📱 Layout

### Paywall Structure
```
┌─────────────────────────────┐
│ [X]          [Try Free]     │ ← Top bar (only Try Free if weekly)
│                             │
│        👑 Crown             │ ← Header
│    Unlock Premium           │
│                             │
│ ✓ 100+ Stories              │ ← Features (bigger icons)
│ ✓ Audio Narration           │
│ ✓ Offline Mode              │
│ ✓ Weekly Updates            │
│                             │
│ ┌─────────────────────────┐ │ ← Yearly (selected, bold border)
│ │ Yearly  [Save 85%]      │ │
│ │ Best Value              │ │
│ │              $39.99     │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │ ← Weekly (lighter)
│ │ Weekly                  │ │
│ │ Weekly Access           │ │
│ │              $4.99      │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │ ← Continue button (only yearly)
│ │      Continue           │ │
│ └─────────────────────────┘ │
│ Then $39.99/year            │ ← Info text
│                             │
│ Terms | Privacy | Restore   │ ← Legal
└─────────────────────────────┘
```

---

## 🧪 Testing Checklist

### Onboarding
- [ ] Page indicators visible
- [ ] Active dot is gold
- [ ] Inactive dots are brown
- [ ] Text is readable

### Paywall - Yearly
- [ ] Opens with yearly selected
- [ ] Bottom button says "Continue"
- [ ] Info: "Then $39.99/year"
- [ ] No "Try Free" in top-right
- [ ] Price from RevenueCat

### Paywall - Weekly
- [ ] Can select weekly
- [ ] "Try Free" appears top-right
- [ ] Info: "3-day free trial, then $4.99/week"
- [ ] Bottom button disappears
- [ ] Price from RevenueCat

### Visual
- [ ] Colors are vibrant
- [ ] Text is bold and readable
- [ ] Icons are bigger
- [ ] Badge has gradient
- [ ] Borders are thick

---

## 🎨 Color Reference

```swift
// Parchment
Color(red: 0.95, green: 0.90, blue: 0.67) // #f3e5ab

// Stone
Color(red: 0.84, green: 0.75, blue: 0.54) // #d6c08a

// Faded Gold
Color(red: 0.94, green: 0.82, blue: 0.54) // #f1d78a

// Antique Gold
Color(red: 0.84, green: 0.58, blue: 0.23) // #d69438

// Antique Brown
Color(red: 0.48, green: 0.37, blue: 0.23) // #7b5e3b
```

---

## ✅ Summary

**Onboarding:**
- ✅ Darker, more visible page indicators

**Paywall:**
- ✅ Brighter, bolder design
- ✅ Yearly default with "Continue"
- ✅ Weekly with "Try Free" (top-right)
- ✅ 3-day trial for weekly
- ✅ RevenueCat dynamic pricing
- ✅ Larger text and icons
- ✅ Gradient badge
- ✅ Thicker borders

**Ready to test!** 🚀
