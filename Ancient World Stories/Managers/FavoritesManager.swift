//  FavoritesManager.swift
import Foundation
import SwiftUI
import Combine

@MainActor
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    @Published var favoriteChapterIds: Set<UUID> = []
    private let favoritesKey = "favoriteChapterIds"
    private var hasLoaded = false

    private init() {
        // Don't load in init - lazy load on first access
    }

    private func ensureLoaded() {
        guard !hasLoaded else { return }
        hasLoaded = true
        loadFavorites()
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            favoriteChapterIds = decoded
        }
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteChapterIds) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    func toggleFavorite(chapterId: UUID) {
        ensureLoaded()
        if favoriteChapterIds.contains(chapterId) {
            favoriteChapterIds.remove(chapterId)
        } else {
            favoriteChapterIds.insert(chapterId)
        }
        saveFavorites()
    }

    func isFavorite(chapterId: UUID) -> Bool {
        ensureLoaded()
        return favoriteChapterIds.contains(chapterId)
    }

    func getFavoriteChapters() -> [Chapter] {
        ensureLoaded()
        return ContentLoader.shared.chapters.filter { favoriteChapterIds.contains($0.id) }
    }

    func favoriteCount() -> Int {
        ensureLoaded()
        return favoriteChapterIds.count
    }
}
