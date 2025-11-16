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
    let languageCode: String
    let createdAt: Date?
    
    // Map coordinates (not stored in DB, computed based on name)
    var coordinate: CLLocationCoordinate2D {
        switch name {
        // AFRICA
        case "Ancient Egypt": return CLLocationCoordinate2D(latitude: 26.8206, longitude: 30.8025)
        case "Kingdom of Kush": return CLLocationCoordinate2D(latitude: 16.8845, longitude: 33.6303)
        case "Carthage": return CLLocationCoordinate2D(latitude: 36.8531, longitude: 10.3233)
        case "Kingdom of Aksum": return CLLocationCoordinate2D(latitude: 14.1308, longitude: 38.7199)
        case "Ghana Empire": return CLLocationCoordinate2D(latitude: 15.3333, longitude: -9.0)

        // MESOPOTAMIA & MIDDLE EAST
        case "Sumer": return CLLocationCoordinate2D(latitude: 31.0, longitude: 46.0)
        case "Akkadian Empire": return CLLocationCoordinate2D(latitude: 33.0, longitude: 44.5)
        case "Babylonia": return CLLocationCoordinate2D(latitude: 32.5363, longitude: 44.4209)
        case "Assyria": return CLLocationCoordinate2D(latitude: 36.2, longitude: 43.15)
        case "Hittite Empire": return CLLocationCoordinate2D(latitude: 40.0, longitude: 34.0)
        case "Phoenicia": return CLLocationCoordinate2D(latitude: 33.9, longitude: 35.5)
        case "Persian Empire", "Achaemenid Empire": return CLLocationCoordinate2D(latitude: 32.0, longitude: 53.0)
        case "Kingdom of Urartu": return CLLocationCoordinate2D(latitude: 39.0, longitude: 44.0)

        // EUROPE
        case "Ancient Greece": return CLLocationCoordinate2D(latitude: 38.0, longitude: 23.7)
        case "Roman Empire": return CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5)
        case "Minoan Civilization": return CLLocationCoordinate2D(latitude: 35.3, longitude: 25.1)
        case "Mycenaean Greece": return CLLocationCoordinate2D(latitude: 37.7, longitude: 22.8)
        case "Etruscan Civilization": return CLLocationCoordinate2D(latitude: 43.3, longitude: 11.3)
        case "Celtic Tribes": return CLLocationCoordinate2D(latitude: 48.0, longitude: -2.0)
        case "Ancient Sparta": return CLLocationCoordinate2D(latitude: 37.08, longitude: 22.42)
        case "Ancient Athens": return CLLocationCoordinate2D(latitude: 37.98, longitude: 23.73)
        case "Macedonian Empire": return CLLocationCoordinate2D(latitude: 40.63, longitude: 22.38)
        case "Byzantine Empire": return CLLocationCoordinate2D(latitude: 41.01, longitude: 28.97)
        case "Vikings": return CLLocationCoordinate2D(latitude: 59.91, longitude: 10.75)
        case "Ancient Thrace": return CLLocationCoordinate2D(latitude: 42.0, longitude: 26.0)

        // ASIA
        case "Shang Dynasty", "Zhou Dynasty", "Qin Dynasty", "Han Dynasty":
            return CLLocationCoordinate2D(latitude: 34.5, longitude: 109.0)
        case "Indus Valley Civilization": return CLLocationCoordinate2D(latitude: 27.5, longitude: 68.5)
        case "Maurya Empire": return CLLocationCoordinate2D(latitude: 25.6, longitude: 85.1)
        case "Gupta Empire": return CLLocationCoordinate2D(latitude: 25.3, longitude: 83.0)
        case "Jomon Period": return CLLocationCoordinate2D(latitude: 35.7, longitude: 139.7)
        case "Khmer Empire": return CLLocationCoordinate2D(latitude: 13.4, longitude: 103.8)
        case "Silla Kingdom": return CLLocationCoordinate2D(latitude: 35.8, longitude: 129.2)
        case "Parthian Empire": return CLLocationCoordinate2D(latitude: 36.3, longitude: 59.5)
        case "Scythian Empire": return CLLocationCoordinate2D(latitude: 47.0, longitude: 40.0)
        case "Xiongnu Confederation": return CLLocationCoordinate2D(latitude: 43.0, longitude: 104.0)
        case "Silk Road Kingdoms": return CLLocationCoordinate2D(latitude: 38.0, longitude: 75.0)

        // AMERICAS
        case "Maya Civilization": return CLLocationCoordinate2D(latitude: 17.5, longitude: -88.0)
        case "Aztec Empire": return CLLocationCoordinate2D(latitude: 19.4, longitude: -99.1)
        case "Inca Empire": return CLLocationCoordinate2D(latitude: -13.5, longitude: -71.9)
        case "Olmec Civilization": return CLLocationCoordinate2D(latitude: 18.0, longitude: -94.5)
        case "Moche Civilization": return CLLocationCoordinate2D(latitude: -8.1, longitude: -79.0)
        case "Toltec Civilization": return CLLocationCoordinate2D(latitude: 20.0, longitude: -99.2)
        case "Nazca Civilization": return CLLocationCoordinate2D(latitude: -14.8, longitude: -75.1)

        // OCEANIA
        case "Ancient Polynesia": return CLLocationCoordinate2D(latitude: -17.5, longitude: -149.5)
        case "Rapa Nui": return CLLocationCoordinate2D(latitude: -27.1, longitude: -109.3)
        case "Aboriginal Cultures": return CLLocationCoordinate2D(latitude: -25.0, longitude: 133.0)

        // FALLBACK
        case "Ancient Mesopotamia": return CLLocationCoordinate2D(latitude: 33.3, longitude: 44.4)
        case "Ancient China": return CLLocationCoordinate2D(latitude: 35.0, longitude: 105.0)
        default:
            // If not found, return Middle East as default
            return CLLocationCoordinate2D(latitude: 30.0, longitude: 35.0)
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
        case languageCode = "language_code"
        case createdAt = "created_at"
    }

    init(id: UUID = UUID(), name: String, eraStart: String, eraEnd: String, region: String, description: String, languageCode: String = "en", createdAt: Date? = nil) {
        self.id = id
        self.name = name
        self.eraStart = eraStart
        self.eraEnd = eraEnd
        self.region = region
        self.description = description
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

        name = try container.decode(String.self, forKey: .name)
        eraStart = try container.decode(String.self, forKey: .eraStart)
        eraEnd = try container.decode(String.self, forKey: .eraEnd)
        region = try container.decode(String.self, forKey: .region)
        description = try container.decode(String.self, forKey: .description)
        languageCode = try container.decodeIfPresent(String.self, forKey: .languageCode) ?? "en"

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
