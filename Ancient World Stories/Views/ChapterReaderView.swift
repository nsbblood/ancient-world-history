// ChapterReaderView.swift
import SwiftUI

struct ChapterReaderView: View {
    let initialChapter: Chapter
    let story: Story
    let civilization: Civilization
    let allChapters: [Chapter]

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileManager = ProfileManager.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @ObservedObject private var analytics = AnalyticsManager.shared
    @ObservedObject private var audioManager = AudioManager.shared

    @State private var currentChapter: Chapter
    @State private var hasMarkedAsRead = false
    @State private var isCinematicMode = false
    @State private var showPaywall = false

    init(chapter: Chapter, story: Story, civilization: Civilization, allChapters: [Chapter]) {
        self.initialChapter = chapter
        self.story = story
        self.civilization = civilization
        self.allChapters = allChapters
        self._currentChapter = State(initialValue: chapter)
    }

    var currentIndex: Int? {
        allChapters.firstIndex(where: { $0.id == currentChapter.id })
    }

    var nextChapter: Chapter? {
        guard let index = currentIndex, index + 1 < allChapters.count else { return nil }
        return allChapters[index + 1]
    }

    var previousChapter: Chapter? {
        guard let index = currentIndex, index > 0 else { return nil }
        return allChapters[index - 1]
    }

    var isFavorite: Bool {
        favoritesManager.isFavorite(chapterId: currentChapter.id)
    }

    /// Same rule as the list screens: chapter 1 is free, everything else needs premium.
    private func isLocked(_ chapter: Chapter) -> Bool {
        chapter.orderNo > 1 && !profileManager.isPremium
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    if isCinematicMode {
                        Color.black.ignoresSafeArea()
                    }
                    
                    VStack(spacing: 0) {
                        // Scrollable content area
                        ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: isCinematicMode ? .center : .leading, spacing: 12) {
                                Text(civilization.name)
                                    .font(.serifCaption())
                                    .foregroundColor(isCinematicMode ? .orange : .appAccent)

                                Text(story.title)
                                    .font(.serifBody())
                                    .foregroundColor(isCinematicMode ? .white.opacity(0.7) : .appText.opacity(0.7))

                                Text(currentChapter.title)
                                    .font(isCinematicMode ? .system(size: 32, weight: .bold, design: .serif) : .serifTitle2())
                                    .foregroundColor(isCinematicMode ? .white : .appText)

                                HStack(spacing: 12) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                            .foregroundColor(isCinematicMode ? .white.opacity(0.7) : .appText.opacity(0.7))
                                        Text(currentChapter.formattedDuration)
                                    }
                                    Text("•")
                                    Text("reader.chapter".localized(with: currentChapter.orderNo))
                                }
                                .font(.serifCaption())
                                .foregroundColor(isCinematicMode ? .white.opacity(0.7) : .appText.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity, alignment: isCinematicMode ? .center : .leading)

                            Divider().background(isCinematicMode ? Color.white.opacity(0.2) : Color.appSecondary)

                            Text(currentChapter.text)
                                .font(isCinematicMode ? .system(size: 22, weight: .medium, design: .serif) : .readingFont())
                                .foregroundColor(isCinematicMode ? Color(hex: "F4A261") : .appText)
                                .lineSpacing(isCinematicMode ? 12 : 8)
                                .multilineTextAlignment(isCinematicMode ? .center : .leading)
                                .textSelection(.enabled)
                                
                            Divider().background(Color.appSecondary).padding(.vertical, 16)
                            
