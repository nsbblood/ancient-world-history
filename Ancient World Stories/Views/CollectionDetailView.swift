//
//  CollectionDetailView.swift
//  Ancient World Stories
//

import SwiftUI

struct CollectionDetailView: View {
    let collection: StoryCollection
    @ObservedObject private var content = ContentLoader.shared
    @Environment(\.dismiss) private var dismiss
    
    var collectionStories: [Story] {
        collection.storyIds.compactMap { content.story(for: $0) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: collection.colorHex).opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: collection.iconName)
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: collection.colorHex))
                    }
                    .padding(.top, 20)
                    
                    Text(collection.title)
                        .font(.serifTitle())
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text(collection.subtitle)
                        .font(.serifBody())
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
                
                // Stories List
                VStack(spacing: 16) {
                    ForEach(collectionStories) { story in
                        if let civ = content.civilization(for: story) {
                            NavigationLink(destination: ChaptersView(story: story, civilization: civ)) {
                                StoryCard(story: story, civilization: civ)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}
