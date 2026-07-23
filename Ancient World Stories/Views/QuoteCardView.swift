//
//  QuoteCardView.swift
//  Ancient World Stories
//

import SwiftUI

struct QuoteCardView: View {
    let chapter: Chapter
    let civilization: Civilization
    
    // Fallback to extract a good quote, typically the middle or the end, but excerpt is fine for now
    var quoteText: String {
        // Find a complete sentence if possible from the excerpt, or just use excerpt
        let text = chapter.text
        let sentences = text.components(separatedBy: ". ")
        if sentences.count > 1 {
            // pick the second sentence as it might be more interesting than the first
            return sentences[1] + "."
        }
        return chapter.excerpt
    }
    
    var body: some View {
        ZStack {
            // Rich dark background
            LinearGradient(
                colors: [Color(hex: "2b2118"), Color(hex: "0f0c09")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle texture/pattern using stacked shapes or gradients
            RadialGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.15), .clear]),
                center: .center,
                startRadius: 50,
                endRadius: 250
            )
            
            VStack(spacing: 24) {
                // Top App Name
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.orange)
                    Text("Ancient World Stories")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1.5)
                        .textCase(.uppercase)
                }
                .padding(.top, 32)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.orange.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(quoteText)
                        .font(.system(size: 26, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .lineLimit(4)
                        .minimumScaleFactor(0.7)
                        
                    Image(systemName: "quote.closing")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.orange.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    Text(civilization.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.orange)
                        .textCase(.uppercase)
                        .tracking(2)
                    
                    Text(chapter.title)
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 32)
            }
            
            // Border
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.orange.opacity(0.5), .clear, .orange.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .padding(12)
        }
        .frame(width: 400, height: 400)
        .background(Color(hex: "0f0c09")) // Ensure solid background when rendering
        .ignoresSafeArea()
    }
}
