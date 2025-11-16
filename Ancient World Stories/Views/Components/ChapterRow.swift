//  ChapterRow.swift
import SwiftUI

struct ChapterRow: View {
    let chapter: Chapter
    var isLocked: Bool = false
    @ObservedObject private var profileManager = ProfileManager.shared

    var isRead: Bool {
        profileManager.isChapterRead(chapter.id)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(isLocked ? Color.appSecondary.opacity(0.5) : (isRead ? Color.accentColor : Color.appSecondary))
                    .frame(width: 40, height: 40)

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primaryText.opacity(0.5))
                } else if isRead {
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
                HStack(spacing: 8) {
                    Text(chapter.title)
                        .font(.serifHeadline())
                        .foregroundColor(isLocked ? .primaryText.opacity(0.5) : .primaryText)

                    if isLocked {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.appAccent)
                    }
                }

                Text(chapter.excerpt)
                    .font(.serifBody())
                    .foregroundColor(isLocked ? .secondaryText.opacity(0.5) : .secondaryText)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(chapter.formattedDuration)
                }
                .font(.serifCaption2())
                .foregroundColor(isLocked ? .secondaryText.opacity(0.5) : .secondaryText)
            }

            Spacer()

            Image(systemName: isLocked ? "lock.fill" : "play.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(isLocked ? .appAccent : .accentColor)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .opacity(isLocked ? 0.7 : 1.0)
    }
}
