//
//  Chapter.swift
//  Ancient World Stories Universe
//
//  Created by Claude Code
//

import Foundation

struct Chapter: Identifiable, Codable, Hashable {
    let id: UUID
    let storyId: UUID
    let title: String
    let orderNo: Int
    let text: String
    let duration: Int // in seconds
    let languageCode: String

    enum CodingKeys: String, CodingKey {
        case id
        case storyId = "story_id"
        case title
        case orderNo = "order_no"
        case text
        case duration
        case languageCode = "language_code"
    }

    init(id: UUID = UUID(), storyId: UUID, title: String, orderNo: Int, text: String, duration: Int, languageCode: String = "en") {
        self.id = id
        self.storyId = storyId
        self.title = title
        self.orderNo = orderNo
        self.text = text
        self.duration = duration
        self.languageCode = languageCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let uuidString = try? container.decode(String.self, forKey: .id),
           let uuid = UUID(uuidString: uuidString) {
            id = uuid
        } else {
            id = try container.decode(UUID.self, forKey: .id)
        }

        if let uuidString = try? container.decode(String.self, forKey: .storyId),
           let uuid = UUID(uuidString: uuidString) {
            storyId = uuid
        } else {
            storyId = try container.decode(UUID.self, forKey: .storyId)
        }

        title = try container.decode(String.self, forKey: .title)
        orderNo = try container.decode(Int.self, forKey: .orderNo)
        text = try container.decode(String.self, forKey: .text)
        duration = try container.decode(Int.self, forKey: .duration)
        languageCode = (try? container.decode(String.self, forKey: .languageCode)) ?? "en"
    }

    var formattedDuration: String {
        let minutes = duration / 60
        let seconds = duration % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    var excerpt: String {
        let words = text.split(separator: " ")
        let previewWords = words.prefix(25)
        return previewWords.joined(separator: " ") + (words.count > 25 ? "..." : "")
    }

    var wordCount: Int {
        text.split(separator: " ").count
    }
}

// MARK: - Sample Data
extension Chapter {
    static func samples(for storyId: UUID, count: Int = 10) -> [Chapter] {
        let sampleTexts = [
            "The morning sun painted the ancient city in hues of amber and gold. Nammu clutched his clay tablet, fingers trembling with anticipation. Today would mark the beginning of his journey into the sacred art of writing, a privilege reserved for only a chosen few in all of Uruk.",
            "Master Enki's weathered hands moved across the wet clay with practiced grace. Each mark, each wedge, told a story that would outlast empires. 'A scribe,' he intoned, 'is more than a keeper of words. We are the memory of civilization itself, the bridge between gods and mortals.'",
            "The temple library was forbidden to novice scribes, yet here Nammu stood at midnight, heart pounding like war drums. The key Master Enki had given him felt heavy with responsibility. 'Some knowledge,' the old scribe had warned, 'changes those who find it forever.'",
            "By lamplight, Nammu discovered tablets far older than any he had studied. They spoke of times before the great flood, of kings who ruled for thousands of years, of wisdom that came from the stars themselves. His hands trembled as he traced the ancient cuneiform.",
            "Nammu was summoned to the palace at dawn, his hands still bearing traces of yesterday's clay. Now he stood before King Ur-Nammu, feeling the weight of destiny pressing upon his young shoulders. The king's words would change everything he thought he knew about truth and loyalty."
        ]

        return (1...count).map { index in
            Chapter(
                storyId: storyId,
                title: "Chapter \(index)",
                orderNo: index,
                text: sampleTexts[index % sampleTexts.count],
                duration: 45 + (index * 2)
            )
        }
    }
}
