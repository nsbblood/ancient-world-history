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
    @Published var error: String?

    private let supabase = SupabaseClient.shared
    private var hasInitialized = false

    private init() {
        // Don't load data in init - wait for explicit call after splash
    }

    // MARK: - Load Data
    func loadInitialData() {
        guard !hasInitialized else {
            print("ℹ️ ContentLoader already initialized, skipping...")
            return
        }
        hasInitialized = true
        print("🚀 ContentLoader: Starting to load data from Supabase...")
        Task {
            await loadAllData()
        }
    }

    func loadAllData() async {
        isLoading = true
        error = nil

        // Load local JSON first for instant app launch
        loadFromLocalJSON()
        isLoading = false

        // Then try to sync from Supabase in background (non-blocking)
        Task {
            do {
                async let civilizationsTask = supabase.fetchCivilizations()
                async let storiesTask = supabase.fetchStories()
                async let chaptersTask = supabase.fetchChapters()

                let (fetchedCivs, fetchedStories, fetchedChapters) = try await (civilizationsTask, storiesTask, chaptersTask)

                // Only update if we got data
                if !fetchedCivs.isEmpty && !fetchedStories.isEmpty && !fetchedChapters.isEmpty {
                    self.civilizations = fetchedCivs
                    self.stories = fetchedStories
                    self.chapters = fetchedChapters
                    print("✅ Successfully synced \(fetchedCivs.count) civilizations, \(fetchedStories.count) stories, and \(fetchedChapters.count) chapters from Supabase")
                }
            } catch {
                print("ℹ️ Supabase sync skipped: \(error.localizedDescription)")
            }
        }
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

    /// Get random chapters from all stories
    func randomChapters(count: Int = 10) -> [Chapter] {
        Array(chapters.shuffled().prefix(count))
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