                            Button(action: {
                                Task { @MainActor in
                                    generateAndShareQuote()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("reader.share_quote".localized)
                                }
                                .font(.serifHeadline())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.accentColor)
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom, 8)
                        }
                        .padding()
                        .id(currentChapter.id)
                    }
                    .frame(height: max(0, geometry.size.height - (isCinematicMode ? 0 : 80)))
                    .background(isCinematicMode ? Color.black : Color.backgroundColor)

                    // Chapter navigation
                    if !isCinematicMode && (previousChapter != nil || nextChapter != nil) {
                        VStack(spacing: 0) {
                            Divider()
                                .background(Color.appSecondary.opacity(0.3))

                            HStack(spacing: 0) {
                                if let previous = previousChapter {
                                    Button {
                                        analytics.track(event: .previousChapterTapped, parameters: [
                                            "current_chapter_id": currentChapter.id.uuidString,
                                            "previous_chapter_id": previous.id.uuidString,
                                            "previous_chapter_title": previous.title
                                        ])
                                        if isLocked(previous) {
                                            showPaywall = true
                                        } else {
                                            navigateToPreviousChapter(previous)
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: isLocked(previous) ? "lock.fill" : "chevron.left")
                                                .foregroundColor(.accentColor)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("reader.previous_chapter".localized)
                                                    .font(.serifCaption())
                                                    .foregroundColor(.appText.opacity(0.7))

                                                Text(previous.title)
                                                    .font(.serifBody())
                                                    .foregroundColor(isLocked(previous) ? .appText.opacity(0.5) : .appText)
                                                    .lineLimit(1)
                                            }

                                            Spacer()
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .buttonStyle(PlainButtonStyle())
                                }

                                if previousChapter != nil && nextChapter != nil {
                                    Divider()
                                        .background(Color.appSecondary.opacity(0.3))
                                }

                                if let next = nextChapter {
                                    Button {
                                        analytics.track(event: .nextChapterTapped, parameters: [
                                            "current_chapter_id": currentChapter.id.uuidString,
                                            "next_chapter_id": next.id.uuidString,
                                            "next_chapter_title": next.title
                                        ])
                                        if isLocked(next) {
                                            showPaywall = true
                                        } else {
                                            navigateToNextChapter(next)
                                        }
                                    } label: {
                                        HStack {
                                            Spacer()

                                            VStack(alignment: .trailing, spacing: 2) {
                                                Text("reader.next_chapter".localized)
                                                    .font(.serifCaption())
                                                    .foregroundColor(.appText.opacity(0.7))

                                                Text(next.title)
                                                    .font(.serifBody())
                                                    .foregroundColor(isLocked(next) ? .appText.opacity(0.5) : .appText)
                                                    .lineLimit(1)
                                            }

                                            Image(systemName: isLocked(next) ? "lock.fill" : "chevron.right")
                                                .foregroundColor(.accentColor)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        .background(Color.backgroundColor)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if isCinematicMode {
                        Button {
                            withAnimation {
                                isCinematicMode = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.6))
                                .padding()
                        }
                    }
                }
            }
            .background(isCinematicMode ? Color.black : Color.backgroundColor)
            .navigationBarHidden(isCinematicMode)
            .statusBarHidden(isCinematicMode)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        analytics.track(event: .backButtonTapped, parameters: [
                            "chapter_id": currentChapter.id.uuidString,
                            "reading_time_seconds": 0
                        ])
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("reader.back".localized)
                        }
                        .font(.serifBody())
                        .foregroundColor(.accentColor)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            audioManager.setVoice(profileManager.currentVoice)
                            audioManager.togglePlayback(for: currentChapter.text)
                            analytics.track(event: .featureUsed, parameters: [
                                "feature": "tts_playback",
                                "is_playing": audioManager.isPlaying
                            ])
                        } label: {
                            Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "speaker.wave.2.fill")
                                .foregroundColor(.accentColor)
                                .font(.system(size: 20))
                        }

                        Button {
                            withAnimation {
                                isCinematicMode = true
                                analytics.track(event: .featureUsed, parameters: ["feature": "cinematic_mode"])
                            }
                        } label: {
                            Image(systemName: "theatermasks")
                                .foregroundColor(.accentColor)
                                .font(.system(size: 20))
                        }

                        Button {
                            if isFavorite {
                                analytics.track(event: .chapterUnfavorited, parameters: [
                                    "chapter_id": currentChapter.id.uuidString,
                                    "chapter_title": currentChapter.title
                                ])
                            } else {
                                analytics.track(event: .chapterFavorited, parameters: [
                                    "chapter_id": currentChapter.id.uuidString,
                                    "chapter_title": currentChapter.title,
                                    "story_title": story.title
                                ])
                            }
                            favoritesManager.toggleFavorite(chapterId: currentChapter.id)
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(.accentColor)
                                .font(.system(size: 20))
                        }
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.backgroundColor, for: .navigationBar)
        }
        .onAppear {
            analytics.track(event: .chapterOpened, parameters: [
                "chapter_id": currentChapter.id.uuidString,
                "chapter_title": currentChapter.title,
                "chapter_number": currentChapter.orderNo,
                "story_title": story.title,
                "civilization_name": civilization.name
            ])
            markAsRead()
        }
        .onDisappear {
            audioManager.stop()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall)
        }
        }
    }

    private func navigateToNextChapter(_ next: Chapter) {
        audioManager.stop()
        currentChapter = next
        hasMarkedAsRead = false
        markAsRead()
    }

    private func navigateToPreviousChapter(_ previous: Chapter) {
        audioManager.stop()
        currentChapter = previous
        hasMarkedAsRead = false
        markAsRead()
    }

    private func markAsRead() {
        if !hasMarkedAsRead {
            profileManager.markChapterAsRead(currentChapter.id, duration: currentChapter.duration)
            hasMarkedAsRead = true
        }
    }

    @MainActor
    private func generateAndShareQuote() {
        let quoteCard = QuoteCardView(chapter: currentChapter, civilization: civilization)
        let renderer = ImageRenderer(content: quoteCard)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            renderer.scale = windowScene.screen.scale

            if let uiImage = renderer.uiImage {
                let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)

                if let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {

                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = window
                        popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }

                    rootVC.present(activityVC, animated: true)
                    analytics.track(event: .shareQuoteTapped, parameters: [
                        "chapter_id": currentChapter.id.uuidString,
                        "civilization_name": civilization.name
                    ])
                }
            }
        }
    }
}
