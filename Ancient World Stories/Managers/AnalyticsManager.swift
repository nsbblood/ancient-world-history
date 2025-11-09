//
//  AnalyticsManager.swift
//  Ancient World Stories
//
//  Analytics event tracking for Facebook, TikTok, and Mixpanel
//

import Foundation
import Combine

@MainActor
class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()

    private init() {}

    // MARK: - Event Tracking

    /// Track an event with optional parameters
    func track(event: AnalyticsEvent, parameters: [String: Any] = [:]) {
        let eventName = event.rawValue

        print("📊 Analytics Event: \(eventName)")
        if !parameters.isEmpty {
            print("   Parameters: \(parameters)")
        }

        // TODO: Send to Facebook Pixel
        trackFacebookEvent(event: eventName, parameters: parameters)

        // TODO: Send to TikTok Pixel
        trackTikTokEvent(event: eventName, parameters: parameters)

        // TODO: Send to Mixpanel
        trackMixpanelEvent(event: eventName, parameters: parameters)
    }

    // MARK: - Platform-Specific Tracking

    private func trackFacebookEvent(event: String, parameters: [String: Any]) {
        // Facebook Pixel integration
        // TODO: Implement Facebook SDK tracking
    }

    private func trackTikTokEvent(event: String, parameters: [String: Any]) {
        // TikTok Pixel integration
        // TODO: Implement TikTok Events API
    }

    private func trackMixpanelEvent(event: String, parameters: [String: Any]) {
        // Mixpanel integration
        // TODO: Implement Mixpanel SDK tracking
    }

    // MARK: - User Properties

    func setUserProperty(key: String, value: Any) {
        print("👤 Set User Property: \(key) = \(value)")
        // TODO: Update user properties in all platforms
    }

    func identifyUser(userId: String) {
        print("🆔 Identify User: \(userId)")
        // TODO: Identify user across all platforms
    }
}

// MARK: - Analytics Events Enum

enum AnalyticsEvent: String {
    // MARK: - App Lifecycle
    case appLaunched = "app_launched"
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"
    case onboardingPageViewed = "onboarding_page_viewed"

    // MARK: - Navigation
    case homeTabViewed = "home_tab_viewed"
    case civilizationsTabViewed = "civilizations_tab_viewed"
    case exploreTabViewed = "explore_tab_viewed"
    case profileTabViewed = "profile_tab_viewed"

    // MARK: - Content Browsing
    case civilizationViewed = "civilization_viewed"
    case civilizationCardTapped = "civilization_card_tapped"
    case storyViewed = "story_viewed"
    case storyCardTapped = "story_card_tapped"
    case chapterViewed = "chapter_viewed"
    case chapterCardTapped = "chapter_card_tapped"
    case chapterOpened = "chapter_opened"

    // MARK: - Reading & Audio
    case chapterReadingStarted = "chapter_reading_started"
    case audioPlaybackStarted = "audio_playback_started"
    case audioPlaybackPaused = "audio_playback_paused"
    case audioPlaybackResumed = "audio_playback_resumed"
    case audioPlaybackStopped = "audio_playback_stopped"
    case audioPlaybackCompleted = "audio_playback_completed"

    // MARK: - Chapter Navigation
    case nextChapterTapped = "next_chapter_tapped"
    case previousChapterTapped = "previous_chapter_tapped"
    case backButtonTapped = "back_button_tapped"

    // MARK: - Favorites
    case chapterFavorited = "chapter_favorited"
    case chapterUnfavorited = "chapter_unfavorited"
    case favoriteChapterOpened = "favorite_chapter_opened"

    // MARK: - Settings & Preferences
    case settingsOpened = "settings_opened"
    case voiceSelectorOpened = "voice_selector_opened"
    case voiceChanged = "voice_changed"
    case contactSupportTapped = "contact_support_tapped"
    case privacyPolicyTapped = "privacy_policy_tapped"
    case termsOfServiceTapped = "terms_of_service_tapped"

    // MARK: - Premium & Paywall
    case paywallViewed = "paywall_viewed"
    case paywallDismissed = "paywall_dismissed"
    case goPremiumTapped = "go_premium_tapped"
    case subscriptionPlanSelected = "subscription_plan_selected"
    case purchaseInitiated = "purchase_initiated"
    case purchaseCompleted = "purchase_completed"
    case purchaseFailed = "purchase_failed"
    case restorePurchasesTapped = "restore_purchases_tapped"
    case restorePurchasesCompleted = "restore_purchases_completed"

    // MARK: - Profile
    case profileImageChanged = "profile_image_changed"
    case statisticsViewed = "statistics_viewed"

    // MARK: - Explore Map
    case mapViewed = "map_viewed"
    case mapCivilizationTapped = "map_civilization_tapped"
    case mapZoomed = "map_zoomed"

    // MARK: - Errors & Issues
    case errorOccurred = "error_occurred"
    case networkErrorOccurred = "network_error_occurred"
    case audioErrorOccurred = "audio_error_occurred"

    // MARK: - Content Refresh
    case contentRefreshed = "content_refreshed"
    case randomChaptersLoaded = "random_chapters_loaded"
}
