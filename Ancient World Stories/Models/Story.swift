//
//  Story.swift
//  Ancient World Stories Universe
//
//  Created by Claude Code
//

import Foundation

struct Story: Identifiable, Codable, Hashable {
    let id: UUID
    let civilizationId: UUID
    let title: String
    let summary: String
    let chaptersCount: Int
    let languageCode: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case civilizationId = "civilization_id"
        case title
        case summary
        case chaptersCount = "chapters_count"
        case languageCode = "language_code"
        case createdAt = "created_at"
    }

    init(id: UUID = UUID(), civilizationId: UUID, title: String, summary: String, chaptersCount: Int, languageCode: String = "en", createdAt: Date? = nil) {
        self.id = id
        self.civilizationId = civilizationId
        self.title = title
        self.summary = summary
        self.chaptersCount = chaptersCount
        self.languageCode = languageCode
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let uuidString = try? container.decode(String.self, forKey: .id),
           let uuid = UUID(uuidString: uuidString) {
            id = uuid
        } else {
            id = try container.decode(UUID.self, forKey: .id)
        }

        if let uuidString = try? container.decode(String.self, forKey: .civilizationId),
           let uuid = UUID(uuidString: uuidString) {
            civilizationId = uuid
        } else {
            civilizationId = try container.decode(UUID.self, forKey: .civilizationId)
        }

        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        chaptersCount = try container.decode(Int.self, forKey: .chaptersCount)
        languageCode = (try? container.decode(String.self, forKey: .languageCode)) ?? "en"

        if let timestamp = try? container.decode(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            createdAt = formatter.date(from: timestamp)
        } else {
            createdAt = try? container.decode(Date.self, forKey: .createdAt)
        }
    }
}

// MARK: - Sample Data
extension Story {
    static func samples(for civilizationId: UUID) -> [Story] {
        [
            Story(
                civilizationId: civilizationId,
                title: "The Scribe's Secret",
                summary: "A young scribe discovers ancient texts that could change the course of history.",
                chaptersCount: 12
            ),
            Story(
                civilizationId: civilizationId,
                title: "Merchants of the Silk Road",
                summary: "Follow a caravan across treacherous deserts and through bustling bazaars.",
                chaptersCount: 15
            ),
            Story(
                civilizationId: civilizationId,
                title: "The Oracle's Vision",
                summary: "A priestess receives visions that challenge everything she believes.",
                chaptersCount: 10
            )
        ]
    }
}
