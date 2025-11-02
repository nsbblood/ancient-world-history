//  ProfileManager.swift
import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    
    @AppStorage("selectedVoiceType") var selectedVoiceType: String = VoiceType.femaleUS.rawValue
    @AppStorage("readChapterIds") private var readChapterIdsData: Data = Data()
    @AppStorage("isPremium") var isPremium: Bool = false
    @AppStorage("totalReadingTime") var totalReadingTime: Int = 0
    
    @Published var readChapterIds: Set<UUID> = []
    
    private init() {
        loadReadChapters()
    }
    
    private func loadReadChapters() {
        if let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: readChapterIdsData) {
            readChapterIds = decoded
        }
    }
    
    private func saveReadChapters() {
        if let encoded = try? JSONEncoder().encode(readChapterIds) {
            readChapterIdsData = encoded
        }
    }
    
    func markChapterAsRead(_ chapterId: UUID, duration: Int) {
        readChapterIds.insert(chapterId)
        totalReadingTime += duration
        saveReadChapters()
    }
    
    func isChapterRead(_ chapterId: UUID) -> Bool {
        readChapterIds.contains(chapterId)
    }
    
    func totalChaptersRead() -> Int {
        readChapterIds.count
    }
    
    func civilizationsExplored() -> Int {
        let readChapters = ContentLoader.shared.chapters.filter { readChapterIds.contains($0.id) }
        let storyIds = Set(readChapters.map { $0.storyId })
        let civIds = Set(ContentLoader.shared.stories.filter { storyIds.contains($0.id) }.map { $0.civilizationId })
        return civIds.count
    }
    
    func formattedTotalReadingTime() -> String {
        let hours = totalReadingTime / 3600
        let minutes = (totalReadingTime % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func readProgress(for storyId: UUID) -> Double {
        let chapters = ContentLoader.shared.chapters(for: storyId)
        guard !chapters.isEmpty else { return 0 }
        let readCount = chapters.filter { readChapterIds.contains($0.id) }.count
        return Double(readCount) / Double(chapters.count)
    }
    
    func canAccessContent() -> Bool {
        if isPremium { return true }
        let uniqueStoriesRead = Set(ContentLoader.shared.chapters.filter { readChapterIds.contains($0.id) }.map { $0.storyId })
        return uniqueStoriesRead.count < 3
    }
    
    var currentVoice: VoiceType {
        get { VoiceType(rawValue: selectedVoiceType) ?? .femaleUS }
        set {
            selectedVoiceType = newValue.rawValue
            AudioManager.shared.setVoice(newValue)
        }
    }
}
