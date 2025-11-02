// ChapterReaderView.swift
import SwiftUI
import AVFoundation

struct ChapterReaderView: View {
    let chapter: Chapter
    let story: Story
    let civilization: Civilization
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var profileManager = ProfileManager.shared
    @State private var hasMarkedAsRead = false
    
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
                    .background(Color.cardBackground.opacity(0.95))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        audioManager.stop()
                        dismiss()
                    }
                    .font(.serifBody())
                    .foregroundColor(.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: markAsRead) {
                        Image(systemName: profileManager.isChapterRead(chapter.id) ? "checkmark.circle.fill" : "checkmark.circle")
                            .foregroundColor(.accentColor)
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
