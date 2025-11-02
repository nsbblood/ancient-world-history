// StoriesView.swift
import SwiftUI

struct StoriesView: View {
    let civilization: Civilization
    @StateObject private var content = ContentLoader.shared
    @State private var selectedStory: Story?
    
    var stories: [Story] {
        content.stories(for: civilization.id)
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            
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
                    
                    if stories.isEmpty {
                        Text("No stories available yet.")
                            .font(.serifBody())
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
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
    }
}
