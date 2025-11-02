// ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @ObservedObject private var profileManager = ProfileManager.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @StateObject private var content = ContentLoader.shared
    @State private var selectedStory: Story?
    @State private var showVoiceSelector = false
    
    var favoriteStories: [Story] {
        favoritesManager.getFavoriteStories()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.accentColor)
                            
                            if !profileManager.isPremium {
                                Button {
                                    // TODO: RevenueCat integration
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
                                    title: "Favorite Stories",
                                    value: "\(favoritesManager.favoriteCount())"
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Voice Settings")
                                .font(.serifTitle3())
                                .foregroundColor(.primaryText)
                            
                            Button {
                                showVoiceSelector = true
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Selected Voice")
                                            .font(.serifCaption())
                                            .foregroundColor(.secondaryText)
                                        
                                        Text(profileManager.currentVoice.displayName)
                                            .font(.serifBody())
                                            .foregroundColor(.primaryText)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.accentColor)
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        if !favoriteStories.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Favorite Stories")
                                    .font(.serifTitle3())
                                    .foregroundColor(.primaryText)
                                
                                ForEach(favoriteStories) { story in
                                    Button {
                                        selectedStory = story
                                    } label: {
                                        StoryCard(story: story, civilization: content.civilization(for: story))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showVoiceSelector) {
                VoiceSelectorView()
            }
            .navigationDestination(item: $selectedStory) { story in
                if let civ = content.civilization(for: story) {
                    ChaptersView(story: story, civilization: civ)
                }
            }
        }
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
                    Button("Done") {
                        dismiss()
                    }
                    .font(.serifBody())
                    .foregroundColor(.accentColor)
                }
            }
        }
    }
}
