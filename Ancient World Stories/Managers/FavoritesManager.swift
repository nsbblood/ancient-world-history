//  FavoritesManager.swift
import Foundation
import SwiftUI
import Combine

@MainActor
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteStoryIds: Set<UUID> = []
    private let favoritesKey = "favoriteStoryIds"
    
    private init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            favoriteStoryIds = decoded
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteStoryIds) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    func toggleFavorite(storyId: UUID) {
        if favoriteStoryIds.contains(storyId) {
            favoriteStoryIds.remove(storyId)
        } else {
            favoriteStoryIds.insert(storyId)
        }
        saveFavorites()
    }
    
    func isFavorite(storyId: UUID) -> Bool {
        favoriteStoryIds.contains(storyId)
    }
    
    func getFavoriteStories() -> [Story] {
        ContentLoader.shared.stories.filter { favoriteStoryIds.contains($0.id) }
    }
    
    func favoriteCount() -> Int {
        favoriteStoryIds.count
    }
}
