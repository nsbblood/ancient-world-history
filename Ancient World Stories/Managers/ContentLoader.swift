//
//  ContentLoader.swift
//  Ancient World Stories Universe
//
//  Created by Claude Code
//

import Foundation
import Combine

@MainActor
class ContentLoader: ObservableObject {
    static let shared = ContentLoader()

    @Published var civilizations: [Civilization] = []
    @Published var stories: [Story] = []
    @Published var chapters: [Chapter] = []
    @Published var isLoading = false
    @Published var isFullySynced = false // Track if full data is loaded
    @Published var error: String?

    private let supabase = SupabaseClient.shared
    private var hasInitialized = false
    private var loadedStoryIds: Set<UUID> = [] // Track which stories have chapters loaded

    private init() {
        // Don't load data in init - wait for explicit call after splash
    }

    // MARK: - Progressive Loading Strategy

    /// Initial quick load: 10 civilizations + 20 recent stories (instant app launch)
    func loadInitialData() {
        guard !hasInitialized else {
            print("ℹ️ ContentLoader already initialized, skipping...")
            return
        }
        hasInitialized = true
        print("🚀 ContentLoader: Progressive loading started...")

        Task {
            await loadQuickStart()

            // After quick start, load remaining data in background
            Task.detached { [weak self] in
                await self?.syncRemainingData()
            }
        }
    }

    /// PHASE 1: Quick start - Load minimal data for instant app launch (~15 KB)
    private func loadQuickStart() async {
        isLoading = true
        error = nil

        do {
            let currentLanguage = LanguageManager.shared.currentLanguageCode

            // Load first 10 civilizations + 20 stories + 50 chapters in parallel for quick start
            async let civsTask = supabase.fetchCivilizations(languageCode: currentLanguage, limit: 10)
            async let storiesTask = supabase.fetchStories(languageCode: currentLanguage, limit: 20)
            async let chaptersTask = supabase.fetchChapters(languageCode: currentLanguage)

            let (fetchedCivs, fetchedStories, fetchedChapters) = try await (civsTask, storiesTask, chaptersTask)

            self.civilizations = fetchedCivs
            self.stories = fetchedStories
            self.chapters = fetchedChapters

            let civsSize = fetchedCivs.count * 200
            let storiesSize = fetchedStories.count * 280
            let chaptersSize = fetchedChapters.count * 150
            let totalSizeKB = (civsSize + storiesSize + chaptersSize) / 1024

            print("⚡ Quick start loaded: \(fetchedCivs.count) civs, \(fetchedStories.count) stories, \(fetchedChapters.count) chapters")
            print("📦 Data size: ~\(totalSizeKB) KB")

        } catch {
            print("⚠️ Quick start failed, loading from local JSON: \(error.localizedDescription)")
            loadFromLocalJSON()
        }

        isLoading = false
    }

    /// PHASE 2: Background sync - Load all civilizations and stories (~50 KB)
    private func syncRemainingData() async {
        // Give user time to see initial content
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds delay

        print("🔄 Background sync: Loading remaining data...")

        do {
            let currentLanguage = LanguageManager.shared.currentLanguageCode

            // Load all civilizations and stories
            async let allCivsTask = supabase.fetchCivilizations(languageCode: currentLanguage)
            async let allStoriesTask = supabase.fetchStories(languageCode: currentLanguage)

            let (allCivs, allStories) = try await (allCivsTask, allStoriesTask)

            await MainActor.run {
                self.civilizations = allCivs
                self.stories = allStories
                self.isFullySynced = true
                print("✅ Full sync complete: \(allCivs.count) civilizations, \(allStories.count) stories")
            }

        } catch {
            print("ℹ️ Background sync failed: \(error.localizedDescription)")
        }
    }

