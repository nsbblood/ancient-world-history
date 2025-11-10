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
                        ForEach(AppLanguage.allCases) { language in
                            Button {
                                languageManager.setLanguage(language)
                            } label: {
                                HStack {
                                    Text(language.flag)
                                        .font(.system(size: 24))

                                    Text(language.nativeName)
                                        .font(.serifBody())
                                        .foregroundColor(.primaryText)

                                    Spacer()

                                    if languageManager.selectedLanguage == language {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .listRowBackground(Color.cardBackground)
                        }
                    } header: {
                        Text("Language")
                            .font(.serifBody())
                            .foregroundColor(.primaryText)
                    } footer: {
                        Text("Select your preferred language for stories and narration")
                            .font(.serifCaption())
                            .foregroundColor(.secondaryText)
                    }

                    Section {
                        SettingsRow(
                            icon: "envelope.fill",
                            title: "Contact Support",
                            subtitle: "hi@dainty.app"
                        ) {
                            if let url = URL(string: "mailto:hi@dainty.app") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .listRowBackground(Color.cardBackground)
                    } header: {
                        Text("Support")
                            .font(.serifBody())
                            .foregroundColor(.primaryText)
                    }

                    Section {
                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Privacy Policy",
                            subtitle: "How we handle your data"
                        ) {
                            if let url = URL(string: "https://dainty.app/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .listRowBackground(Color.cardBackground)

                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Terms of Service",
                            subtitle: "Our terms and conditions"
                        ) {
                            if let url = URL(string: "https://dainty.app/terms") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .listRowBackground(Color.cardBackground)
                    } header: {
                        Text("Legal")
                            .font(.serifBody())
                            .foregroundColor(.primaryText)
                    }

                    Section {
                        HStack {
                            Text("Version")
                                .font(.serifBody())
                                .foregroundColor(.primaryText)

                            Spacer()

                            Text("1.0.0")
                                .font(.serifBody())
                                .foregroundColor(.secondaryText)
                        }
                        .listRowBackground(Color.cardBackground)
                    } header: {
                        Text("About")
                            .font(.serifBody())
                            .foregroundColor(.primaryText)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
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
