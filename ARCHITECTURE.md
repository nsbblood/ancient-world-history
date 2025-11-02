# Ancient World Stories - Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Ancient World Stories                    │
│                         iOS App (SwiftUI)                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                         Presentation Layer                   │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ HomeView │  │ MapView  │  │ Profile  │  │ Episodes │   │
│  │          │  │          │  │ View     │  │ View     │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         EpisodeReaderView (with TTS controls)        │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  Components:                                                 │
│  ┌─────────────┐  ┌─────────────┐                          │
│  │ SeriesCard  │  │ EpisodeRow  │                          │
│  └─────────────┘  └─────────────┘                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                       Business Logic Layer                   │
├─────────────────────────────────────────────────────────────┤
│  Managers (Singleton Pattern):                              │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ StoryLoader  │  │AudioManager  │  │ Favorites    │     │
│  │ (Main Data)  │  │ (TTS/AVF)    │  │ Manager      │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │ Profile      │  │ Supabase     │                        │
│  │ Manager      │  │ Client       │                        │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                         Data Layer                           │
├─────────────────────────────────────────────────────────────┤
│  Models:                                                     │
│  ┌─────────┐  ┌─────────┐                                  │
│  │ Series  │  │ Episode │                                  │
│  └─────────┘  └─────────┘                                  │
│                                                              │
│  Persistence:                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ UserDefaults │  │ AppStorage   │  │ FileManager  │     │
│  │ (Favorites)  │  │ (Settings)   │  │ (Cache)      │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      External Services                       │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Supabase    │  │   stories    │  │   AVFoundation│     │
│  │  REST API    │  │   .json      │  │   (TTS)       │     │
│  │  (Optional)  │  │  (Fallback)  │  │  (Offline)    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐                                           │
│  │  RevenueCat  │                                           │
│  │  (Future)    │                                           │
│  └──────────────┘                                           │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. App Launch
```
User Opens App
      ↓
AncientWorldStoriesApp.swift
      ↓
ContentView (TabView)
      ↓
StoryLoader.loadInitialData()
      ↓
Try: Supabase → Success: Cache & Display
      ↓
Fail: Load from stories.json → Display
```

### 2. Reading an Episode
```
User taps Episode
      ↓
EpisodeReaderView displayed
      ↓
ProfileManager.markEpisodeAsRead()
      ↓
User taps Play
      ↓
AudioManager.speak(text)
      ↓
AVSpeechSynthesizer (offline TTS)
      ↓
Progress updates in real-time
```

### 3. Favorites Flow
```
User taps Heart icon
      ↓
FavoritesManager.toggleFavorite()
      ↓
Save to UserDefaults
      ↓
UI updates via @Published
      ↓
Visible in ProfileView
```

## Component Responsibilities

### Models
**Series.swift**
- Data structure for story series
- Codable for JSON parsing
- Sample data for previews

**Episode.swift**
- Episode data with text content
- Duration and language info
- Computed properties (excerpt, formattedDuration)

### Managers

**StoryLoader** (Main Data Controller)
- Fetches data from Supabase or local JSON
- Caches episodes and series
- Provides filtered/grouped data to views
- Observable for reactive UI updates

**AudioManager** (Text-to-Speech)
- Wraps AVSpeechSynthesizer
- Manages voice selection (4 voices)
- Controls playback (play/pause/stop)
- Tracks progress
- Fully offline

**FavoritesManager** (Local Persistence)
- Manages favorite series
- Stores in UserDefaults
- Provides favorite queries
- Observable for UI reactivity

**ProfileManager** (User Settings & Stats)
- Tracks read episodes
- Stores voice preference
- Calculates statistics
- Premium status management
- Uses AppStorage for persistence

**SupabaseClient** (Network Layer)
- REST API communication
- Error handling
- Response caching
- Configurable via Info.plist

### Views

**HomeView**
- Displays random episodes
- Refresh functionality
- Navigation to series details
- Loading/error states

