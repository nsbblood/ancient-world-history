//
//  String+Localization.swift
//  Ancient World Stories
//
//  Localization helpers for dynamic language switching
//

import Foundation
import SwiftUI

extension String {
    /// Get localized string using current LanguageManager bundle
    var localized: String {
        let bundle = LanguageManager.shared.currentBundle
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }

    /// Get localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        let bundle = LanguageManager.shared.currentBundle
        let format = NSLocalizedString(self, bundle: bundle, comment: "")
        return String(format: format, arguments: arguments)
    }
}

// SwiftUI Text helper
extension Text {
    init(localized key: String) {
        let bundle = LanguageManager.shared.currentBundle
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        self.init(localizedString)
    }
}
