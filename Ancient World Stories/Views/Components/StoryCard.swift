//  StoryCard.swift
import SwiftUI

struct StoryCard: View {
    let story: Story
    let civilization: Civilization?
    @ObservedObject private var profileManager = ProfileManager.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if let civ = civilization {
                        Text(civ.name)
                            .font(.serifCaption())
                            .foregroundColor(.accentColor)
                    }
                    
                    Text(story.title)
                        .font(.serifHeadline())
                        .foregroundColor(.primaryText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: {
                    favoritesManager.toggleFavorite(storyId: story.id)
                }) {
                    Image(systemName: favoritesManager.isFavorite(storyId: story.id) ? "heart.fill" : "heart")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 20))
                }
            }
            
            Text(story.summary)
                .font(.serifBody())
                .foregroundColor(.primaryText)
                .lineLimit(3)
            
            HStack {
                Image(systemName: "book.closed")
                    .font(.system(size: 12))
                Text("\(story.chaptersCount) chapters")
                    .font(.serifCaption2())
            }
            .foregroundColor(.secondaryText)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