**MapView**
- Groups series by civilization
- Expandable sections
- Era information
- Navigation to series

**EpisodesView**
- Shows all episodes in series
- Progress tracking
- Favorite toggle
- Episode list with read status

**EpisodeReaderView**
- Full text display
- TTS controls
- Progress indicator
- Mark as read

**ProfileView**
- User statistics
- Favorite series list
- Voice selector
- Premium status/upgrade

## State Management

### ObservableObject Pattern
```swift
@StateObject private var storyLoader = StoryLoader.shared
@ObservedObject private var audioManager = AudioManager.shared
```

### AppStorage for Settings
```swift
@AppStorage("selectedVoiceType") var selectedVoiceType: String
@AppStorage("isPremium") var isPremium: Bool
```

### UserDefaults for Complex Data
```swift
// FavoritesManager
let favoriteSeriesIds: Set<UUID>
// Encoded/decoded as JSON
```

## Design Patterns

### 1. Singleton Pattern
All managers use singleton pattern for centralized state:
```swift
static let shared = StoryLoader()
```

### 2. MVVM-Inspired
- Models: Pure data structures
- Views: SwiftUI views
- ViewModel logic: Embedded in Managers (ObservableObject)

### 3. Repository Pattern
- SupabaseClient abstracts data source
- StoryLoader provides unified interface
- Fallback mechanism transparent to views

### 4. Dependency Injection
Views receive managers via @StateObject or @ObservedObject

## Threading Model

### Main Actor
All managers marked @MainActor for UI updates:
```swift
@MainActor
class StoryLoader: ObservableObject { }
```

### Async/Await
Network calls use modern concurrency:
```swift
async let seriesTask = supabase.fetchSeries()
async let episodesTask = supabase.fetchEpisodes()
let (series, episodes) = try await (seriesTask, episodesTask)
```

## Error Handling

### Graceful Degradation
```
Supabase fails → Load from cache → Load from JSON → Show error
```

### User-Facing Errors
- Loading states with ProgressView
- Error messages with retry options
- Fallback to local data silently

## Performance Optimizations

### 1. Lazy Loading
- Episodes loaded on demand per series
- Images (when added) loaded asynchronously

### 2. Caching Strategy
- Network responses cached to disk
- UserDefaults for small data
- In-memory cache for active data

### 3. Efficient Lists
- SwiftUI's lazy stacks
- Identified items for optimization
- Minimal view hierarchy

## Security Considerations

### 1. API Keys
- Stored in Info.plist (not in code)
- Use environment variables in production
- Supabase Row Level Security enabled

### 2. Data Privacy
- All user data stored locally
- No personal information sent to server
- Reading history private

### 3. Premium Features
- Server-side validation (when implemented)
- Receipt verification via RevenueCat

## Testing Strategy

### Unit Tests (Future)
- Manager business logic
- Data model encoding/decoding
- Calculation methods (progress, stats)

### UI Tests (Future)
- Navigation flows
- TTS playback
- Favorite toggling

### Integration Tests
- Supabase connection
- Fallback mechanism
- Cache invalidation

## Scalability

### Current Limitations
- ~100 series max (memory constraints)
- ~1000 episodes total
- Text-only content

### Future Enhancements
- Pagination for large datasets
- Media streaming for audio files
- CDN for images/assets
- Background download for offline

## Deployment Architecture

```
Development → TestFlight → App Store
     ↓            ↓            ↓
  Simulator    Beta Users   Production
     ↓            ↓            ↓
 Local JSON   Supabase     Supabase
```

## Monitoring & Analytics (Future)

### Planned Metrics
- Session duration
- Episodes completed
- Favorite conversion rate
- Premium conversion rate
- Crash reports
- Network errors

### Tools
- Firebase Analytics (optional)
- App Store Connect Analytics
- RevenueCat analytics
- Supabase logs

---

**Architecture Version:** 1.0
**Last Updated:** January 2025
**iOS Target:** 17.0+
**Swift Version:** 5.9+
