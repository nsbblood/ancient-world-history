//
//  VoiceSelectorView.swift
//  Ancient World Stories
//
//  Voice selection for TTS (System vs Neural AI)
//

import SwiftUI

struct VoiceSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var profileManager = ProfileManager.shared
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                List {
                    // Premium badge section
                    if !profileManager.isPremium {
                        Section {
                            HStack(spacing: 12) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.appAccent)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Premium Feature")
                                        .font(.serifBody())
                                        .foregroundColor(.primaryText)

                                    Text("Unlock Neural AI voices with premium")
                                        .font(.serifCaption2())
                                        .foregroundColor(.secondaryText)
                                }

                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.appAccent.opacity(0.1))
                        }
                    }

                    // Neural AI Voice Selection
                    Section {
                        ForEach(MinimaxTTSService.Voice.allCases, id: \.self) { voice in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(voice.displayName)
                                        .font(.serifBody())
                                        .foregroundColor(.primaryText)

                                    Text(voiceDescription(for: voice))
                                        .font(.serifCaption2())
                                        .foregroundColor(.secondaryText)
                                }

                                Spacer()

                                if audioManager.selectedMinimaxVoice == voice {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.appAccent)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if !profileManager.isPremium {
                                    showPaywall = true
                                } else {
                                    audioManager.setMinimaxVoice(voice)
                                }
                            }
                            .listRowBackground(Color.cardBackground)
                            .opacity(profileManager.isPremium ? 1.0 : 0.6)
                        }
                    } header: {
                        Text("Neural AI Voices")
                            .font(.serifBody())
                            .foregroundColor(.primaryText)
                    } footer: {
                        Text("Natural, human-like narration powered by advanced AI. Choose a voice character that brings ancient stories to life.")
                            .font(.serifCaption())
                            .foregroundColor(.secondaryText)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Voice Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.serifBody())
                            .foregroundColor(.appAccent)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
            }
        }
    }

    private func voiceDescription(for voice: MinimaxTTSService.Voice) -> String {
        switch voice {
        case .wiseWoman: return "Experienced, calm storyteller"
        case .deepVoiceMan: return "Powerful, authoritative narrator"
        case .calmWoman: return "Peaceful, soothing voice"
        case .casualGuy: return "Friendly, conversational tone"
        case .friendlyPerson: return "Warm, welcoming narrator"
        case .inspirationalGirl: return "Energetic, motivating voice"
        }
    }
}

#Preview {
    VoiceSelectorView()
}
