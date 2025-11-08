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

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                List {
                    // TTS Engine Selection
                    Section {
                        ForEach(TTSEngine.allCases, id: \.self) { engine in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(engine.displayName)
                                        .font(.serifBody())
                                        .foregroundColor(.primaryText)

                                    if engine.isPremium {
                                        HStack(spacing: 4) {
                                            Image(systemName: "crown.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(.appAccent)
                                            Text("Premium - Neural AI Voice")
                                                .font(.serifCaption2())
                                                .foregroundColor(.secondaryText)
                                        }
                                    } else {
                                        Text("Standard iOS Voice")
                                            .font(.serifCaption2())
                                            .foregroundColor(.secondaryText)
                                    }
                                }

                                Spacer()

                                if audioManager.selectedEngine == engine {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.appAccent)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if engine.isPremium && !profileManager.isPremium {
                                    // Show premium required message
                                    print("⚠️ Premium required for Neural AI")
                                } else {
                                    audioManager.selectedEngine = engine
                                }
                            }
                            .listRowBackground(Color.cardBackground)
                        }
                    } header: {
                        Text("Voice Engine")
                            .font(.serifBody())
                            .foregroundColor(.primaryText)
                    } footer: {
                        if audioManager.selectedEngine.isPremium {
                            Text("Neural AI provides natural, human-like narration powered by advanced AI.")
                                .font(.serifCaption())
                                .foregroundColor(.secondaryText)
                        }
                    }

                    // Voice Selection based on engine
                    if audioManager.selectedEngine == .system {
                        Section {
                            ForEach(VoiceType.allCases, id: \.self) { voice in
                                HStack {
                                    Text(voice.displayName)
                                        .font(.serifBody())
                                        .foregroundColor(.primaryText)

                                    Spacer()

                                    if audioManager.selectedVoice == voice {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.appAccent)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    audioManager.setVoice(voice)
                                }
                                .listRowBackground(Color.cardBackground)
                            }
                        } header: {
                            Text("System Voice")
                                .font(.serifBody())
                                .foregroundColor(.primaryText)
                        }
                    } else {
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
                                    audioManager.setMinimaxVoice(voice)
                                }
                                .listRowBackground(Color.cardBackground)
                            }
                        } header: {
                            Text("Neural AI Voice Character")
                                .font(.serifBody())
                                .foregroundColor(.primaryText)
                        } footer: {
                            Text("Choose a voice character that brings ancient stories to life.")
                                .font(.serifCaption())
                                .foregroundColor(.secondaryText)
                        }
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
