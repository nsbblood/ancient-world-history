//
//  ReadingPathView.swift
//  Ancient World Stories
//

import SwiftUI

struct ReadingPathView: View {
    @ObservedObject private var content = ContentLoader.shared
    @ObservedObject private var profileManager = ProfileManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedChapter: Chapter?
    @State private var showPaywall = false
    
    var pathNodes: [Chapter] {
        // Simple linear path using the first chapters of the first 10 stories
        let firstChapters = content.chapters.filter { $0.orderNo == 1 }
        return Array(firstChapters.prefix(10))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.appAccent)
                            
                            Text("reading_path.title".localized)
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(.primaryText)
                            
                            Text("reading_path.subtitle".localized)
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 32)
                        
                        // Path Nodes
                        ForEach(Array(pathNodes.enumerated()), id: \.element.id) { index, chapter in
                            let isCompleted = profileManager.isChapterRead(chapter.id)
                            let isPreviousCompleted = index == 0 || profileManager.isChapterRead(pathNodes[index - 1].id)
                            let isUnlocked = isCompleted || isPreviousCompleted
                            
                            HStack {
                                if index % 2 == 1 { Spacer() }
                                
                                PathNodeView(
                                    chapter: chapter,
                                    index: index,
                                    isCompleted: isCompleted,
                                    isUnlocked: isUnlocked
                                )
                                .onTapGesture {
                                    if isUnlocked {
                                        if !profileManager.isPremium && index > 2 {
                                            showPaywall = true
                                        } else {
                                            selectedChapter = chapter
                                        }
                                    }
                                }
                                
                                if index % 2 == 0 { Spacer() }
                            }
                            .padding(.horizontal, 40)
                            
                            // Connecting line
                            if index < pathNodes.count - 1 {
                                PathConnectingLine(
                                    isRightToLeft: index % 2 == 0,
                                    isUnlocked: isCompleted
                                )
                            }
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appAccent)
                            .font(.system(size: 24))
                    }
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
        }
    }
}

struct PathNodeView: View {
    let chapter: Chapter
    let index: Int
    let isCompleted: Bool
    let isUnlocked: Bool
    
    @ObservedObject private var content = ContentLoader.shared
    
    var body: some View {
        let story = content.story(for: chapter)
        let civ = story.flatMap { content.civilization(for: $0) }
        
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.appAccent : (isUnlocked ? Color.appAccent.opacity(0.3) : Color.gray.opacity(0.3)))
                    .frame(width: 80, height: 80)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                } else if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.appAccent)
                }
            }
            .shadow(color: isUnlocked ? Color.appAccent.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
            
            VStack(spacing: 4) {
                Text(civ?.name ?? "")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isUnlocked ? .appAccent : .gray)
                    .textCase(.uppercase)
                
                Text(story?.title ?? "")
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(isUnlocked ? .primaryText : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 120)
        }
    }
}

struct PathConnectingLine: View {
    let isRightToLeft: Bool
    let isUnlocked: Bool
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: isRightToLeft ? 60 : 200, y: 0))
            path.addCurve(
                to: CGPoint(x: isRightToLeft ? 200 : 60, y: 60),
                control1: CGPoint(x: isRightToLeft ? 60 : 200, y: 30),
                control2: CGPoint(x: isRightToLeft ? 200 : 60, y: 30)
            )
        }
        .stroke(
            isUnlocked ? Color.appAccent : Color.gray.opacity(0.3),
            style: StrokeStyle(lineWidth: 4, dash: isUnlocked ? [] : [8, 8])
        )
        .frame(height: 60)
    }
}
