// ChapterReaderView.swift
import SwiftUI
import AVFoundation

struct ChapterReaderView: View {
    let chapter: Chapter
    let story: Story
    let civilization: Civilization
    let allChapters: [Chapter]

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var profileManager = ProfileManager.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @State private var hasMarkedAsRead = false

    var currentIndex: Int? {
        allChapters.firstIndex(where: { $0.id == chapter.id })
    }

    var nextChapter: Chapter? {
        guard let index = currentIndex, index + 1 < allChapters.count else { return nil }
        return allChapters[index + 1]
    }

    var isFavorite: Bool {
        favoritesManager.isFavorite(chapterId: chapter.id)
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
                            
                            Text(chapter.title)
                                .font(.serifTitle2())
                                .foregroundColor(.primaryText)
                            
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                    Text(chapter.formattedDuration)
                                }
                                Text("•")
                                Text("Chapter \(chapter.orderNo)")
                            }
                            .font(.serifCaption())
                            .foregroundColor(.secondaryText)
                        }
                        
                        Divider().background(Color.appSecondary)
                        
                        Text(chapter.text)
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
                                    audioManager.speak(text: chapter.text, language: chapter.languageCode)
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

                            NavigationLink {
                                ChapterReaderView(
                                    chapter: next,
                                    story: story,
                                    civilization: civilization,
                                    allChapters: allChapters
                                )
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
                        favoritesManager.toggleFavorite(chapterId: chapter.id)
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
    
    private func markAsRead() {
        if !hasMarkedAsRead {
            profileManager.markChapterAsRead(chapter.id, duration: chapter.duration)
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
