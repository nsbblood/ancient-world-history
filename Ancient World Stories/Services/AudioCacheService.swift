//
//  AudioCacheService.swift
//  Ancient World Stories
//
//  Manages audio caching for TTS narration
//  - Local disk cache for offline playback
//  - Supabase integration for cross-user sharing
//

import Foundation

@MainActor
class AudioCacheService {
    static let shared = AudioCacheService()

    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        // Create cache directory in app's documents folder
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("AudioCache", isDirectory: true)

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }

        print("📁 Audio cache directory: \(cacheDirectory.path)")
    }

    // MARK: - Cache Key Generation

    /// Generate unique cache key for audio based on text + voice + language
    /// This ensures same audio is reused across all users
    func cacheKey(for text: String, voice: String, language: String) -> String {
        let combined = "\(text)-\(voice)-\(language)"
        return combined.data(using: .utf8)!
            .base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .prefix(64) // Limit length for filesystem
            .appending(".mp3")
    }

    // MARK: - Local Disk Cache

    /// Check if audio exists in local cache
    func getCachedAudio(key: String) -> URL? {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        if fileManager.fileExists(atPath: fileURL.path) {
            print("✅ Found cached audio: \(key)")
            return fileURL
        }

        print("❌ No cached audio: \(key)")
        return nil
    }

    /// Save audio data to local cache
    func saveAudio(data: Data, key: String) throws -> URL {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        try data.write(to: fileURL)

        let sizeKB = data.count / 1024
        print("💾 Saved audio to cache: \(key) (\(sizeKB)KB)")

        return fileURL
    }

    /// Download and cache audio from URL
    func downloadAndCache(from urlString: String, key: String) async throws -> URL {
        // Check if already cached locally
        if let cachedURL = getCachedAudio(key: key) {
            return cachedURL
        }

        // Download from remote URL
        guard let url = URL(string: urlString) else {
            throw AudioCacheError.invalidURL
        }

        print("⬇️ Downloading audio from: \(urlString)")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AudioCacheError.downloadFailed
        }

        // Save to cache
        return try saveAudio(data: data, key: key)
    }

    // MARK: - Cache Management

    /// Get total cache size in bytes
    func getCacheSize() -> Int64 {
        var totalSize: Int64 = 0

        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }

        for file in files {
            if let fileSize = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(fileSize)
            }
        }

        return totalSize
    }

    /// Get formatted cache size (e.g., "25.3 MB")
    func getFormattedCacheSize() -> String {
        let bytes = getCacheSize()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    /// Clear all cached audio files
    func clearCache() throws {
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)

        for file in files {
            try fileManager.removeItem(at: file)
        }

        print("🗑️ Cleared audio cache (\(files.count) files)")
    }

    /// Clear old cache files (older than specified days)
    func clearOldCache(olderThanDays days: Int) throws {
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey])

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        var deletedCount = 0

        for file in files {
            if let creationDate = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate,
               creationDate < cutoffDate {
                try fileManager.removeItem(at: file)
                deletedCount += 1
            }
        }

        print("🗑️ Cleared \(deletedCount) old cache files (> \(days) days)")
    }
}

// MARK: - Error Types

enum AudioCacheError: LocalizedError {
    case invalidURL
    case downloadFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid audio URL"
        case .downloadFailed:
            return "Failed to download audio"
        case .saveFailed:
            return "Failed to save audio to cache"
        }
    }
}
