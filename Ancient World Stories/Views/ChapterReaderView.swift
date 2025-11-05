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

    @State private var currentChapter: Chapter
    @State private var hasMarkedAsRead = false
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var screenWidth: CGFloat = 0

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
            ZStack {
                Color.backgroundColor.ignoresSafeArea()

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

                        if previousChapter != nil || nextChapter != nil {
                            Divider()
                                .background(Color.appSecondary.opacity(0.3))

                            HStack(spacing: 0) {
                                if let previous = previousChapter {
                                    Button {
                                        navigateToPreviousChapter(previous)
                                    } label: {
                                        HStack {
                                            Image(systemName: "chevron.left")
                                                .foregroundColor(.accentColor)

                                            VStack(alignment: .leading, spacing: 4) {
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
                                        .padding()
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
                                        navigateToNextChapter(next)
                                    } label: {
                                        HStack {
                                            Spacer()

                                            VStack(alignment: .trailing, spacing: 4) {
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
                                        .padding()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .background(Color.cardBackground.opacity(0.95))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
                .allowsHitTesting(true)
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
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    screenWidth = geometry.size.width
                }
            }
        )
        .offset(x: dragOffset)
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    // Only allow swipe from left edge
                    if value.startLocation.x < 30 && value.translation.width > 0 {
                        isDragging = true
                        dragOffset = min(value.translation.width, screenWidth)
                    }
                }
                .onEnded { value in
                    if isDragging {
                        if dragOffset > 100 {
                            audioManager.stop()
                            dismiss()
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                        isDragging = false
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = 0
                        }
                    }
                }
        )
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

    private func navigateToPreviousChapter(_ previous: Chapter) {
        // Stop current audio
        audioManager.stop()

        // Update to previous chapter
        withAnimation {
            currentChapter = previous
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

            HStack(spacing: 0) {
                Button(action: onStop) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.appText.opacity(0.6))
                        .frame(maxWidth: .infinity)
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