    /// PHASE 3: On-demand chapter loading - Load chapters only when story is opened
    func loadChapters(for storyId: UUID) async {
        // Check if already loaded
        if loadedStoryIds.contains(storyId) {
            print("📖 Chapters for story \(storyId) already loaded")
            return
        }

        do {
            let currentLanguage = LanguageManager.shared.currentLanguageCode
            let fetchedChapters = try await supabase.fetchChapters(forStory: storyId, languageCode: currentLanguage)

            await MainActor.run {
                // Add new chapters, avoiding duplicates
                let newChapters = fetchedChapters.filter { newChapter in
                    !self.chapters.contains(where: { $0.id == newChapter.id })
                }
                self.chapters.append(contentsOf: newChapters)
                self.loadedStoryIds.insert(storyId)
                print("✅ Loaded \(fetchedChapters.count) chapters for story \(storyId)")
            }

        } catch {
            print("⚠️ Failed to load chapters for story \(storyId): \(error.localizedDescription)")
        }
    }

    /// Legacy method for backwards compatibility
    @available(*, deprecated, message: "Use loadInitialData() instead")
    func loadAllData() async {
        await loadQuickStart()
        await syncRemainingData()
    }

    /// Legacy method for backwards compatibility
    @available(*, deprecated, message: "Replaced by progressive loading")
    func syncFromSupabase() async {
        await syncRemainingData()
    }

    // MARK: - Local JSON Fallback
    private func loadFromLocalJSON() {
        guard let url = Bundle.main.url(forResource: "stories", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            error = "Failed to load local stories.json"
            return
        }

        let decoder = JSONDecoder()
        // Don't use convertFromSnakeCase - models have custom CodingKeys

        do {
            let content = try decoder.decode(UniverseData.self, from: data)
            self.civilizations = content.civilizations
            self.stories = content.stories
            self.chapters = content.chapters
            print("✅ Loaded \(civilizations.count) civilizations, \(stories.count) stories, and \(chapters.count) chapters from local JSON")
        } catch {
            self.error = "Failed to decode local JSON: \(error.localizedDescription)"
            print("❌ JSON decode error: \(error)")
        }
    }

    // MARK: - Helper Methods

    /// Get stories for a specific civilization (filtered by selected language)
    func stories(for civilizationId: UUID) -> [Story] {
        let selectedLang = LanguageManager.shared.currentLanguageCode
        return stories.filter { $0.civilizationId == civilizationId && $0.languageCode == selectedLang }
    }

    /// Get chapters for a specific story (filtered by selected language)
    func chapters(for storyId: UUID) -> [Chapter] {
        let selectedLang = LanguageManager.shared.currentLanguageCode
        return chapters
            .filter { $0.storyId == storyId && $0.languageCode == selectedLang }
            .sorted { $0.orderNo < $1.orderNo }
    }

    /// Get civilization for a story
    func civilization(for story: Story) -> Civilization? {
        civilizations.first { $0.id == story.civilizationId }
    }

    /// Get story for a chapter
    func story(for chapter: Chapter) -> Story? {
        stories.first { $0.id == chapter.storyId }
    }

    /// Get story by ID
    func story(for storyId: UUID) -> Story? {
        stories.first { $0.id == storyId }
    }

    /// Get random chapters from all stories (filtered by selected language)
    func randomChapters(count: Int = 10) -> [Chapter] {
        let selectedLang = LanguageManager.shared.currentLanguageCode
        let filteredChapters = chapters.filter { $0.languageCode == selectedLang }
        return Array(filteredChapters.shuffled().prefix(count))
    }

    /// Get civilizations grouped by region
    func civilizationsGroupedByRegion() -> [String: [Civilization]] {
        Dictionary(grouping: civilizations, by: { $0.region })
    }

    /// Get total chapter count for a story
    func chapterCount(for storyId: UUID) -> Int {
        chapters.filter { $0.storyId == storyId }.count
    }

    /// Get total story count for a civilization
    func storyCount(for civilizationId: UUID) -> Int {
        stories.filter { $0.civilizationId == civilizationId }.count
    }
}

// MARK: - Supporting Types
struct UniverseData: Codable {
    let civilizations: [Civilization]
    let stories: [Story]
    let chapters: [Chapter]
}
