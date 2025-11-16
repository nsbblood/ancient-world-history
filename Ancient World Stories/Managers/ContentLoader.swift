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

    // Persistent cache configuration
    private let cacheExpirationHours = 24 // Cache expires after 24 hours
    private var cacheDirectory: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("ContentCache")
    }

    private init() {
        // Don't load data in init - wait for explicit call after splash
        createCacheDirectoryIfNeeded()
    }

    private func createCacheDirectoryIfNeeded() {
        guard let cacheDir = cacheDirectory else { return }
        if !FileManager.default.fileExists(atPath: cacheDir.path) {
            try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
            print("📁 Created persistent cache directory")
        }
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

        // Try loading from persistent cache first
        if let cachedData = loadFromPersistentCache(), !isCacheExpired() {
            print("✨ Loaded data from persistent cache")
            self.civilizations = cachedData.civilizations
            self.stories = cachedData.stories
            self.chapters = cachedData.chapters
            isLoading = false

            // Sync in background to get latest updates
            Task.detached { [weak self] in
                await self?.syncFromSupabaseInBackground()
            }
            return
        }

        // Cache miss or expired - fetch from Supabase
        do {
            let currentLanguage = LanguageManager.shared.currentLanguageCode
            print("🌍 Loading content for language: \(currentLanguage)")

            // Load data WITHOUT language filter (we'll filter in memory)
            // This ensures we always have content, even if selected language has no content
            async let civsTask = supabase.fetchCivilizations(languageCode: nil, limit: nil)
            async let storiesTask = supabase.fetchStories(languageCode: nil, limit: nil)
            async let chaptersTask = supabase.fetchChapters(languageCode: nil)

            let (fetchedCivs, fetchedStories, fetchedChapters) = try await (civsTask, storiesTask, chaptersTask)

            self.civilizations = fetchedCivs
            self.stories = fetchedStories
            self.chapters = fetchedChapters

            // Save to persistent cache
            saveToPersistentCache()

            let civsSize = fetchedCivs.count * 200
            let storiesSize = fetchedStories.count * 280
            let chaptersSize = fetchedChapters.count * 150
            let totalSizeKB = (civsSize + storiesSize + chaptersSize) / 1024

            print("⚡ Quick start loaded: \(fetchedCivs.count) civs, \(fetchedStories.count) stories, \(fetchedChapters.count) chapters")
            print("📦 Data size: ~\(totalSizeKB) KB")
            print("📊 Language breakdown:")
            print("   Civs: \(fetchedCivs.filter { $0.languageCode == currentLanguage }.count) in \(currentLanguage), \(fetchedCivs.filter { $0.languageCode == "en" }.count) in English")
            print("   Stories: \(fetchedStories.filter { $0.languageCode == currentLanguage }.count) in \(currentLanguage), \(fetchedStories.filter { $0.languageCode == "en" }.count) in English")
            print("   Chapters: \(fetchedChapters.filter { $0.languageCode == currentLanguage }.count) in \(currentLanguage), \(fetchedChapters.filter { $0.languageCode == "en" }.count) in English")

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
            // Load all data without language filter (we filter in memory)
            async let allCivsTask = supabase.fetchCivilizations(languageCode: nil)
            async let allStoriesTask = supabase.fetchStories(languageCode: nil)

            let (allCivs, allStories) = try await (allCivsTask, allStoriesTask)

            await MainActor.run {
                self.civilizations = allCivs
                self.stories = allStories
                self.isFullySynced = true

                // Save updated data to persistent cache
                self.saveToPersistentCache()

                print("✅ Full sync complete: \(allCivs.count) civilizations, \(allStories.count) stories")
            }

        } catch {
            print("ℹ️ Background sync failed: \(error.localizedDescription)")
        }
    }

    /// Background sync from Supabase (used when loading from cache)
    private func syncFromSupabaseInBackground() async {
        print("🔄 Background sync: Checking for updates...")

        do {
            // Load all data without language filter (we filter in memory)
            async let allCivsTask = supabase.fetchCivilizations(languageCode: nil)
            async let allStoriesTask = supabase.fetchStories(languageCode: nil)
            async let allChaptersTask = supabase.fetchChapters(languageCode: nil)

            let (allCivs, allStories, allChapters) = try await (allCivsTask, allStoriesTask, allChaptersTask)

            await MainActor.run {
                // Only update if data has changed
                if allCivs.count != self.civilizations.count ||
                   allStories.count != self.stories.count ||
                   allChapters.count != self.chapters.count {
                    self.civilizations = allCivs
                    self.stories = allStories
                    self.chapters = allChapters
                    self.saveToPersistentCache()
                    print("✅ Background sync: Updated with new data")
                } else {
                    print("✅ Background sync: No updates needed")
                }
                self.isFullySynced = true
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
            // Load all chapters for this story (all languages)
            let fetchedChapters = try await supabase.fetchChapters(forStory: storyId, languageCode: nil)

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

    /// Get stories for a specific civilization (filtered by selected language, fallback to English)
    func stories(for civilizationId: UUID) -> [Story] {
        let selectedLang = LanguageManager.shared.currentLanguageCode
        let storiesInSelectedLang = stories.filter { $0.civilizationId == civilizationId && $0.languageCode == selectedLang }

        // Fallback to English if no content in selected language
        if storiesInSelectedLang.isEmpty && selectedLang != "en" {
            print("⚠️ No stories found in \(selectedLang) for civilization \(civilizationId), falling back to English")
            return stories.filter { $0.civilizationId == civilizationId && $0.languageCode == "en" }
        }

        return storiesInSelectedLang
    }

    /// Get chapters for a specific story (filtered by selected language, fallback to English)
    func chapters(for storyId: UUID) -> [Chapter] {
        let selectedLang = LanguageManager.shared.currentLanguageCode
        let chaptersInSelectedLang = chapters
            .filter { $0.storyId == storyId && $0.languageCode == selectedLang }
            .sorted { $0.orderNo < $1.orderNo }

        // Fallback to English if no content in selected language
        if chaptersInSelectedLang.isEmpty && selectedLang != "en" {
            print("⚠️ No chapters found in \(selectedLang) for story \(storyId), falling back to English")
            return chapters
                .filter { $0.storyId == storyId && $0.languageCode == "en" }
                .sorted { $0.orderNo < $1.orderNo }
        }

        return chaptersInSelectedLang
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

    /// Get random chapters from all stories (filtered by selected language, fallback to English)
    func randomChapters(count: Int = 10) -> [Chapter] {
        let selectedLang = LanguageManager.shared.currentLanguageCode
        let filteredChapters = chapters.filter { $0.languageCode == selectedLang }

        // Fallback to English if no content in selected language
        if filteredChapters.isEmpty && selectedLang != "en" {
            print("⚠️ No chapters found in \(selectedLang), falling back to English for random chapters")
            let englishChapters = chapters.filter { $0.languageCode == "en" }
            return Array(englishChapters.shuffled().prefix(count))
        }

        return Array(filteredChapters.shuffled().prefix(count))
    }

    /// Get civilizations for selected language (fallback to English)
    var filteredCivilizations: [Civilization] {
        let selectedLang = LanguageManager.shared.currentLanguageCode
        let civsInSelectedLang = civilizations.filter { $0.languageCode == selectedLang }

        // Fallback to English if no content in selected language
        if civsInSelectedLang.isEmpty && selectedLang != "en" {
            print("⚠️ No civilizations found in \(selectedLang), falling back to English")
            return civilizations.filter { $0.languageCode == "en" }
        }

        return civsInSelectedLang
    }

    /// Get civilizations grouped by region
    func civilizationsGroupedByRegion() -> [String: [Civilization]] {
        Dictionary(grouping: filteredCivilizations, by: { $0.region })
    }

    /// Get total chapter count for a story
    func chapterCount(for storyId: UUID) -> Int {
        chapters.filter { $0.storyId == storyId }.count
    }

    /// Get total story count for a civilization
    func storyCount(for civilizationId: UUID) -> Int {
        stories.filter { $0.civilizationId == civilizationId }.count
    }

    // MARK: - Persistent Cache Management

    private func saveToPersistentCache() {
        guard let cacheDir = cacheDirectory else {
            print("❌ Cache directory not available")
            return
        }

        let data = UniverseData(
            civilizations: civilizations,
            stories: stories,
            chapters: chapters
        )

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(data)

            let cacheFile = cacheDir.appendingPathComponent("content_cache.json")
            try jsonData.write(to: cacheFile)

            // Save timestamp
            UserDefaults.standard.set(Date(), forKey: "contentCacheTimestamp")

            let sizeKB = jsonData.count / 1024
            print("💾 Saved \(sizeKB)KB to persistent cache")
        } catch {
            print("❌ Failed to save to persistent cache: \(error)")
        }
    }

    private func loadFromPersistentCache() -> UniverseData? {
        guard let cacheDir = cacheDirectory else {
            print("❌ Cache directory not available")
            return nil
        }

        let cacheFile = cacheDir.appendingPathComponent("content_cache.json")

        guard FileManager.default.fileExists(atPath: cacheFile.path) else {
            print("ℹ️ No persistent cache found")
            return nil
        }

        do {
            let jsonData = try Data(contentsOf: cacheFile)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let data = try decoder.decode(UniverseData.self, from: jsonData)

            let sizeKB = jsonData.count / 1024
            print("📂 Loaded \(sizeKB)KB from persistent cache")
            return data
        } catch {
            print("❌ Failed to load from persistent cache: \(error)")
            return nil
        }
    }

    private func isCacheExpired() -> Bool {
        guard let timestamp = UserDefaults.standard.object(forKey: "contentCacheTimestamp") as? Date else {
            print("ℹ️ No cache timestamp found")
            return true
        }

        let hoursSinceCache = Date().timeIntervalSince(timestamp) / 3600
        let isExpired = hoursSinceCache >= Double(cacheExpirationHours)

        if isExpired {
            print("⏰ Cache expired (\(Int(hoursSinceCache)) hours old)")
        } else {
            print("✅ Cache is fresh (\(Int(hoursSinceCache)) hours old)")
        }

        return isExpired
    }

    func clearPersistentCache() {
        guard let cacheDir = cacheDirectory else { return }
        let cacheFile = cacheDir.appendingPathComponent("content_cache.json")

        try? FileManager.default.removeItem(at: cacheFile)
        UserDefaults.standard.removeObject(forKey: "contentCacheTimestamp")
        print("🗑️ Persistent cache cleared")
    }
}

// MARK: - Supporting Types
struct UniverseData: Codable {
    let civilizations: [Civilization]
    let stories: [Story]
    let chapters: [Chapter]
}
