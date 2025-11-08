// StoriesView.swift
import SwiftUI

struct StoriesView: View {
    let civilization: Civilization
    @ObservedObject private var content = ContentLoader.shared
    @State private var selectedStory: Story?

    var stories: [Story] {
        content.stories(for: civilization.id)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(civilization.name)
                            .font(.serifTitle2())
                            .foregroundColor(.primaryText)
                        
                        Text(civilization.eraDisplay)
                            .font(.serifBody())
                            .foregroundColor(.accentColor)
                        
                        Text(civilization.description)
                            .font(.serifBody())
                            .foregroundColor(.secondaryText)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    if content.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.accentColor)
                            Text("Loading stories...")
                                .font(.serifBody())
                                .foregroundColor(.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else if stories.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 60))
                                .foregroundColor(.accentColor.opacity(0.5))
                            
                            Text("Stories Coming Soon")
                                .font(.serifTitle3())
                                .foregroundColor(.primaryText)
                            
                            Text("New tales from \(civilization.name) will be added here soon. Check back later!")
                                .font(.serifBody())
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ForEach(stories) { story in
                            Button {
                                selectedStory = story
                            } label: {
                                StoryCard(story: story, civilization: civilization)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedStory) { story in
            ChaptersView(story: story, civilization: civilization)
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
    }
}
