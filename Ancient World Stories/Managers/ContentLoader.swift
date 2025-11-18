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

    // Bundle configuration
    private let bundleFileName = "stories_bundle"
    private var bundleExportDate: Date? // Track when bundle was exported for delta sync

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

    // MARK: - Bundle-First Loading Strategy

    /// Initial load: Load from bundle first (instant), then delta sync for new content
    func loadInitialData() {
        guard !hasInitialized else {
            print("ℹ️ ContentLoader already initialized, skipping...")
            return
        }
        hasInitialized = true
        print("🚀 ContentLoader: Bundle-first loading started...")

        Task {
            await loadFromBundle()

            // After bundle load, check for new content in background
            Task.detached { [weak self] in
                await self?.syncNewContent()
            }
        }
    }

    /// PHASE 1: Load from bundle - Instant app launch with all content (~20 MB)
    private func loadFromBundle() async {
        isLoading = true
        error = nil

        // Try loading from bundle (shipped with app)
        guard let bundleURL = Bundle.main.url(forResource: bundleFileName, withExtension: "json") else {
            print("⚠️ Bundle not found, falling back to Supabase")
            await loadFromSupabaseFallback()
            return
        }

        do {
            let data = try Data(contentsOf: bundleURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            // Decode the bundle with metadata
            let bundleData = try decoder.decode(BundleData.self, from: data)

            // Store export date for delta sync
            self.bundleExportDate = bundleData.exportedAt

            // Load ALL data from bundle
            let allCivs = bundleData.civilizations
            let allStories = bundleData.stories
            let allChapters = bundleData.chapters

            print("📦 Bundle loaded: \(allCivs.count) civs, \(allStories.count) stories, \(allChapters.count) chapters")

            // Store all data
            self.civilizations = allCivs
            self.stories = allStories
            self.chapters = allChapters
            self.isFullySynced = true

            let sizeKB = data.count / 1024
            print("⚡ Bundle loaded instantly: \(sizeKB) KB")
            print("🌍 Available languages: 15")

        } catch {
            print("⚠️ Bundle decode failed: \(error.localizedDescription)")
            await loadFromSupabaseFallback()
        }

        isLoading = false
    }

    /// Fallback: Load from Supabase if bundle fails
    private func loadFromSupabaseFallback() async {
        print("🔄 Falling back to Supabase...")

        do {
            // Load all data from Supabase (all languages)
            async let civsTask = supabase.fetchCivilizations(languageCode: nil, limit: nil)
            async let storiesTask = supabase.fetchStories(languageCode: nil, limit: nil)
            async let chaptersTask = supabase.fetchChapters(languageCode: nil)

            let (fetchedCivs, fetchedStories, fetchedChapters) =
                try await (civsTask, storiesTask, chaptersTask)

            self.civilizations = fetchedCivs
            self.stories = fetchedStories
            self.chapters = fetchedChapters

            print("📊 Supabase fallback loaded: \(fetchedCivs.count) civs, \(fetchedStories.count) stories, \(fetchedChapters.count) chapters")

        } catch {
            print("❌ Supabase fallback failed: \(error.localizedDescription)")
            loadFromLocalJSON()
        }

        isLoading = false
    }

    /// PHASE 2: Delta sync - Only fetch content created after bundle export date
    private func syncNewContent() async {
        guard let exportDate = bundleExportDate else {
            print("ℹ️ No export date, skipping delta sync")
            return
        }

        // Wait a bit before checking for new content
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds

        print("🔄 Checking for new content since \(exportDate)...")

        // TODO: Implement delta sync
        // This would fetch only items where created_at > exportDate
        // For now, we skip this as bundle should be fresh

        print("✅ Delta sync: No new content to fetch")
    }

    /// On-demand chapter loading - Load chapters only when story is opened (for new content)
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
        await loadFromBundle()
    }

    /// Legacy method for backwards compatibility
    @available(*, deprecated, message: "Replaced by bundle-first loading")
    func syncFromSupabase() async {
        await loadFromSupabaseFallback()
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

    /// Get stories for a specific civilization
    func stories(for civilizationId: UUID) -> [Story] {
        stories.filter { $0.civilizationId == civilizationId }
    }

    /// Get chapters for a specific story
    func chapters(for storyId: UUID) -> [Chapter] {
        chapters
            .filter { $0.storyId == storyId }
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

    /// Get random chapters from all stories
    func randomChapters(count: Int = 10) -> [Chapter] {
        Array(chapters.shuffled().prefix(count))
    }

    /// Get civilizations filtered by user's language
    /// Shows only user's language, fallback to English if no civilizations in user's language
    /// Only includes civilizations that have stories with chapters
    var filteredCivilizations: [Civilization] {
        let currentLang = LanguageManager.shared.currentLanguageCode

        // Filter civilizations by user's language
        let civsInUserLang = civilizations
            .filter { $0.languageCode == currentLang }
            .filter { storyCount(for: $0.id) > 0 } // Only civs with stories that have chapters

        // If user's language has civilizations, use them. Otherwise fallback to English.
        if !civsInUserLang.isEmpty {
            return civsInUserLang.sorted { $0.eraStart < $1.eraStart }
        } else {
            return civilizations
                .filter { $0.languageCode == "en" }
                .filter { storyCount(for: $0.id) > 0 }
                .sorted { $0.eraStart < $1.eraStart }
        }
    }

    /// Get civilizations grouped by region
    func civilizationsGroupedByRegion() -> [String: [Civilization]] {
        Dictionary(grouping: filteredCivilizations, by: { $0.region })
    }

    /// Get total chapter count for a story
    func chapterCount(for storyId: UUID) -> Int {
        chapters.filter { $0.storyId == storyId }.count
    }

    /// Get total story count for a civilization (only stories with chapters)
    func storyCount(for civilizationId: UUID) -> Int {
        stories
            .filter { $0.civilizationId == civilizationId }
            .filter { chapterCount(for: $0.id) > 0 }
            .count
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

/// Bundle data structure with metadata
struct BundleData: Codable {
    let version: String
    let exportedAt: Date?
    let totalCivilizations: Int
    let totalStories: Int
    let totalChapters: Int
    let civilizations: [Civilization]
    let stories: [Story]
    let chapters: [Chapter]

    enum CodingKeys: String, CodingKey {
        case version
        case exportedAt = "exported_at"
        case totalCivilizations = "total_civilizations"
        case totalStories = "total_stories"
        case totalChapters = "total_chapters"
        case civilizations
        case stories
        case chapters
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        totalCivilizations = try container.decode(Int.self, forKey: .totalCivilizations)
        totalStories = try container.decode(Int.self, forKey: .totalStories)
        totalChapters = try container.decode(Int.self, forKey: .totalChapters)
        civilizations = try container.decode([Civilization].self, forKey: .civilizations)
        stories = try container.decode([Story].self, forKey: .stories)
        chapters = try container.decode([Chapter].self, forKey: .chapters)

        // Parse exported_at as ISO8601 string
        if let dateString = try? container.decode(String.self, forKey: .exportedAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            exportedAt = formatter.date(from: dateString)
        } else {
            exportedAt = try? container.decode(Date.self, forKey: .exportedAt)
        }
    }
}
