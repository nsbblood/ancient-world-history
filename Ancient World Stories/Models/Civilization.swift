//
//  Civilization.swift
//  Ancient World Stories Universe
//
//  Created by Claude Code
//

import Foundation
import CoreLocation

struct Civilization: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let eraStart: String
    let eraEnd: String
    let region: String
    let description: String
    let createdAt: Date?
    
    // Map coordinates (not stored in DB, computed based on region)
    var coordinate: CLLocationCoordinate2D {
        switch name {
        case "Ancient Mesopotamia":
            return CLLocationCoordinate2D(latitude: 33.3152, longitude: 44.3661) // Baghdad area
        case "Ancient Egypt":
            return CLLocationCoordinate2D(latitude: 26.8206, longitude: 30.8025) // Luxor
        case "Ancient Greece":
            return CLLocationCoordinate2D(latitude: 37.9838, longitude: 23.7275) // Athens
        case "Roman Empire":
            return CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964) // Rome
        case "Ancient China":
            return CLLocationCoordinate2D(latitude: 34.3416, longitude: 108.9398) // Xi'an
        case "Medieval Europe":
            return CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522) // Paris
        default:
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
    
    // Parse year from era string (e.g., "3500 BC" -> -3500)
    var startYear: Int {
        parseYear(from: eraStart)
    }
    
    var endYear: Int {
        parseYear(from: eraEnd)
    }
    
    private func parseYear(from era: String) -> Int {
        let components = era.components(separatedBy: " ")
        guard let yearString = components.first,
              let year = Int(yearString) else { return 0 }
        
        if era.contains("BC") {
            return -year
        } else {
            return year
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case eraStart = "era_start"
        case eraEnd = "era_end"
        case region
        case description
        case createdAt = "created_at"
    }

    init(id: UUID = UUID(), name: String, eraStart: String, eraEnd: String, region: String, description: String, createdAt: Date? = nil) {
        self.id = id
        self.name = name
        self.eraStart = eraStart
        self.eraEnd = eraEnd
        self.region = region
        self.description = description
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

        name = try container.decode(String.self, forKey: .name)
        eraStart = try container.decode(String.self, forKey: .eraStart)
        eraEnd = try container.decode(String.self, forKey: .eraEnd)
        region = try container.decode(String.self, forKey: .region)
        description = try container.decode(String.self, forKey: .description)

        if let timestamp = try? container.decode(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            createdAt = formatter.date(from: timestamp)
        } else {
            createdAt = try? container.decode(Date.self, forKey: .createdAt)
        }
    }

    var eraDisplay: String {
        "\(eraStart) – \(eraEnd)"
    }
}

// MARK: - Sample Data
extension Civilization {
    static let samples: [Civilization] = [
        Civilization(
            name: "Ancient Mesopotamia",
            eraStart: "3500 BC",
            eraEnd: "539 BC",
            region: "Middle East",
            description: "The cradle of civilization, home to the Sumerians, Akkadians, Babylonians, and Assyrians. Birthplace of writing, law, and the wheel."
        ),
        Civilization(
            name: "Ancient Egypt",
            eraStart: "3100 BC",
            eraEnd: "30 BC",
            region: "North Africa",
            description: "Land of the pharaohs, pyramids, and hieroglyphs. A civilization that mastered architecture, medicine, and the afterlife."
        ),
        Civilization(
            name: "Ancient Greece",
            eraStart: "800 BC",
            eraEnd: "146 BC",
            region: "Mediterranean",
            description: "Birthplace of democracy, philosophy, and Olympic games. Home to Socrates, Plato, and Alexander the Great."
        ),
        Civilization(
            name: "Roman Empire",
            eraStart: "27 BC",
            eraEnd: "476 AD",
            region: "Mediterranean & Europe",
            description: "The eternal empire that shaped Western civilization through law, engineering, and military might."
        ),
        Civilization(
            name: "Ancient China",
            eraStart: "2070 BC",
            eraEnd: "220 AD",
            region: "East Asia",
            description: "Dynasty of dynasties. Inventors of paper, gunpowder, and the compass. Builders of the Great Wall."
        ),
        Civilization(
            name: "Medieval Europe",
            eraStart: "500 AD",
            eraEnd: "1500 AD",
            region: "Europe",
            description: "Era of knights, castles, and crusades. Age of chivalry, feudalism, and the rise of universities."
        )
    ]
}
