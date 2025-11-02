// ProfileView.swift
import SwiftUI
import PhotosUI

struct ProfileView: View {
    @ObservedObject private var profileManager = ProfileManager.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @StateObject private var content = ContentLoader.shared
    @State private var selectedChapter: Chapter?
    @State private var showPaywall = false
    @State private var showSettings = false
    @State private var showImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var favoriteChapters: [Chapter] {
        favoritesManager.getFavoriteChapters()
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Fixed Header
                HStack {
                    Text("Profile")
                        .font(.serifLargeTitle())
                        .foregroundColor(.primaryText)

                    Spacer()

                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color.backgroundColor)

                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(spacing: 16) {
                            Button {
                                showImagePicker = true
                            } label: {
                                ZStack {
                                    if let profileImage = profileManager.profileImage {
                                        Image(uiImage: profileImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.accentColor, lineWidth: 2)
                                            )
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 80))
                                            .foregroundColor(.accentColor)
                                    }

                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Image(systemName: "camera.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.white)
                                                .background(
                                                    Circle()
                                                        .fill(Color.accentColor)
                                                        .frame(width: 28, height: 28)
                                                )
                                        }
                                    }
                                    .frame(width: 80, height: 80)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())

                            if !profileManager.isPremium {
                                Button {
                                    showPaywall = true
                                } label: {
                                    HStack {
                                        Image(systemName: "crown.fill")
                                        Text("Go Premium")
                                    }
                                    .font(.serifHeadline())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                            } else {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.accentColor)
                                    Text("Premium Member")
                                        .font(.serifHeadline())
                                        .foregroundColor(.accentColor)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Statistics")
                                .font(.serifTitle3())
                                .foregroundColor(.primaryText)
                            
                            VStack(spacing: 12) {
                                StatisticRow(
                                    icon: "book.fill",
                                    title: "Chapters Read",
                                    value: "\(profileManager.totalChaptersRead())"
                                )
                                
                                StatisticRow(
                                    icon: "globe",
                                    title: "Civilizations Explored",
                                    value: "\(profileManager.civilizationsExplored())"
                                )
                                
                                StatisticRow(
                                    icon: "clock.fill",
                                    title: "Total Reading Time",
                                    value: profileManager.formattedTotalReadingTime()
                                )
                                
                                StatisticRow(
                                    icon: "heart.fill",
                                    title: "Favorite Chapters",
                                    value: "\(favoritesManager.favoriteCount())"
                                )
                            }
                        }
                        .padding(.horizontal)

                        if !favoriteChapters.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Favorite Chapters")
                                    .font(.serifTitle3())
                                    .foregroundColor(.primaryText)

                                ForEach(favoriteChapters) { chapter in
                                    if let story = content.story(for: chapter.storyId),
                                       let civilization = content.civilization(for: story) {
                                        Button {
                                            selectedChapter = chapter
                                        } label: {
                                            FavoriteChapterRow(
                                                chapter: chapter,
                                                story: story,
                                                civilization: civilization
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(
                onComplete: {
                    showPaywall = false
                },
                onDismiss: {
                    showPaywall = false
                }
            )
        }
        .fullScreenCover(item: $selectedChapter) { chapter in
            if let story = content.story(for: chapter.storyId),
               let civilization = content.civilization(for: story) {
                ChapterReaderView(
                    chapter: chapter,
                    story: story,
                    civilization: civilization,
                    allChapters: content.chapters(for: story.id)
                )
            }
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(Color.cardBackground, for: .tabBar)
        .photosPicker(isPresented: $showImagePicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                if let newValue,
                   let data = try? await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    profileManager.saveProfileImage(image)
                }
            }
        }
    }
}

struct FavoriteChapterRow: View {
    let chapter: Chapter
    let story: Story
    let civilization: Civilization

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(civilization.name)
                    .font(.serifCaption())
                    .foregroundColor(.accentColor)

                Text(story.title)
                    .font(.serifBody())
                    .foregroundColor(.secondaryText)

                Text(chapter.title)
                    .font(.serifHeadline())
                    .foregroundColor(.primaryText)

                HStack(spacing: 8) {
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

            Spacer()

            Image(systemName: "heart.fill")
                .foregroundColor(.accentColor)
                .font(.system(size: 20))
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct StatisticRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            Text(title)
                .font(.serifBody())
                .foregroundColor(.primaryText)
            
            Spacer()
            
            Text(value)
                .font(.serifHeadline())
                .foregroundColor(.accentColor)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct VoiceSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileManager = ProfileManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor.ignoresSafeArea()
                
                List {
                    ForEach(VoiceType.allCases, id: \.self) { voice in
                        Button {
                            profileManager.currentVoice = voice
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(voice.displayName)
                                        .font(.serifBody())
                                        .foregroundColor(.primaryText)
                                    
                                    Text(voice.language)
                                        .font(.serifCaption())
                                        .foregroundColor(.secondaryText)
                                }
                                
                                Spacer()
                                
                                if profileManager.currentVoice == voice {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Select Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondaryText)
                    }
                }
            }
        }
    }
}
