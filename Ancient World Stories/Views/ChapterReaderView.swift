// ChapterReaderView.swift
import SwiftUI
import AVFoundation

struct ChapterReaderView: View {
    let initialChapter: Chapter
    let story: Story
    let civilization: Civilization
    let allChapters: [Chapter]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.displayScale) private var displayScale
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var profileManager = ProfileManager.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @ObservedObject private var analytics = AnalyticsManager.shared

    @State private var currentChapter: Chapter
    @State private var hasMarkedAsRead = false
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var screenWidth: CGFloat = 0
    @State private var showPaywall = false
    @State private var showVoiceSelector = false

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
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Scrollable content area
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(civilization.name)
                                    .font(.serifCaption())
                                    .foregroundColor(.appAccent)

                                Text(story.title)
                                    .font(.serifBody())
                                    .foregroundColor(.appText.opacity(0.7))

                                Text(currentChapter.title)
                                    .font(.serifTitle2())
                                    .foregroundColor(.appText)

                                HStack(spacing: 12) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                            .foregroundColor(.appText.opacity(0.7))
                                        Text(currentChapter.formattedDuration)
                                    }
                                    Text("•")
                                    Text("Chapter \(currentChapter.orderNo)")
                                }
                                .font(.serifCaption())
                                .foregroundColor(.appText.opacity(0.7))
                            }

                            Divider().background(Color.appSecondary)

                            Text(currentChapter.text)
                                .font(.readingFont())
                                .foregroundColor(.appText)
                                .lineSpacing(8)
                                .textSelection(.enabled)
                        }
                        .padding()
                        .id(currentChapter.id)
                    }
                    .frame(height: max(0, geometry.size.height - 150))
                    .background(Color.backgroundColor)

                // Fixed bottom controls
                VStack(spacing: 0) {
                    AudioPlayerControls(
                        isPlaying: audioManager.isPlaying,
                        progress: audioManager.currentProgress,
                        onPlayPause: {
                            if audioManager.isPlaying {
                                analytics.track(event: .audioPlaybackPaused, parameters: [
                                    "chapter_id": currentChapter.id.uuidString,
                                    "progress_percentage": Int(audioManager.currentProgress * 100)
                                ])
                                audioManager.pause()
                            } else if audioManager.synthesizer.isPaused {
                                analytics.track(event: .audioPlaybackResumed, parameters: [
                                    "chapter_id": currentChapter.id.uuidString,
                                    "progress_percentage": Int(audioManager.currentProgress * 100)
                                ])
                                audioManager.resume()
                            } else {
                                // Check if premium for Neural AI TTS
                                if !profileManager.isPremium {
                                    analytics.track(event: .paywallViewed, parameters: [
                                        "source": "audio_playback",
                                        "trigger": "non_premium_user"
                                    ])
                                    showPaywall = true
                                } else {
                                    analytics.track(event: .audioPlaybackStarted, parameters: [
                                        "chapter_id": currentChapter.id.uuidString,
                                        "voice_type": "neural_ai",
                                        "is_premium": true
                                    ])
                                    audioManager.speak(text: currentChapter.text, language: currentChapter.languageCode)
                                    markAsRead()
                                }
                            }
                        },
                        onStop: {
                            analytics.track(event: .audioPlaybackStopped, parameters: [
                                "chapter_id": currentChapter.id.uuidString,
                                "progress_percentage": Int(audioManager.currentProgress * 100)
                            ])
                            audioManager.stop()
                        }
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)

                    if previousChapter != nil || nextChapter != nil {
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
                                    navigateToPreviousChapter(previous)
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(.accentColor)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Previous Chapter")
                                                .font(.serifCaption())
                                                .foregroundColor(.appText.opacity(0.7))

                                            Text(previous.title)
                                                .font(.serifBody())
                                                .foregroundColor(.appText)
                                                .lineLimit(1)
                                        }

                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 1.5)
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
                                    navigateToNextChapter(next)
                                } label: {
                                    HStack {
                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("Next Chapter")
                                                .font(.serifCaption())
                                                .foregroundColor(.appText.opacity(0.7))

                                            Text(next.title)
                                                .font(.serifBody())
                                                .foregroundColor(.appText)
                                                .lineLimit(1)
                                        }

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.accentColor)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 1.5)
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .background(Color.backgroundColor)
                }
            }
            .background(Color.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        analytics.track(event: .backButtonTapped, parameters: [
                            "chapter_id": currentChapter.id.uuidString,
                            "reading_time_seconds": 0 // TODO: Track actual reading time
                        ])
                        audioManager.stop()
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.serifBody())
                        .foregroundColor(.accentColor)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Voice selector button
                        Button {
                            analytics.track(event: .voiceSelectorOpened, parameters: [
                                "current_voice": audioManager.selectedMinimaxVoice.displayName
                            ])
                            showVoiceSelector = true
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.accentColor)
                                .font(.system(size: 20))
                        }

                        // Favorite button
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
            .sheet(isPresented: $showVoiceSelector) {
                VoiceSelectorView()
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
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
    }

    private func navigateToNextChapter(_ next: Chapter) {
        // Stop current audio
        audioManager.stop()

        // Update to next chapter
        currentChapter = next
        hasMarkedAsRead = false

        // Mark new chapter as read
        markAsRead()
    }

    private func navigateToPreviousChapter(_ previous: Chapter) {
        // Stop current audio
        audioManager.stop()

        // Update to previous chapter
        currentChapter = previous
        hasMarkedAsRead = false

        // Mark new chapter as read
        markAsRead()
    }

    private func markAsRead() {
        if !hasMarkedAsRead {
            profileManager.markChapterAsRead(currentChapter.id, duration: currentChapter.duration)
            hasMarkedAsRead = true
        }
    }
}

struct AudioPlayerControls: View {
    let isPlaying: Bool
    let progress: Double
    let onPlayPause: () -> Void
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            ProgressView(value: progress)
                .tint(.accentColor)

            HStack(spacing: 0) {
                Button(action: onStop) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.appText.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }

                Button(action: onPlayPause) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 50, height: 50)

                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                }

                Text("\(Int(progress * 100))%")
                    .font(.serifBody())
                    .foregroundColor(.appText.opacity(0.7))
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
