//  ProfileManager.swift
import Foundation
import SwiftUI
import Combine
import RevenueCat

@MainActor
class ProfileManager: ObservableObject {
    static let shared = ProfileManager()

    @AppStorage("selectedVoiceType") var selectedVoiceType: String = VoiceType.femaleUS.rawValue
    @AppStorage("readChapterIds") private var readChapterIdsData: Data = Data()
    @AppStorage("isPremium") var isPremium: Bool = false
    @AppStorage("totalReadingTime") var totalReadingTime: Int = 0
    @AppStorage("profileImageData") private var profileImageData: Data?
    @AppStorage("currentStreak") var currentStreak: Int = 0
    @AppStorage("lastReadDate") var lastReadDate: Double = 0

    @Published var readChapterIds: Set<UUID> = []
    @Published var profileImage: UIImage?
    private var hasLoadedData = false
    private var hasLoadedImage = false
    private var entitlementTask: Task<Void, Never>?

    private init() {
        // Don't load data in init - wait for explicit call to improve app startup time
        // Don't check premium status in init - wait for explicit call after splash and RevenueCat configuration
    }

    func loadInitialDataIfNeeded() {
        guard !hasLoadedData else { return }
        hasLoadedData = true
        // Only load critical data - defer image loading
        loadReadChapters()
        // Don't load profile image yet - lazy load when ProfileView is opened
    }

    func checkPremiumStatus() async {
        guard Purchases.isConfigured else {
            print("⚠️ Skipping premium check — RevenueCat not configured yet")
            return
        }
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let hasPremium = customerInfo.entitlements["premium"]?.isActive == true
            self.isPremium = hasPremium
        } catch {
            print("❌ Error checking premium status: \(error)")
        }
    }

    /// `isPremium` is cached in AppStorage so the UI can render instantly, which means it goes
    /// stale when a subscription is cancelled, expires or is renewed while the app is running.
    /// RevenueCat's customer info stream pushes every entitlement change, so mirror it here.
    func startObservingEntitlements() {
        guard entitlementTask == nil, Purchases.isConfigured else { return }
        entitlementTask = Task { [weak self] in
            for await customerInfo in Purchases.shared.customerInfoStream {
                self?.isPremium = customerInfo.entitlements["premium"]?.isActive == true
            }
        }
    }

    func ensureProfileImageLoaded() {
        guard !hasLoadedImage else { return }
        hasLoadedImage = true
        loadProfileImage()
    }

    private func loadProfileImage() {
        if let data = profileImageData {
            profileImage = UIImage(data: data)
        }
    }

    func saveProfileImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            profileImageData = data
            profileImage = image
        }
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
        updateStreak()
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = Date()
        let todayStart = calendar.startOfDay(for: today)
        
        if lastReadDate == 0 {
            // First time reading
            currentStreak = 1
            lastReadDate = todayStart.timeIntervalSince1970
            return
        }
        
        let lastRead = Date(timeIntervalSince1970: lastReadDate)
        let lastReadStart = calendar.startOfDay(for: lastRead)
        
        let components = calendar.dateComponents([.day], from: lastReadStart, to: todayStart)
        
        if let days = components.day {
            if days == 1 {
                // Read yesterday, increment streak
                currentStreak += 1
                lastReadDate = todayStart.timeIntervalSince1970
            } else if days > 1 {
                // Missed a day, reset streak
                currentStreak = 1
                lastReadDate = todayStart.timeIntervalSince1970
            }
            // If days == 0, already read today, do nothing to streak
        }
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
    
    var currentVoice: VoiceType {
        get { VoiceType(rawValue: selectedVoiceType) ?? .femaleUS }
        set {
            selectedVoiceType = newValue.rawValue
            AudioManager.shared.setVoice(newValue)
        }
    }
}
