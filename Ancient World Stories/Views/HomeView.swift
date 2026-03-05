// HomeView.swift
import SwiftUI

struct HomeView: View {
    @ObservedObject private var content = ContentLoader.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var profileManager = ProfileManager.shared
    @State private var selectedChapter: Chapter?
    @State private var randomChapters: [Chapter] = []
    @State private var dailyChapter: Chapter?

    @State private var showPaywall = false
    @State private var showReadingPath = false

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
                                        content.loadInitialData()
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
                            if let daily = dailyChapter,
                               let story = content.story(for: daily),
                               let civ = content.civilization(for: story) {
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("home.daily_story".localized)
                                            .font(.serifTitle2())
                                            .foregroundColor(.primaryText)
                                        Spacer()
                                        if profileManager.currentStreak > 0 {
                                            HStack(spacing: 4) {
                                                Text("🔥 \(profileManager.currentStreak)")
                                                    .font(.headline)
                                                    .foregroundColor(.orange)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.orange.opacity(0.15))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    Button {
                                        selectedChapter = daily
                                    } label: {
                                        VStack(alignment: .leading, spacing: 16) {
                                            HStack {
                                                Text(civ.name)
                                                    .font(.serifCaption())
                                                    .foregroundColor(.white.opacity(0.8))
                                                Spacer()
                                                HStack(spacing: 4) {
                                                    Image(systemName: "gift.fill")
                                                    Text("Free Today")
                                                }
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.white.opacity(0.2))
                                                .cornerRadius(6)
                                            }
                                            
                                            Text(story.title)
                                                .font(.serifTitle())
                                                .foregroundColor(.white)
                                                
                                            Text(daily.excerpt)
                                                .font(.serifBody())
                                                .foregroundColor(.white.opacity(0.9))
                                                .lineLimit(3)
                                                
                                            HStack {
                                                Image(systemName: "clock")
                                                    .font(.system(size: 12))
                                                Text(daily.formattedDuration)
                                                Text("• Chapter \(daily.orderNo)")
                                            }
                                            .font(.serifCaption2())
                                            .foregroundColor(.white.opacity(0.8))
                                        }
                                        .padding(20)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(16)
                                        .shadow(color: .accentColor.opacity(0.4), radius: 10, x: 0, y: 5)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal)
                                }
                                .padding(.bottom, 16)
                            }

                            if !content.collections.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Collections") // Hardcoded fallback if missing localization
                                        .font(.serifTitle2())
                                        .foregroundColor(.primaryText)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(content.collections) { collection in
                                                NavigationLink(destination: CollectionDetailView(collection: collection)) {
                                                    VStack(alignment: .leading, spacing: 12) {
                                                        ZStack {
                                                            Circle()
                                                                .fill(Color(hex: collection.colorHex).opacity(0.2))
                                                                .frame(width: 50, height: 50)
                                                            
                                                            Image(systemName: collection.iconName)
                                                                .font(.system(size: 24))
                                                                .foregroundColor(Color(hex: collection.colorHex))
                                                        }
                                                        
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(collection.title)
                                                                .font(.serifHeadline())
                                                                .foregroundColor(.primaryText)
                                                                .lineLimit(1)
                                                            
                                                            Text(collection.subtitle)
                                                                .font(.serifCaption())
                                                                .foregroundColor(.secondaryText)
                                                                .lineLimit(2)
                                                        }
                                                    }
                                                    .padding(16)
                                                    .frame(width: 160, alignment: .leading)
                                                    .background(Color.cardBackground)
                                                    .cornerRadius(16)
                                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.bottom, 16)
                            }

                            // Personal Reading Path Entry
                            Button {
                                showReadingPath = true
                            } label: {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Kişisel Okuma Yolu")
                                            .font(.serifHeadline())
                                        Text("Tarihsel serüvenine devam et")
                                            .font(.serifCaption())
                                    }
                                    .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "map.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(20)
                                .background(
                                    LinearGradient(
                                        colors: [Color.appAccent, Color(hex: "8B6914")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .appAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .padding(.bottom, 16)

                            VStack(alignment: .leading, spacing: 16) {
                                Text(localized: "home.explore_chapters")
                                    .font(.serifTitle2())
                                    .foregroundColor(.primaryText)
                                    .padding(.horizontal)
                                
                                ForEach(randomChapters) { chapter in
                                    if let story = content.story(for: chapter),
                                       let civ = content.civilization(for: story) {
                                        Button {
                                            // First chapter is always free, rest require premium
                                            if chapter.orderNo == 1 || profileManager.isPremium {
                                                selectedChapter = chapter
                                            } else {
                                                // Show paywall for non-premium users on chapters 2+
                                                showPaywall = true
                                            }
                                        } label: {
                                            let isLocked = chapter.orderNo > 1 && !profileManager.isPremium

                                            VStack(alignment: .leading, spacing: 12) {
                                                HStack {
                                                    Text(civ.name)
                                                        .font(.serifCaption())
                                                        .foregroundColor(.accentColor)

                                                    Spacer()

                                                    if isLocked {
                                                        HStack(spacing: 4) {
                                                            Image(systemName: "crown.fill")
                                                                .font(.system(size: 12))
                                                            Text("Premium")
                                                                .font(.serifCaption2())
                                                        }
                                                        .foregroundColor(.appAccent)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(Color.appAccent.opacity(0.1))
                                                        .cornerRadius(6)
                                                    }
                                                }

                                                Text(story.title)
                                                    .font(.serifHeadline())
                                                    .foregroundColor(isLocked ? .primaryText.opacity(0.6) : .primaryText)

                                                Text(chapter.excerpt)
                                                    .font(.serifBody())
                                                    .foregroundColor(isLocked ? .secondaryText.opacity(0.6) : .secondaryText)
                                                    .lineLimit(3)

                                                HStack {
                                                    Image(systemName: "clock")
                                                        .font(.system(size: 12))
                                                    Text(chapter.formattedDuration)
                                                    Text("• Chapter \(chapter.orderNo)")

                                                    if isLocked {
                                                        Spacer()
                                                        Image(systemName: "lock.fill")
                                                            .font(.system(size: 14))
                                                            .foregroundColor(.appAccent)
                                                    }
                                                }
                                                .font(.serifCaption2())
                                                .foregroundColor(isLocked ? .secondaryText.opacity(0.6) : .secondaryText)
                                            }
                                            .padding(16)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.cardBackground)
                                            .cornerRadius(12)
                                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                            .opacity(isLocked ? 0.8 : 1.0)
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
                    content.loadInitialData()
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
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
            }
            .fullScreenCover(isPresented: $showReadingPath) {
                ReadingPathView()
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
        dailyChapter = content.getDailyChapter()
    }
}
