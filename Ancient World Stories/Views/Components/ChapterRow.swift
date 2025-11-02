//  ChapterRow.swift
import SwiftUI

struct ChapterRow: View {
    let chapter: Chapter
    @ObservedObject private var profileManager = ProfileManager.shared
    
    var isRead: Bool {
        profileManager.isChapterRead(chapter.id)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(isRead ? Color.accentColor : Color.appSecondary)
                    .frame(width: 40, height: 40)
                
                if isRead {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(chapter.orderNo)")
                        .font(.serifBody())
                        .foregroundColor(.primaryText)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(chapter.title)
                    .font(.serifHeadline())
                    .foregroundColor(.primaryText)
                
                Text(chapter.excerpt)
                    .font(.serifBody())
                    .foregroundColor(.secondaryText)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(chapter.formattedDuration)
                }
                .font(.serifCaption2())
                .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(.accentColor)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
