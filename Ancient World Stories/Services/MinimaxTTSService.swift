//
//  MinimaxTTSService.swift
//  Ancient World Stories
//
//  Neural TTS service using Fal AI Minimax Speech 2.6 Turbo
//  via Supabase Edge Function for secure API key handling
//

import Foundation
import AVFoundation
import Combine

@MainActor
class MinimaxTTSService: ObservableObject {
    static let shared = MinimaxTTSService()

    @Published var isGenerating = false
    @Published var error: String?

    private var audioPlayer: AVAudioPlayer?
    private let supabaseURL = "https://njpjehnphsceepechadv.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qcGplaG5waHNjZWVwZWNoYWR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMDk5MTEsImV4cCI6MjA3NzU4NTkxMX0.deAvavILAyoKDFR9K3Rw5FwO_lJ1r7_GKoE9WHjiVx0"

    // Voice options from Minimax
    enum Voice: String, CaseIterable {
        case wiseWoman = "Wise_Woman"
        case friendlyPerson = "Friendly_Person"
        case inspirationalGirl = "Inspirational_girl"
        case deepVoiceMan = "Deep_Voice_Man"
        case calmWoman = "Calm_Woman"
        case casualGuy = "Casual_Guy"

        var displayName: String {
            switch self {
            case .wiseWoman: return "Wise Woman"
            case .friendlyPerson: return "Friendly Person"
            case .inspirationalGirl: return "Inspirational Girl"
            case .deepVoiceMan: return "Deep Voice Man"
            case .calmWoman: return "Calm Woman"
            case .casualGuy: return "Casual Guy"
            }
        }
    }

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Generate and Play Speech (with caching)

    /// Get or generate audio for a chapter with full caching support
    /// Flow: Chapter audioURL → Local cache → Generate new + Save to Supabase + Cache locally
    func speakChapter(_ chapter: Chapter) async throws {
        let cacheKey = AudioCacheService.shared.cacheKey(
            for: chapter.text,
            voice: Voice.wiseWoman.rawValue,
            language: chapter.languageCode
        )

        // 1. Check if Chapter already has audioURL from Supabase
        if let audioURLString = chapter.audioURL,
           !audioURLString.isEmpty {
            print("✅ Chapter has audioURL from Supabase")

            do {
                let localURL = try await AudioCacheService.shared.downloadAndCache(
                    from: audioURLString,
                    key: cacheKey
                )
                let audioData = try Data(contentsOf: localURL)
                try await playAudio(data: audioData)
                return
            } catch {
                print("⚠️ Failed to use audioURL, will regenerate: \(error)")
            }
        }

        // 2. Check local cache
        if let cachedURL = AudioCacheService.shared.getCachedAudio(key: cacheKey) {
            print("✅ Found in local cache")
            let audioData = try Data(contentsOf: cachedURL)
            try await playAudio(data: audioData)
            return
        }

        // 3. Generate new audio
        print("🎙️ Generating new audio...")
        isGenerating = true
        defer { isGenerating = false }

        do {
            // Generate via AI
            let audioURL = try await generateSpeech(
                text: chapter.text,
                voice: .wiseWoman,
                speed: 1.0,
                language: chapter.languageCode
            )

            // Download and cache locally
            let audioData = try await downloadAudio(from: audioURL)
            _ = try AudioCacheService.shared.saveAudio(data: audioData, key: cacheKey)

            // Save audioURL to Supabase for other users
            Task.detached {
                try? await SupabaseClient.shared.updateChapterAudioURL(
                    chapterId: chapter.id,
                    audioURL: audioURL.absoluteString
                )
            }

            // Play audio
            try await playAudio(data: audioData)

        } catch {
            self.error = error.localizedDescription
            print("❌ TTS Error: \(error)")
            throw error
        }
    }

    /// Legacy speak function (kept for backward compatibility)
    func speak(text: String, voice: Voice = .wiseWoman, speed: Double = 1.0, language: String = "en") async throws {
        guard !text.isEmpty else {
            throw TTSError.emptyText
        }

        isGenerating = true
        error = nil

        defer {
            isGenerating = false
        }

        do {
            // 1. Call Supabase Edge Function to get audio URL
            let audioURL = try await generateSpeech(text: text, voice: voice, speed: speed, language: language)

            // 2. Download audio file
            let audioData = try await downloadAudio(from: audioURL)

            // 3. Play audio
            try await playAudio(data: audioData)

        } catch {
            self.error = error.localizedDescription
            print("❌ TTS Error: \(error)")
            throw error
        }
    }

    // MARK: - Generate Speech via Supabase Edge Function

    private func generateSpeech(text: String, voice: Voice, speed: Double, language: String) async throws -> URL {
        let endpoint = URL(string: "\(supabaseURL)/functions/v1/minimax-tts")!

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = [
            "text": text,
            "voice_id": voice.rawValue,
            "speed": speed,
            "language": language
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        print("🎙️ Generating speech for: \"\(text.prefix(50))...\"")
        print("   Voice: \(voice.displayName), Speed: \(speed)x")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TTSError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Edge Function error (\(httpResponse.statusCode)): \(errorMessage)")
            throw TTSError.serverError(errorMessage)
        }

        struct TTSResponse: Codable {
            let audio_url: String
            let duration_ms: Int?
        }

        let ttsResponse = try JSONDecoder().decode(TTSResponse.self, from: data)

        guard let audioURL = URL(string: ttsResponse.audio_url) else {
            throw TTSError.invalidAudioURL
        }

        print("✅ Audio generated successfully (\(ttsResponse.duration_ms ?? 0)ms)")

        return audioURL
    }

    // MARK: - Download Audio

    private func downloadAudio(from url: URL) async throws -> Data {
        print("⬇️ Downloading audio from: \(url)")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TTSError.downloadFailed
        }

        print("✅ Downloaded \(data.count / 1024)KB audio")

        return data
    }

    // MARK: - Play Audio

    private func playAudio(data: Data) async throws {
        print("🔊 Playing audio...")

        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()

        // Wait for playback to finish
        while audioPlayer?.isPlaying == true {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }

        print("✅ Playback finished")
    }

    // MARK: - Stop Playback

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        print("⏹️ Playback stopped")
    }

    // MARK: - Cache Management (Optional)

    private var audioCache: [String: Data] = [:]

    func cacheAudio(for text: String, data: Data) {
        let key = text.hash.description
        audioCache[key] = data
    }

    func getCachedAudio(for text: String) -> Data? {
        let key = text.hash.description
        return audioCache[key]
    }

    func clearCache() {
        audioCache.removeAll()
        print("🗑️ Audio cache cleared")
    }
}

// MARK: - Error Types

enum TTSError: LocalizedError {
    case emptyText
    case invalidResponse
    case serverError(String)
    case invalidAudioURL
    case downloadFailed

    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Text cannot be empty"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let message):
            return "Server error: \(message)"
        case .invalidAudioURL:
            return "Invalid audio URL received"
        case .downloadFailed:
            return "Failed to download audio"
        }
    }
}
