// HomeView.swift
import SwiftUI

struct HomeView: View {
    @ObservedObject private var content = ContentLoader.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var selectedChapter: Chapter?
    @State private var randomChapters: [Chapter] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localized: "app.title")
                                .font(.serifTitle())
                                .foregroundColor(.primaryText)

                            Text(localized: "app.tagline")
                                .font(.serifBody())
                                .foregroundColor(.secondaryText)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        if content.isLoading {
                            VStack(spacing: 16) {
                                ProgressView().tint(.accentColor)
                                Text(localized: "home.loading_stories")
                                    .font(.serifBody())
                                    .foregroundColor(.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else if let error = content.error {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.accentColor)
                                Text(error)
                                    .font(.serifBody())
                                    .foregroundColor(.secondaryText)
                                    .multilineTextAlignment(.center)
                                Button("retry".localized) {
                                    Task {
                                        await content.loadInitialData()
                                        loadRandomChapters()
                                    }
                                }
                                .font(.serifBody())
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.accentColor)
                                .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(localized: "home.explore_chapters")
                                    .font(.serifTitle2())
                                    .foregroundColor(.primaryText)
                                    .padding(.horizontal)
                                
                                ForEach(randomChapters) { chapter in
                                    if let story = content.story(for: chapter),
                                       let civ = content.civilization(for: story) {
                                        Button {
                                            selectedChapter = chapter
                                        } label: {
                                            VStack(alignment: .leading, spacing: 12) {
                                                Text(civ.name)
                                                    .font(.serifCaption())
                                                    .foregroundColor(.accentColor)
                                                
                                                Text(story.title)
                                                    .font(.serifHeadline())
                                                    .foregroundColor(.primaryText)
                                                
                                                Text(chapter.excerpt)
                                                    .font(.serifBody())
                                                    .foregroundColor(.secondaryText)
                                                    .lineLimit(3)
                                                
                                                HStack {
                                                    Image(systemName: "clock")
                                                        .font(.system(size: 12))
                                                    Text(chapter.formattedDuration)
                                                    Text("• Chapter \(chapter.orderNo)")
                                                }
                                                .font(.serifCaption2())
                                                .foregroundColor(.secondaryText)
                                            }
                                            .padding(16)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.cardBackground)
                                            .cornerRadius(12)
                                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            Button {
                                withAnimation {
                                    loadRandomChapters()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("home.show_different".localized)
                                }
                                .font(.serifBody())
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.cardBackground)
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .refreshable {
                    await content.loadInitialData()
                    loadRandomChapters()
                }
            }
            .fullScreenCover(item: $selectedChapter) { chapter in
                if let story = content.story(for: chapter),
                   let civ = content.civilization(for: story) {
                    ChapterReaderView(
                        chapter: chapter,
                        story: story,
                        civilization: civ,
                        allChapters: content.chapters(for: story.id)
                    )
                }
            }
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(Color.cardBackground, for: .tabBar)
        .onAppear {
            loadRandomChapters()
        }
        .onChange(of: content.chapters) {
            // Auto-load random chapters when content finishes loading
            if !content.chapters.isEmpty && randomChapters.isEmpty {
                loadRandomChapters()
            }
        }
        .onChange(of: languageManager.selectedLanguage) {
            // Reload random chapters when language changes
            loadRandomChapters()
        }
    }

    private func loadRandomChapters() {
        randomChapters = content.randomChapters(count: 10)
    }
}
