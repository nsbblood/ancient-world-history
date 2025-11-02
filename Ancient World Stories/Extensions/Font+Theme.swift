//
//  Font+Theme.swift
//  Ancient World Stories
//
//  Created by Claude Code
//

import SwiftUI

extension Font {
    // MARK: - Serif Fonts (Playfair Display / Cinzel)
    // Note: These require custom fonts to be added to the project
    // For now, using system serif fonts as fallback

    static func serifLargeTitle() -> Font {
        .system(size: 40, weight: .bold, design: .serif)
    }

    static func serifTitle() -> Font {
        .system(size: 34, weight: .bold, design: .serif)
    }

    static func serifTitle2() -> Font {
        .system(size: 28, weight: .semibold, design: .serif)
    }

    static func serifTitle3() -> Font {
        .system(size: 22, weight: .semibold, design: .serif)
    }

    static func serifHeadline() -> Font {
        .system(size: 18, weight: .semibold, design: .serif)
    }

    static func serifBody() -> Font {
        .system(size: 17, weight: .regular, design: .serif)
    }

    static func serifBodyLarge() -> Font {
        .system(size: 19, weight: .regular, design: .serif)
    }

    static func serifCaption() -> Font {
        .system(size: 14, weight: .regular, design: .serif)
    }

    static func serifCaption2() -> Font {
        .system(size: 12, weight: .regular, design: .serif)
    }

    // MARK: - Reading Font
    static func readingFont(size: CGFloat = 19) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    // MARK: - Custom Fonts (when added)
    /*
    static func playfairDisplay(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("PlayfairDisplay-Regular", size: size)
    }

    static func cinzel(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Cinzel-Regular", size: size)
    }
    */
}

// MARK: - Text Style Modifiers
extension View {
    func appTitleStyle() -> some View {
        self
            .font(.serifTitle())
            .foregroundColor(.primaryText)
    }

    func appHeadlineStyle() -> some View {
        self
            .font(.serifHeadline())
            .foregroundColor(.primaryText)
    }

    func appBodyStyle() -> some View {
        self
            .font(.serifBody())
            .foregroundColor(.primaryText)
    }

    func appCaptionStyle() -> some View {
        self
            .font(.serifCaption())
            .foregroundColor(.secondaryText)
    }

    func readingTextStyle() -> some View {
        self
            .font(.readingFont())
            .foregroundColor(.primaryText)
            .lineSpacing(8)
    }
}
