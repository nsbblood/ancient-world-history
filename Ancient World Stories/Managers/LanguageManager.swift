//
//  LanguageManager.swift
//  Ancient World Stories
//
//  Manages app language selection for multi-language content
//

import Foundation
import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"
    case german = "de"
    case french = "fr"
    case spanish = "es"
    case italian = "it"
    case japanese = "ja"
    case korean = "ko"
    case dutch = "nl"
    case arabic = "ar"
    case swedish = "sv"
    case norwegian = "no"
    case danish = "da"
    case finnish = "fi"
    case portuguese = "pt"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Turkish"
        case .german: return "German"
        case .french: return "French"
        case .spanish: return "Spanish"
        case .italian: return "Italian"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .dutch: return "Dutch"
        case .arabic: return "Arabic"
        case .swedish: return "Swedish"
        case .norwegian: return "Norwegian"
        case .danish: return "Danish"
        case .finnish: return "Finnish"
        case .portuguese: return "Portuguese"
        }
    }

    var nativeName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .spanish: return "Español"
        case .italian: return "Italiano"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .dutch: return "Nederlands"
        case .arabic: return "العربية"
        case .swedish: return "Svenska"
        case .norwegian: return "Norsk"
        case .danish: return "Dansk"
        case .finnish: return "Suomi"
        case .portuguese: return "Português"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .turkish: return "🇹🇷"
        case .german: return "🇩🇪"
        case .french: return "🇫🇷"
        case .spanish: return "🇪🇸"
        case .italian: return "🇮🇹"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .dutch: return "🇳🇱"
        case .arabic: return "🇸🇦"
        case .swedish: return "🇸🇪"
        case .norwegian: return "🇳🇴"
        case .danish: return "🇩🇰"
        case .finnish: return "🇫🇮"
        case .portuguese: return "🇵🇹"
        }
    }
}

@MainActor
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var selectedLanguage: AppLanguage

    private init() {
        // Try to load saved language, or use device language, or default to English
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            selectedLanguage = language
        } else {
            // Auto-detect device language
            let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            selectedLanguage = AppLanguage(rawValue: deviceLanguage) ?? .english
        }
    }

    func setLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "selectedLanguage")
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        print("🌍 Language changed to: \(language.displayName)")

        // Clear cache and reload content with new language
        ContentLoader.shared.clearPersistentCache()
        ContentLoader.shared.loadInitialData()
    }

    var currentLanguageCode: String {
        selectedLanguage.rawValue
    }

    // Get bundle for current language
    var currentBundle: Bundle {
        guard let path = Bundle.main.path(forResource: selectedLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }

    // Localized string helper
    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, bundle: currentBundle, comment: "")
    }
}
