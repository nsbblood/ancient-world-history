# Ancient World Stories

A calm, minimalist storytelling app featuring short serialized stories inspired by ancient civilizations.

## Overview

Ancient World Stories is a premium iOS app (iOS 17+) built with SwiftUI that offers users an immersive journey through history via serialized storytelling. Each story series consists of 10 episodes (30-60 seconds each) set in different ancient civilizations.

## Features

### Core Screens
1. **Home** - Discover random episodes from various story series
2. **Explore** - Browse stories by civilization and era
3. **Profile** - Track reading progress, favorites, and manage voice settings

### Key Capabilities
- **Offline Text-to-Speech** - 4 built-in voices (2 male, 2 female) using AVSpeechSynthesizer
- **Progress Tracking** - Monitor reading completion per series
- **Favorites** - Save favorite story series
- **Statistics** - View total reading time and civilizations explored
- **Supabase Integration** - Cloud data sync with local JSON fallback

## Project Structure

```
AncientWorldStories/
├── Models/
│   ├── Series.swift
│   └── Episode.swift
├── Managers/
│   ├── SupabaseClient.swift
│   ├── StoryLoader.swift
│   ├── AudioManager.swift
│   ├── FavoritesManager.swift
│   └── ProfileManager.swift
├── Views/
│   ├── Components/
│   │   ├── SeriesCard.swift
│   │   └── EpisodeRow.swift
│   ├── HomeView.swift
│   ├── MapView.swift
│   ├── EpisodesView.swift
│   ├── EpisodeReaderView.swift
│   └── ProfileView.swift
├── Extensions/
│   ├── Color+Theme.swift
│   └── Font+Theme.swift
├── Resources/
│   └── stories.json
└── AncientWorldStoriesApp.swift
```

## Setup Instructions

### 1. Xcode Configuration

1. Open the project in Xcode 15.0 or later
2. Set deployment target to iOS 17.0+
3. Configure signing & capabilities with your team

### 2. Supabase Configuration (Optional)

If you want to use Supabase for cloud data:

1. Create a Supabase project at https://supabase.com
2. Add the following keys to your `Info.plist`:

```xml
<key>SUPABASE_URL</key>
<string>https://your-project.supabase.co</string>
<key>SUPABASE_ANON_KEY</key>
<string>your-anon-key-here</string>
```

3. Create tables in Supabase:

**Series Table:**
```sql
CREATE TABLE series (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    civilization TEXT NOT NULL,
    era TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Episodes Table:**
```sql
CREATE TABLE episodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    series_id UUID REFERENCES series(id),
    title TEXT NOT NULL,
    text TEXT NOT NULL,
    order_no INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    language_code TEXT DEFAULT 'en-US'
);
```

### 3. Local Fallback

The app includes `Resources/stories.json` with sample data. If Supabase is not configured or unavailable, the app will automatically use this local data.

### 4. Add Stories JSON to Target

1. In Xcode, select `stories.json`
2. In File Inspector, ensure it's checked under "Target Membership" for AncientWorldStories

## Design System

### Colors
- Background: `#F7F4EC` (Light parchment)
- Text: `#3E3A31` (Dark brown)
- Accent: `#A98358` (Bronze/gold)
- Card Background: `#FFFFFF` (White)

### Typography
- Uses system serif fonts (Playfair Display / Cinzel style)
- Custom font support can be added by:
  1. Adding font files to project
  2. Updating `Info.plist` with font names
  3. Uncommenting custom font methods in `Font+Theme.swift`

## Premium Features (Placeholder)

The app includes placeholders for premium subscription:

- Weekly: $2.99/week
- Yearly: $29.99/year

**Free Tier:**
- Access to first 3 series (30 episodes)

**Premium Tier:**
- Unlimited access to all civilizations
- Ad-free (though MVP has no ads)

To implement:
1. Integrate RevenueCat or StoreKit 2
2. Update `ProfileManager.canAccessContent()` logic
3. Add paywall UI in `ProfileView`

## Data Management

### Favorites
- Stored locally using UserDefaults
- Managed by `FavoritesManager`

### Reading Progress
- Tracked per episode using `ProfileManager`
- Includes total episodes read, civilizations explored, reading time

### Voice Settings
- 4 selectable voices using AppStorage
- Offline TTS via AVSpeechSynthesizer

## Testing

### Sample Data
The project includes sample series and episodes in:
- `Series.samples` (Models/Series.swift)
- `Episode.samples` (Models/Episode.swift)
- `Resources/stories.json`

### Preview Data
All views include SwiftUI previews for rapid development.

## Deployment Checklist

Before App Store submission:

- [ ] Add custom fonts (Playfair Display, Cinzel)
- [ ] Configure App Icons in Assets.xcassets
- [ ] Add launch screen
- [ ] Implement RevenueCat for subscriptions
- [ ] Add privacy policy URL
- [ ] Configure App Store Connect metadata
- [ ] Test on physical devices (iPhone, iPad)
- [ ] Add proper error handling for network failures
- [ ] Implement analytics (optional)
- [ ] Add onboarding flow
- [ ] Localization (if supporting multiple languages)

## Architecture Highlights

### Managers (Singleton Pattern)
- `StoryLoader` - Centralized data management
- `AudioManager` - AVSpeechSynthesizer wrapper
- `FavoritesManager` - Local favorites persistence
- `ProfileManager` - User settings and statistics

### Views (SwiftUI)
- MVVM-inspired architecture
- ObservableObject for reactive state management
- Navigation using NavigationStack (iOS 16+)

### Data Flow
```
Supabase → SupabaseClient → StoryLoader → Views
                ↓ (fallback)
           stories.json
```

## License

Copyright © 2025. All rights reserved.

## Support

For issues or questions, contact: [your-email@example.com]

---

**Built with Swift 5.9+ • SwiftUI • iOS 17.0+**
