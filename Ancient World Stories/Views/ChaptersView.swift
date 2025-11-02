// ChaptersView.swift - THE EPISODES PAGE
import SwiftUI

struct ChaptersView: View {
    let story: Story
    let civilization: Civilization
    
    @StateObject private var content = ContentLoader.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @ObservedObject private var profileManager = ProfileManager.shared
    @State private var selectedChapter: Chapter?
    
    var chapters: [Chapter] {
        content.chapters(for: story.id)
    }
    
    var readProgress: Double {
        profileManager.readProgress(for: story.id)
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(civilization.name)
                                    .font(.serifBody())
                                    .foregroundColor(.accentColor)
                                
                                Text(story.title)
                                    .font(.serifTitle2())
                                    .foregroundColor(.primaryText)
                            }
                            
                            Spacer()
                            
                            // Removed story favorite button - favorites are now chapter-based
                        }
                        
                        Text(story.summary)
                            .font(.serifBody())
                            .foregroundColor(.primaryText)
                        
                        if readProgress > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Progress")
                                        .font(.serifCaption())
                                        .foregroundColor(.secondaryText)
                                    Spacer()
                                    Text("\(Int(readProgress * 100))%")
                                        .font(.serifCaption())
                                        .foregroundColor(.accentColor)
                                }
                                ProgressView(value: readProgress)
                                    .tint(.accentColor)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Chapters (\(chapters.count))")
                            .font(.serifTitle3())
                            .foregroundColor(.primaryText)
                        
                        if chapters.isEmpty {
                            Text("No chapters available yet.")
                                .font(.serifBody())
                                .foregroundColor(.secondaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                        } else {
                            ForEach(chapters) { chapter in
                                Button {
                                    selectedChapter = chapter
                                } label: {
                                    ChapterRow(chapter: chapter)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedChapter) { chapter in
            ChapterReaderView(
                chapter: chapter,
                story: story,
                civilization: civilization,
                allChapters: chapters
            )
        }
    }
}
