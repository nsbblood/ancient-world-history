//
//  SettingsView.swift
//  Ancient World Stories
//
//  Settings screen with legal links and support
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileManager = ProfileManager.shared
    @ObservedObject private var languageManager = LanguageManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                List {
                    Section {
                        Picker("settings.language".localized, selection: Binding(
                            get: { languageManager.selectedLanguage },
                            set: { languageManager.setLanguage($0) }
                        )) {
                            ForEach(AppLanguage.allCases) { language in
                                Text("\(language.flag) \(language.nativeName)")
                                    .tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.serifBody())
                        .listRowBackground(Color.cardBackground)
                    } header: {
                        Text(localized: "settings.language")
                            .font(.serifBody())
                            .foregroundColor(.primaryText)
                    } footer: {
                        Text(localized: "settings.language_description")
                            .font(.serifCaption())
                            .foregroundColor(.secondaryText)
                    }

                    Section {
                        SettingsRow(
                            icon: "envelope.fill",
                            title: "settings.contact_support".localized,
                            subtitle: "hi@dainty.app"
                        ) {
                            if let url = URL(string: "mailto:hi@dainty.app") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .listRowBackground(Color.cardBackground)
                    } header: {
                        Text(localized: "support")
                            .font(.serifBody())
                            .foregroundColor(.primaryText)
                    }

                    Section {
                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "settings.privacy_policy".localized,
                            subtitle: "settings.privacy_description".localized
                        ) {
                            if let url = URL(string: "https://dainty.app/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .listRowBackground(Color.cardBackground)

                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "settings.terms".localized,
                            subtitle: "settings.terms_description".localized
                        ) {
                            if let url = URL(string: "https://dainty.app/terms") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .listRowBackground(Color.cardBackground)
                    } header: {
                        Text(localized: "settings.legal")
                            .font(.serifBody())
                            .foregroundColor(.primaryText)
                    }

                    Section {
                        HStack {
                            Text(localized: "version")
                                .font(.serifBody())
                                .foregroundColor(.primaryText)

                            Spacer()

                            Text("1.0.0")
                                .font(.serifBody())
                                .foregroundColor(.secondaryText)
                        }
                        .listRowBackground(Color.cardBackground)
                    } header: {
                        Text(localized: "about")
                            .font(.serifBody())
                            .foregroundColor(.primaryText)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(Text(localized: "settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondaryText)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.serifBody())
                        .foregroundColor(.primaryText)

                    Text(subtitle)
                        .font(.serifCaption())
                        .foregroundColor(.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondaryText)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
