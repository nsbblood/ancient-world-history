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
    func fetchCivilizations() async throws -> [Civilization] {
        let endpoint = "\(projectURL)/rest/v1/civilizations?select=*&order=era_start.asc"

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

            cacheData(data, filename: "civilizations_cache.json")
            return civilizations
        } catch let error as DecodingError {
            throw SupabaseError.decodingError(error)
        } catch {
            throw SupabaseError.networkError(error)
        }
    }

    // MARK: - Fetch Stories
    func fetchStories(forCivilization civilizationId: UUID? = nil) async throws -> [Story] {
        var endpoint = "\(projectURL)/rest/v1/stories?select=*"
        if let civilizationId = civilizationId {
            endpoint += "&civilization_id=eq.\(civilizationId.uuidString)"
        }
        endpoint += "&order=created_at.desc"

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
    func fetchChapters(forStory storyId: UUID? = nil) async throws -> [Chapter] {
        var endpoint = "\(projectURL)/rest/v1/chapters?select=*"
        if let storyId = storyId {
            endpoint += "&story_id=eq.\(storyId.uuidString)"
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
