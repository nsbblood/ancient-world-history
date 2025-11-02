//
//  Color+Theme.swift
//  Ancient World Stories
//
//  Created by Claude Code
//

import SwiftUI

extension Color {
    // MARK: - App Theme Colors
    static let appBackground = Color(hex: "F7F4EC")
    static let appText = Color(hex: "3E3A31")
    static let appAccent = Color(hex: "A98358")
    static let appSecondary = Color(hex: "D4C5A9")
    static let appCardBackground = Color(hex: "FFFFFF")

    // MARK: - Semantic Colors
    static let primaryText = appText
    static let secondaryText = appText.opacity(0.7)
    static let accentColor = appAccent
    static let backgroundColor = appBackground
    static let cardBackground = appCardBackground

    // MARK: - Civilization Colors
    static func civilizationColor(_ civilization: String) -> Color {
        switch civilization.lowercased() {
        case "mesopotamia": return Color(hex: "8B7355")
        case "egypt": return Color(hex: "D4AF37")
        case "greece": return Color(hex: "4A90E2")
        case "rome": return Color(hex: "8B0000")
        case "china": return Color(hex: "DC143C")
        case "medieval europe": return Color(hex: "4B5320")
        case "ottoman empire": return Color(hex: "C41E3A")
        case "mesoamerica": return Color(hex: "228B22")
        default: return appAccent
        }
    }

    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
