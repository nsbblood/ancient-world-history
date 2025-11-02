# Ancient World Stories - Setup Guide

This guide will help you get the Ancient World Stories app running in Xcode.

## Prerequisites

- macOS Ventura or later
- Xcode 15.0 or later
- iOS 17.0+ device or simulator
- Apple Developer account (for device testing)

## Quick Start

### Step 1: Create Xcode Project

1. Open Xcode
2. Create a new project: **File → New → Project**
3. Select **iOS** → **App**
4. Configure:
   - Product Name: `Ancient World Stories`
   - Team: Select your team
   - Organization Identifier: `com.yourcompany.ancientworldstories`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**
   - Deselect "Include Tests"

### Step 2: Project Structure

Create the following folder structure in your project:

```
AncientWorldStories/
├── Models/
├── Managers/
├── Views/
│   └── Components/
├── Extensions/
└── Resources/
```

To create folders in Xcode:
1. Right-click on `AncientWorldStories` folder
2. Select **New Group**
3. Name it appropriately

### Step 3: Add Source Files

Copy all the `.swift` files from this repository into their respective folders:

**Models/**
- Series.swift
- Episode.swift

**Managers/**
- SupabaseClient.swift
- StoryLoader.swift
- AudioManager.swift
- FavoritesManager.swift
- ProfileManager.swift

**Views/Components/**
- SeriesCard.swift
- EpisodeRow.swift

**Views/**
- HomeView.swift
- MapView.swift
- EpisodesView.swift
- EpisodeReaderView.swift
- ProfileView.swift

**Extensions/**
- Color+Theme.swift
- Font+Theme.swift

**Root Level:**
- AncientWorldStoriesApp.swift (replace the default one)

### Step 4: Add stories.json

1. In Xcode, right-click on `Resources` folder
2. Select **Add Files to "Ancient World Stories"...**
3. Select `stories.json`
4. Ensure "Copy items if needed" is checked
5. Ensure "Add to targets" has AncientWorldStories checked

### Step 5: Configure Info.plist

#### Option A: Using Xcode UI

1. Select your project in Project Navigator
2. Select the `AncientWorldStories` target
3. Go to the **Info** tab
4. Add the following custom keys:

**For Supabase (Optional):**
- Right-click → **Add Row**
- Key: `SUPABASE_URL`, Type: String, Value: `https://your-project.supabase.co`
- Key: `SUPABASE_ANON_KEY`, Type: String, Value: `your-anon-key`

**For Custom Fonts (When Added):**
- Key: `Fonts provided by application`, Type: Array
  - Item 0: `PlayfairDisplay-Regular.ttf`
  - Item 1: `Cinzel-Regular.ttf`

#### Option B: Edit Info.plist Directly

Add to `Info.plist`:

```xml
<key>SUPABASE_URL</key>
<string>https://your-project.supabase.co</string>
<key>SUPABASE_ANON_KEY</key>
<string>your-anon-key-here</string>

<!-- If using custom fonts -->
<key>UIAppFonts</key>
<array>
    <string>PlayfairDisplay-Regular.ttf</string>
    <string>Cinzel-Regular.ttf</string>
</array>
```

### Step 6: Build and Run

1. Select a simulator or device (iOS 17.0+)
2. Press **⌘R** or click the **Play** button
3. The app should build and launch

## Common Issues & Solutions

### Issue: "Module not found"
**Solution:** Clean build folder (⌘⇧K) and rebuild (⌘B)

### Issue: "stories.json not found"
**Solution:**
1. Select `stories.json` in Project Navigator
2. Check **Target Membership** in File Inspector
3. Ensure `AncientWorldStories` is checked

### Issue: Supabase connection fails
**Solution:** This is normal if you haven't set up Supabase. The app will automatically fallback to `stories.json`

### Issue: Text-to-Speech not working
**Solution:**
1. Ensure you're testing on a real device or simulator with internet (voices download on first use)
2. Check Settings → Accessibility → Spoken Content → Voices to ensure English voices are downloaded

### Issue: Layout issues on iPad
**Solution:** The current design is optimized for iPhone. For iPad support, adjust frame sizes and add `@ScaledMetric` properties

## Optional: Supabase Setup

### 1. Create Supabase Project

1. Go to https://supabase.com
2. Create a new project
3. Note your project URL and anon key

### 2. Create Database Tables

Run these SQL commands in Supabase SQL Editor:

```sql
-- Series table
CREATE TABLE series (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    civilization TEXT NOT NULL,
    era TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Episodes table
CREATE TABLE episodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    series_id UUID REFERENCES series(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    text TEXT NOT NULL,
    order_no INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    language_code TEXT DEFAULT 'en-US',
    UNIQUE(series_id, order_no)
);

-- Create indexes
CREATE INDEX idx_episodes_series_id ON episodes(series_id);
CREATE INDEX idx_episodes_order ON episodes(series_id, order_no);
```

### 3. Import Sample Data

You can import data from `stories.json` using Supabase's table import feature or write SQL INSERT statements.

### 4. Configure Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE series ENABLE ROW LEVEL SECURITY;
ALTER TABLE episodes ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Public read access" ON series FOR SELECT USING (true);
CREATE POLICY "Public read access" ON episodes FOR SELECT USING (true);
```

## Adding Custom Fonts

### 1. Download Fonts

- **Playfair Display**: https://fonts.google.com/specimen/Playfair+Display
- **Cinzel**: https://fonts.google.com/specimen/Cinzel

### 2. Add to Xcode

1. Drag font files (.ttf or .otf) into Xcode project
2. Ensure "Copy items if needed" is checked
3. Add to target

### 3. Update Info.plist

Add font names under `Fonts provided by application`

### 4. Update Font+Theme.swift

Uncomment the custom font methods:

```swift
static func playfairDisplay(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    .custom("PlayfairDisplay-Regular", size: size)
}
```

## Testing the App

### 1. Test Offline Mode

1. Turn off WiFi/Cellular on device
2. Force quit app
3. Relaunch → should load from `stories.json`

### 2. Test Text-to-Speech

1. Open any episode
2. Tap the play button
3. Speech should begin (may be slow on simulator)

### 3. Test Favorites

1. Tap heart icon on any series
2. Go to Profile tab
3. Favorite should appear

### 4. Test Reading Progress

1. Open and read several episodes
2. Check Profile → Statistics
3. Progress bars should update

## Next Steps

1. **Add App Icon**: Create icon in Assets.xcassets
2. **Add Launch Screen**: Create in Storyboard or SwiftUI
3. **Implement IAP**: Integrate RevenueCat for premium subscriptions
4. **Add Analytics**: Optional - Firebase, Mixpanel, etc.
5. **Localization**: Add support for other languages
6. **Testing**: Add unit tests and UI tests

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [AVFoundation Speech](https://developer.apple.com/documentation/avfoundation/avspeechsynthesizer)
- [Supabase Docs](https://supabase.com/docs)
- [App Store Guidelines](https://developer.apple.com/app-store/review/guidelines/)

## Support

If you encounter issues:

1. Check the **Common Issues** section above
2. Clean build folder (⌘⇧K)
3. Restart Xcode
4. Delete derived data: `~/Library/Developer/Xcode/DerivedData`

---

**Happy Coding!** 🏛️📚
