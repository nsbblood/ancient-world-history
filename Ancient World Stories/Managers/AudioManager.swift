//
//  AudioManager.swift
//  Ancient World Stories
//
//  Created by Claude Code
//

import AVFoundation
import Combine
import SwiftUI

enum VoiceType: String, CaseIterable {
    case femaleUS = "com.apple.voice.compact.en-US.Samantha"
    case maleUS = "com.apple.voice.compact.en-US.Aaron"
    case femaleUK = "com.apple.voice.compact.en-GB.Martha"
    case maleUK = "com.apple.voice.compact.en-GB.Daniel"

    var displayName: String {
        switch self {
        case .femaleUS: return "Samantha (US)"
        case .maleUS: return "Aaron (US)"
        case .femaleUK: return "Martha (UK)"
        case .maleUK: return "Daniel (UK)"
        }
    }
}

@MainActor
class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()

    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var currentProgress: Double = 0.0

    private let synthesizer = AVSpeechSynthesizer()
    private var selectedVoiceIdentifier: String = VoiceType.femaleUS.rawValue
    private var totalCharacterCount: Double = 0

    private override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ Audio session setup failed: \(error.localizedDescription)")
        }
    }

    func speak(_ text: String) {
        stop()

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifier)
            ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95
        utterance.pitchMultiplier = 1.0

        totalCharacterCount = Double(max(text.count, 1))
        currentProgress = 0
        isPaused = false
        isPlaying = true
        synthesizer.speak(utterance)
    }

    func pause() {
        guard synthesizer.isSpeaking, !synthesizer.isPaused else { return }
        synthesizer.pauseSpeaking(at: .word)
        isPaused = true
        isPlaying = false
    }

    func resume() {
        guard synthesizer.isPaused else { return }
        synthesizer.continueSpeaking()
        isPaused = false
        isPlaying = true
    }

    func stop() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isPlaying = false
        isPaused = false
        currentProgress = 0
    }

    func setVoice(_ voice: VoiceType) {
        selectedVoiceIdentifier = voice.rawValue
    }

    func togglePlayback(for text: String) {
        if isPlaying {
            pause()
        } else if isPaused {
            resume()
        } else {
            speak(text)
        }
    }
}

extension AudioManager: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPlaying = false
            self.isPaused = false
            self.currentProgress = 1.0
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPlaying = false
            self.isPaused = false
            self.currentProgress = 0
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            guard self.totalCharacterCount > 0 else { return }
            self.currentProgress = min(1.0, Double(characterRange.location) / self.totalCharacterCount)
        }
    }
}
