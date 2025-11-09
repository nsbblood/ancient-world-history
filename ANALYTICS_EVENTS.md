# Analytics Events Documentation
## Ancient World Stories - Event Tracking

This document lists all analytics events tracked in the Ancient World Stories app for Facebook Pixel, TikTok Pixel, and Mixpanel.

---

## Event Categories

### 📱 App Lifecycle Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `app_launched` | User opens the app | - |
| `onboarding_started` | User starts onboarding flow | - |
| `onboarding_completed` | User completes onboarding | - |
| `onboarding_page_viewed` | User views specific onboarding page | `page_number` (Int)<br>`page_title` (String) |

---

### 🧭 Navigation Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `home_tab_viewed` | User taps Home tab | - |
| `civilizations_tab_viewed` | User taps Civilizations tab | - |
| `explore_tab_viewed` | User taps Explore tab | - |
| `profile_tab_viewed` | User taps Profile tab | - |

---

### 📚 Content Browsing Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `civilization_viewed` | User views civilization list | - |
| `civilization_card_tapped` | User taps on a civilization card | `civilization_id` (String)<br>`civilization_name` (String) |
| `story_viewed` | User views stories for a civilization | `civilization_id` (String)<br>`civilization_name` (String) |
| `story_card_tapped` | User taps on a story card | `story_id` (String)<br>`story_title` (String)<br>`civilization_name` (String) |
| `chapter_viewed` | User views chapters for a story | `story_id` (String)<br>`story_title` (String) |
| `chapter_card_tapped` | User taps on a chapter card | `chapter_id` (String)<br>`chapter_title` (String)<br>`story_title` (String) |
| `chapter_opened` | User opens chapter reader | `chapter_id` (String)<br>`chapter_title` (String)<br>`chapter_number` (Int)<br>`story_title` (String)<br>`civilization_name` (String) |

---

### 🎧 Reading & Audio Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `chapter_reading_started` | User starts reading a chapter | `chapter_id` (String)<br>`chapter_title` (String) |
| `audio_playback_started` | User starts audio narration | `chapter_id` (String)<br>`voice_type` (String)<br>`is_premium` (Bool) |
| `audio_playback_paused` | User pauses audio narration | `chapter_id` (String)<br>`progress_percentage` (Int) |
| `audio_playback_resumed` | User resumes audio narration | `chapter_id` (String)<br>`progress_percentage` (Int) |
| `audio_playback_stopped` | User stops audio narration | `chapter_id` (String)<br>`progress_percentage` (Int) |
| `audio_playback_completed` | Audio narration finishes | `chapter_id` (String)<br>`chapter_title` (String) |

---

### ⏭️ Chapter Navigation Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `next_chapter_tapped` | User taps Next Chapter button | `current_chapter_id` (String)<br>`next_chapter_id` (String)<br>`next_chapter_title` (String) |
| `previous_chapter_tapped` | User taps Previous Chapter button | `current_chapter_id` (String)<br>`previous_chapter_id` (String)<br>`previous_chapter_title` (String) |
| `back_button_tapped` | User taps Back button in reader | `chapter_id` (String)<br>`reading_time_seconds` (Int) |

---

### ❤️ Favorites Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `chapter_favorited` | User adds chapter to favorites | `chapter_id` (String)<br>`chapter_title` (String)<br>`story_title` (String) |
| `chapter_unfavorited` | User removes chapter from favorites | `chapter_id` (String)<br>`chapter_title` (String) |
| `favorite_chapter_opened` | User opens a chapter from favorites | `chapter_id` (String)<br>`chapter_title` (String) |

---

### ⚙️ Settings & Preferences Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `settings_opened` | User opens Settings | - |
| `voice_selector_opened` | User opens Voice Selector | `current_voice` (String) |
| `voice_changed` | User changes TTS voice | `old_voice` (String)<br>`new_voice` (String)<br>`is_premium` (Bool) |
| `contact_support_tapped` | User taps Contact Support | - |
| `privacy_policy_tapped` | User taps Privacy Policy | - |
| `terms_of_service_tapped` | User taps Terms of Service | - |

