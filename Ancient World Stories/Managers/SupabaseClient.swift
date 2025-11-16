//
//  SupabaseClient.swift
//  Ancient World Stories
//
//  Created by Claude Code
//

import Foundation

enum SupabaseError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case missingConfiguration
}

class SupabaseClient {
    static let shared = SupabaseClient()

    private let projectURL: String
    private let anonKey: String

    private init() {
        // Priority 1: Configuration.swift (hardcoded)
        if Configuration.isSupabaseConfigured {
            self.projectURL = Configuration.supabaseURL
            self.anonKey = Configuration.supabaseAnonKey
        }
        // Priority 2: Environment variables or Info.plist
        else if let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
                let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String {
            self.projectURL = url
            self.anonKey = key
        }
        // Priority 3: Fallback (will cause data to load from local JSON)
        else {
            self.projectURL = "https://your-project.supabase.co"
            self.anonKey = "your-anon-key"
        }
    }

    // MARK: - Fetch Civilizations
    func fetchCivilizations(languageCode: String? = nil, limit: Int? = nil) async throws -> [Civilization] {
        var endpoint = "\(projectURL)/rest/v1/civilizations?select=*"
        if let languageCode = languageCode {
            endpoint += "&language_code=eq.\(languageCode)"
        }
        endpoint += "&order=era_start.asc"
        if let limit = limit {
            endpoint += "&limit=\(limit)"
        }

        guard let url = URL(string: endpoint) else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw SupabaseError.invalidResponse
            }

            let decoder = JSONDecoder()
            let civilizations = try decoder.decode([Civilization].self, from: data)

            let filename = limit != nil ? "civilizations_quick_\(limit!)_cache.json" : "civilizations_cache.json"
            cacheData(data, filename: filename)
            return civilizations
        } catch let error as DecodingError {
            throw SupabaseError.decodingError(error)
        } catch {
            throw SupabaseError.networkError(error)
        }
    }

    // MARK: - Fetch Stories
    func fetchStories(forCivilization civilizationId: UUID? = nil, languageCode: String? = nil, limit: Int? = nil) async throws -> [Story] {
        var endpoint = "\(projectURL)/rest/v1/stories?select=*"
        if let civilizationId = civilizationId {
            endpoint += "&civilization_id=eq.\(civilizationId.uuidString)"
        }
        if let languageCode = languageCode {
            endpoint += "&language_code=eq.\(languageCode)"
        }
        endpoint += "&order=created_at.desc"

        if let limit = limit {
            endpoint += "&limit=\(limit)"
        }

        guard let url = URL(string: endpoint) else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw SupabaseError.invalidResponse
            }

            let decoder = JSONDecoder()
            let stories = try decoder.decode([Story].self, from: data)

            let filename = civilizationId != nil ? "stories_\(civilizationId!.uuidString)_cache.json" : "stories_cache.json"
            cacheData(data, filename: filename)

            return stories
        } catch let error as DecodingError {
            throw SupabaseError.decodingError(error)
        } catch {
            throw SupabaseError.networkError(error)
        }
    }

    // MARK: - Fetch Chapters
    func fetchChapters(forStory storyId: UUID? = nil, languageCode: String? = nil) async throws -> [Chapter] {
        var endpoint = "\(projectURL)/rest/v1/chapters?select=*"
        if let storyId = storyId {
            endpoint += "&story_id=eq.\(storyId.uuidString)"
        }
        if let languageCode = languageCode {
            // Use exact match, same as civilizations and stories
            endpoint += "&language_code=eq.\(languageCode)"
        }
        endpoint += "&order=order_no.asc"

        guard let url = URL(string: endpoint) else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw SupabaseError.invalidResponse
            }

            let decoder = JSONDecoder()
            let chapters = try decoder.decode([Chapter].self, from: data)

            let filename = storyId != nil ? "chapters_\(storyId!.uuidString)_cache.json" : "chapters_cache.json"
            cacheData(data, filename: filename)

            return chapters
        } catch let error as DecodingError {
            throw SupabaseError.decodingError(error)
        } catch {
            throw SupabaseError.networkError(error)
        }
    }

    // MARK: - Update Chapter Audio URL
    func updateChapterAudioURL(chapterId: UUID, audioURL: String) async throws {
        let endpoint = "\(projectURL)/rest/v1/chapters?id=eq.\(chapterId.uuidString)"

        guard let url = URL(string: endpoint) else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")

        let payload: [String: String] = ["audio_url": audioURL]
        request.httpBody = try JSONEncoder().encode(payload)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw SupabaseError.invalidResponse
            }

            print("✅ Updated audio_url for chapter \(chapterId)")
        } catch {
            print("❌ Failed to update audio_url: \(error)")
            throw SupabaseError.networkError(error)
        }
    }

    // MARK: - Caching
    private func cacheData(_ data: Data, filename: String) {
        guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }

        let fileURL = cacheDir.appendingPathComponent(filename)
        try? data.write(to: fileURL)
    }

    func loadCachedData(filename: String) -> Data? {
        guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = cacheDir.appendingPathComponent(filename)
        return try? Data(contentsOf: fileURL)
    }
}
