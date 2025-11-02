// ChapterReaderView.swift
import SwiftUI
import AVFoundation

struct ChapterReaderView: View {
    let initialChapter: Chapter
    let story: Story
    let civilization: Civilization
    let allChapters: [Chapter]

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var profileManager = ProfileManager.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared

    @State private var currentChapter: Chapter
    @State private var hasMarkedAsRead = false

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

    var isFavorite: Bool {
        favoritesManager.isFavorite(chapterId: currentChapter.id)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(civilization.name)
                                .font(.serifCaption())
                                .foregroundColor(.accentColor)

                            Text(story.title)
                                .font(.serifBody())
                                .foregroundColor(.secondaryText)

                            Text(currentChapter.title)
                                .font(.serifTitle2())
                                .foregroundColor(.primaryText)

                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                    Text(currentChapter.formattedDuration)
                                }
                                Text("•")
                                Text("Chapter \(currentChapter.orderNo)")
                            }
                            .font(.serifCaption())
                            .foregroundColor(.secondaryText)
                        }

                        Divider().background(Color.appSecondary)

                        Text(currentChapter.text)
                            .readingTextStyle()
                            .textSelection(.enabled)
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
                
                VStack {
                    Spacer()

                    VStack(spacing: 0) {
                        AudioPlayerControls(
                            isPlaying: audioManager.isPlaying,
                            progress: audioManager.currentProgress,
                            onPlayPause: {
                                if audioManager.isPlaying {
                                    audioManager.pause()
                                } else if audioManager.synthesizer.isPaused {
                                    audioManager.resume()
                                } else {
                                    audioManager.speak(text: currentChapter.text, language: currentChapter.languageCode)
                                    markAsRead()
                                }
                            },
                            onStop: {
                                audioManager.stop()
                            }
                        )
                        .padding()

                        if let next = nextChapter {
                            Divider()
                                .background(Color.appSecondary.opacity(0.3))

                            Button {
                                navigateToNextChapter(next)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Next Chapter")
                                            .font(.serifCaption())
                                            .foregroundColor(.secondaryText)

                                        Text(next.title)
                                            .font(.serifBody())
                                            .foregroundColor(.primaryText)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.accentColor)
                                }
                                .padding()
                            }
                        }
                    }
                    .background(Color.cardBackground.opacity(0.95))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
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
                    Button {
                        favoritesManager.toggleFavorite(chapterId: currentChapter.id)
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 20))
                    }
                }
            }
        }
        .onAppear {
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
        withAnimation {
            currentChapter = next
            hasMarkedAsRead = false
        }

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
        VStack(spacing: 12) {
            ProgressView(value: progress)
                .tint(.accentColor)
            
            HStack(spacing: 32) {
                Button(action: onStop) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondaryText)
                }
                
                Button(action: onPlayPause) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                
                Text("\(Int(progress * 100))%")
                    .font(.serifBody())
                    .foregroundColor(.secondaryText)
                    .frame(width: 60)
            }
        }
    }
}
