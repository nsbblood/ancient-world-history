//  CivilizationCard.swift
import SwiftUI

struct CivilizationCard: View {
    let civilization: Civilization
    let storyCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(civilization.name)
                        .font(.serifTitle3())
                        .foregroundColor(.primaryText)
                    
                    Text(civilization.eraDisplay)
                        .font(.serifCaption())
                        .foregroundColor(.accentColor)
                    
                    Text(civilization.region)
                        .font(.serifCaption2())
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(storyCount)")
                        .font(.serifTitle2())
                        .foregroundColor(.accentColor)
                    Text("stories")
                        .font(.serifCaption2())
                        .foregroundColor(.secondaryText)
                }
            }
            
            Text(civilization.description)
                .font(.serifBody())
                .foregroundColor(.primaryText)
                .lineLimit(3)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