---

### 👑 Premium & Paywall Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `paywall_viewed` | Paywall is displayed to user | `source` (String)<br>`trigger` (String) |
| `paywall_dismissed` | User closes paywall without purchasing | `source` (String)<br>`time_spent_seconds` (Int) |
| `go_premium_tapped` | User taps Go Premium button | `source` (String) |
| `subscription_plan_selected` | User selects a subscription plan | `plan_id` (String)<br>`plan_name` (String)<br>`price` (String)<br>`billing_period` (String) |
| `purchase_initiated` | User initiates purchase flow | `plan_id` (String)<br>`plan_name` (String)<br>`price` (String) |
| `purchase_completed` | Purchase successfully completed | `plan_id` (String)<br>`plan_name` (String)<br>`price` (String)<br>`transaction_id` (String) |
| `purchase_failed` | Purchase failed | `plan_id` (String)<br>`error_message` (String) |
| `restore_purchases_tapped` | User taps Restore Purchases | - |
| `restore_purchases_completed` | Purchase restoration completed | `success` (Bool)<br>`restored_purchases_count` (Int) |

---

### 👤 Profile Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `profile_image_changed` | User changes profile image | - |
| `statistics_viewed` | User views reading statistics | `total_chapters_read` (Int)<br>`civilizations_explored` (Int)<br>`total_reading_time_minutes` (Int) |

---

### 🗺️ Explore Map Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `map_viewed` | User views map in Explore tab | - |
| `map_civilization_tapped` | User taps civilization on map | `civilization_id` (String)<br>`civilization_name` (String) |
| `map_zoomed` | User zooms the map | `zoom_level` (Double) |

---

### ⚠️ Error & Issue Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `error_occurred` | General error occurred | `error_type` (String)<br>`error_message` (String)<br>`screen` (String) |
| `network_error_occurred` | Network-related error | `endpoint` (String)<br>`error_message` (String) |
| `audio_error_occurred` | Audio playback error | `chapter_id` (String)<br>`error_message` (String)<br>`voice_type` (String) |

---

### 🔄 Content Refresh Events

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `content_refreshed` | User pulls to refresh content | `screen` (String) |
| `random_chapters_loaded` | Random chapters loaded on Home | `chapter_count` (Int) |

---

## Event Implementation

### Usage Example

```swift
// Simple event
AnalyticsManager.shared.track(event: .appLaunched)

// Event with parameters
AnalyticsManager.shared.track(
    event: .chapterOpened,
    parameters: [
        "chapter_id": chapter.id.uuidString,
        "chapter_title": chapter.title,
        "chapter_number": chapter.orderNo,
        "story_title": story.title,
        "civilization_name": civilization.name
    ]
)

// Premium event
AnalyticsManager.shared.track(
    event: .purchaseCompleted,
    parameters: [
        "plan_id": package.identifier,
        "plan_name": "Premium Annual",
        "price": "$39.99",
        "transaction_id": transactionId
    ]
)
```

---

## Integration Platforms

### Facebook Pixel
All events will be sent to Facebook Pixel for conversion tracking and audience building.

### TikTok Pixel
Events will be sent to TikTok Events API for ad optimization and retargeting.

### Mixpanel
Comprehensive user behavior analytics with funnels, retention, and cohort analysis.

---

## Event Naming Conventions

- Use **snake_case** for all event names
- Use descriptive, action-oriented names (e.g., `chapter_opened`, not `open_chapter`)
- Keep names consistent and predictable
- Include context in parameters, not event names

## Parameter Guidelines

- Always include IDs (UUID strings) for trackable entities
- Include human-readable names alongside IDs
- Track boolean flags for A/B testing (e.g., `is_premium`)
- Include time-based metrics where relevant (e.g., `time_spent_seconds`)

---

## Total Events Tracked: 49 Events

**Last Updated:** 2025-01-09
