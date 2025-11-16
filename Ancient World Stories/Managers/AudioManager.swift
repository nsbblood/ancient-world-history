//
//  AudioManager.swift
//  Ancient World Stories
//
//  Created by Claude Code
//

import AVFoundation
import SwiftUI
import Combine

enum TTSEngine: String, CaseIterable {
    case system = "System (Free)"
    case minimax = "Neural AI (Premium)"

    var displayName: String { rawValue }
    var isPremium: Bool { self == .minimax }
}

enum VoiceType: String, CaseIterable {
    case femaleUS = "com.apple.voice.compact.en-US.Samantha"
    case maleUS = "com.apple.voice.compact.en-US.Aaron"
    case femaleUK = "com.apple.voice.compact.en-GB.Kate"
    case maleAU = "com.apple.voice.compact.en-AU.Karen"

    var displayName: String {
        switch self {
        case .femaleUS: return "Samantha (Female, US)"
        case .maleUS: return "Aaron (Male, US)"
        case .femaleUK: return "Kate (Female, UK)"
        case .maleAU: return "Karen (Male, AU)"
        }
    }

    var language: String {
        switch self {
        case .femaleUS, .maleUS: return "en-US"
        case .femaleUK: return "en-GB"
        case .maleAU: return "en-AU"
        }
    }
}

@MainActor
class AudioManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = AudioManager()

    let synthesizer = AVSpeechSynthesizer()

    @Published var isPlaying = false
    @Published var currentProgress: Double = 0.0
    @Published var selectedVoice: VoiceType = .femaleUS
    @Published var selectedEngine: TTSEngine = .minimax  // Default to Neural AI for premium users

    // DEFAULT VOICE: All users use the same voice for consistent caching
    let selectedMinimaxVoice: MinimaxTTSService.Voice = .wiseWoman

    private var currentUtterance: AVSpeechUtterance?
    private var totalCharacterCount: Int = 0
    private var currentCharacterIndex: Int = 0
    private var hasLoadedVoice = false

    private override init() {
        super.init()
        synthesizer.delegate = self
        // Don't load voice in init - lazy load on first use
    }

    // MARK: - Voice Selection
    private func ensureVoiceLoaded() {
        guard !hasLoadedVoice else { return }
        hasLoadedVoice = true
        loadSelectedVoice()
    }

    func loadSelectedVoice() {
        if let savedVoice = UserDefaults.standard.string(forKey: "selectedVoice"),
           let voice = VoiceType(rawValue: savedVoice) {
            selectedVoice = voice
        }
    }

    func setVoice(_ voice: VoiceType) {
        selectedVoice = voice
        UserDefaults.standard.set(voice.rawValue, forKey: "selectedVoice")
    }

    // MARK: - Engine Selection
    func setEngine(_ engine: TTSEngine) {
        // Check if premium feature
        if engine.isPremium && !ProfileManager.shared.isPremium {
            print("⚠️ Neural AI TTS requires premium subscription")
            return
        }

        selectedEngine = engine
        UserDefaults.standard.set(engine.rawValue, forKey: "selectedTTSEngine")
        print("🎙️ TTS Engine set to: \(engine.displayName)")
    }

    // Note: Voice selection removed - all users use default .wiseWoman voice
    // This ensures consistent audio URLs for caching across all users

    // MARK: - Playback Control

    /// Speak chapter with full caching support (recommended)
    func speakChapter(_ chapter: Chapter) {
        // Lazy load voice settings on first use
        ensureVoiceLoaded()

        // Stop any current speech
        stop()

        // Route to appropriate TTS engine
        switch selectedEngine {
        case .system:
            speakWithSystem(text: chapter.text, language: "\(chapter.languageCode)-US")

        case .minimax:
            // Check premium status
            guard ProfileManager.shared.isPremium else {
                print("⚠️ Neural AI TTS requires premium - falling back to system")
                speakWithSystem(text: chapter.text, language: "\(chapter.languageCode)-US")
                return
            }

            speakWithMinimaxChapter(chapter: chapter)
        }
    }

    /// Legacy speak function (for backward compatibility)
    func speak(text: String, language: String = "en-US") {
        // Lazy load voice settings on first use
        ensureVoiceLoaded()

        // Stop any current speech
        stop()

        // Route to appropriate TTS engine
        switch selectedEngine {
        case .system:
            speakWithSystem(text: text, language: language)

        case .minimax:
            // Check premium status
            guard ProfileManager.shared.isPremium else {
                print("⚠️ Neural AI TTS requires premium - falling back to system")
                speakWithSystem(text: text, language: language)
                return
            }

            speakWithMinimax(text: text, language: language)
        }
    }

    private func speakWithSystem(text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5 // Slightly slower for storytelling
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        // Try to use selected voice
        if let voice = AVSpeechSynthesisVoice(identifier: selectedVoice.rawValue) {
            utterance.voice = voice
        } else {
            // Fallback to language-based voice
            utterance.voice = AVSpeechSynthesisVoice(language: language)
        }

        currentUtterance = utterance
        totalCharacterCount = text.count
        currentCharacterIndex = 0
        currentProgress = 0.0

        synthesizer.speak(utterance)
        isPlaying = true
    }

    private func speakWithMinimaxChapter(chapter: Chapter) {
        isPlaying = true

        Task {
            do {
                // Use new cached chapter speak function
                try await MinimaxTTSService.shared.speakChapter(chapter)

                // Reset playing state when done
                self.isPlaying = false
                self.currentProgress = 1.0

            } catch {
                print("❌ Minimax TTS failed, falling back to system: \(error)")

                // Fallback to system TTS
                self.speakWithSystem(text: chapter.text, language: "\(chapter.languageCode)-US")
            }
        }
    }

    private func speakWithMinimax(text: String, language: String) {
        isPlaying = true

        Task {
            do {
                let langCode = language.prefix(2).lowercased() // "en-US" -> "en"
                try await MinimaxTTSService.shared.speak(
                    text: text,
                    voice: selectedMinimaxVoice,
                    speed: 1.0,
                    language: String(langCode)
                )

                // Reset playing state when done
                self.isPlaying = false
                self.currentProgress = 1.0

            } catch {
                print("❌ Minimax TTS failed, falling back to system: \(error)")

                // Fallback to system TTS
                self.speakWithSystem(text: text, language: language)
            }
        }
    }

    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
            isPlaying = false
        }
    }

    func resume() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            isPlaying = true
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        MinimaxTTSService.shared.stop()
        isPlaying = false
        currentProgress = 0.0
        currentCharacterIndex = 0
    }

    // MARK: - AVSpeechSynthesizerDelegate
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPlaying = false
            self.currentProgress = 1.0
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPlaying = false
            self.currentProgress = 0.0
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.currentCharacterIndex = characterRange.location
            if self.totalCharacterCount > 0 {
                self.currentProgress = Double(self.currentCharacterIndex) / Double(self.totalCharacterCount)
            }
        }
    }

    // MARK: - Available Voices
    func availableVoices() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().filter { voice in
            voice.language.hasPrefix("en")
        }
    }
}
