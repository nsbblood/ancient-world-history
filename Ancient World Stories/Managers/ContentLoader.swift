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

    private init() {
        loadInitialData()
    }

    // MARK: - Load Data
    func loadInitialData() {
        Task {
            await loadAllData()
        }
    }

    func loadAllData() async {
        isLoading = true
        error = nil

        do {
            // Try to fetch from Supabase
            async let civilizationsTask = supabase.fetchCivilizations()
            async let storiesTask = supabase.fetchStories()
            async let chaptersTask = supabase.fetchChapters()

            let (fetchedCivs, fetchedStories, fetchedChapters) = try await (civilizationsTask, storiesTask, chaptersTask)

            self.civilizations = fetchedCivs
            self.stories = fetchedStories
            self.chapters = fetchedChapters

            print("✅ Successfully loaded \(fetchedCivs.count) civilizations, \(fetchedStories.count) stories, and \(fetchedChapters.count) chapters from Supabase")

        } catch {
            // Fallback to local JSON
            print("⚠️ Supabase failed, loading from local JSON: \(error.localizedDescription)")
            loadFromLocalJSON()
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
        decoder.keyDecodingStrategy = .convertFromSnakeCase

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
        chapters.filter { $0.storyId == storyId }.sorted { $0.orderNo < $1.orderNo }
    }

    /// Get civilization for a story
    func civilization(for story: Story) -> Civilization? {
        civilizations.first { $0.id == story.civilizationId }
    }

    /// Get story for a chapter
    func story(for chapter: Chapter) -> Story? {
        stories.first { $0.id == chapter.storyId }
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
