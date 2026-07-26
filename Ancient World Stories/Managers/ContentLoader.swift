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
    @Published var isFullySynced = false
    @Published var error: String?

    private var hasInitialized = false

    // Bundle configuration
    private let bundleFileName = "stories_bundle"
    private var bundleExportDate: Date?

    private init() {}

    func clearPersistentCache() {
        civilizations = []
        stories = []
        chapters = []
        hasInitialized = false
    }

    // MARK: - Bundle-First Loading

    func loadInitialData() {
        guard !hasInitialized else {
            print("ℹ️ ContentLoader already initialized, skipping...")
            return
        }
        hasInitialized = true
        print("🚀 ContentLoader: Bundle-first loading started...")

        Task {
            await loadFromBundle()
        }
    }

    /// Force a fresh load (used after failures / language changes).
    func reload() {
        clearPersistentCache()
        loadInitialData()
    }

    private func loadFromBundle() async {
        isLoading = true
        error = nil

        guard let bundleURL = Bundle.main.url(forResource: bundleFileName, withExtension: "json") else {
            print("⚠️ Bundle not found, falling back to local JSON")
            loadFromLocalJSON()
            finalizeLoad()
            return
        }

        do {
            let data = try Data(contentsOf: bundleURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let bundleData = try decoder.decode(BundleData.self, from: data)

            self.bundleExportDate = bundleData.exportedAt
            self.civilizations = bundleData.civilizations
            self.stories = bundleData.stories
            self.chapters = bundleData.chapters
            self.isFullySynced = true

            let sizeKB = data.count / 1024
            print("⚡ Bundle loaded: \(sizeKB) KB, \(civilizations.count) civs, \(stories.count) stories, \(chapters.count) chapters")

        } catch {
            print("⚠️ Bundle decode failed: \(error.localizedDescription)")
            loadFromLocalJSON()
        }

        finalizeLoad()
    }

    private func finalizeLoad() {
        if civilizations.isEmpty || chapters.isEmpty {
            error = error ?? "No stories found in the app bundle. Please reinstall the app."
            hasInitialized = false
        }
        isLoading = false
    }

    // MARK: - Local JSON Fallback

    private func loadFromLocalJSON() {
        guard let url = Bundle.main.url(forResource: "stories", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            error = "Failed to load local stories.json"
            return
        }

        let decoder = JSONDecoder()

        do {
            let content = try decoder.decode(UniverseData.self, from: data)
            self.civilizations = content.civilizations
            self.stories = content.stories
            self.chapters = content.chapters
            print("✅ Loaded \(civilizations.count) civilizations, \(stories.count) stories, \(chapters.count) chapters from local JSON")
        } catch {
            self.error = "Failed to decode local JSON: \(error.localizedDescription)"
            print("❌ JSON decode error: \(error)")
        }
    }

    // MARK: - Helper Methods

    func stories(for civilizationId: UUID) -> [Story] {
        stories.filter { $0.civilizationId == civilizationId }
    }

    func chapters(for storyId: UUID) -> [Chapter] {
        chapters
            .filter { $0.storyId == storyId }
            .sorted { $0.orderNo < $1.orderNo }
    }

    func civilization(for story: Story) -> Civilization? {
        civilizations.first { $0.id == story.civilizationId }
    }

    func story(for chapter: Chapter) -> Story? {
        stories.first { $0.id == chapter.storyId }
    }

    func story(for storyId: UUID) -> Story? {
        stories.first { $0.id == storyId }
    }

    func randomChapters(count: Int = 10) -> [Chapter] {
        Array(chapters.shuffled().prefix(count))
    }

    func getDailyChapter() -> Chapter? {
        // Daily story is marketed as free — only pick first chapters so free users aren't locked out
        let freeChapters = chapters.filter { $0.orderNo == 1 }
        let pool = freeChapters.isEmpty ? chapters : freeChapters
        guard !pool.isEmpty else { return nil }

        let now = Date()
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        let year = calendar.component(.year, from: now)

        let seed = year * 1000 + dayOfYear
        let index = seed % pool.count
        return pool[index]
    }

    var collections: [StoryCollection] {
        // Stable ordering — reshuffling on every access made collections jump around in the UI
        let availableStories = stories.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }

        var cols: [StoryCollection] = []

        if availableStories.count >= 3 {
            cols.append(StoryCollection(
                id: "epic_battles",
                title: "Epic Battles",
                subtitle: "Tales of conquest and glory",
                iconName: "shield.fill",
                colorHex: "E63946",
                storyIds: Array(availableStories.prefix(3).map(\.id))
            ))
        }

        if availableStories.count >= 6 {
            cols.append(StoryCollection(
                id: "mythology",
                title: "Myth & Legend",
                subtitle: "Gods, monsters, and heroes",
                iconName: "bolt.fill",
                colorHex: "F4A261",
                storyIds: Array(availableStories.dropFirst(3).prefix(3).map(\.id))
            ))
        }

        if availableStories.count >= 9 {
            cols.append(StoryCollection(
                id: "great_leaders",
                title: "Great Leaders",
                subtitle: "Kings, Queens, and Pharaohs",
                iconName: "crown.fill",
                colorHex: "2A9D8F",
                storyIds: Array(availableStories.dropFirst(6).prefix(3).map(\.id))
            ))
        }

        return cols
    }

    var filteredCivilizations: [Civilization] {
        let currentLang = LanguageManager.shared.currentLanguageCode

        let civsInUserLang = civilizations
            .filter { $0.languageCode == currentLang }
            .filter { storyCount(for: $0.id) > 0 }

        if !civsInUserLang.isEmpty {
            return civsInUserLang.sorted { $0.startYear < $1.startYear }
        } else {
            return civilizations
                .filter { $0.languageCode == "en" }
                .filter { storyCount(for: $0.id) > 0 }
                .sorted { $0.startYear < $1.startYear }
        }
    }

    func civilizationsGroupedByRegion() -> [String: [Civilization]] {
        Dictionary(grouping: filteredCivilizations, by: { $0.region })
    }

    func chapterCount(for storyId: UUID) -> Int {
        chapters.filter { $0.storyId == storyId }.count
    }

    func storyCount(for civilizationId: UUID) -> Int {
        stories
            .filter { $0.civilizationId == civilizationId }
            .filter { chapterCount(for: $0.id) > 0 }
            .count
    }
}

// MARK: - Supporting Types

struct UniverseData: Codable {
    let civilizations: [Civilization]
    let stories: [Story]
    let chapters: [Chapter]
}

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

        if let dateString = try? container.decode(String.self, forKey: .exportedAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            exportedAt = formatter.date(from: dateString)
        } else {
            exportedAt = try? container.decode(Date.self, forKey: .exportedAt)
        }
    }
}
