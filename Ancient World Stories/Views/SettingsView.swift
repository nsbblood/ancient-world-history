//
//  SettingsView.swift
//  Ancient World Stories
//
//  Settings screen with legal links and support
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                List {
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
                    } header: {
                        Text("Support")
                            .font(.serifBody())
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

                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Terms of Service",
                            subtitle: "Our terms and conditions"
                        ) {
                            if let url = URL(string: "https://dainty.app/terms") {
                                UIApplication.shared.open(url)
                            }
                        }
                    } header: {
                        Text("Legal")
                            .font(.serifBody())
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
                    } header: {
                        Text("About")
                            .font(.serifBody())
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.serifBody())
                    .foregroundColor(.accentColor)
                }
            }
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
