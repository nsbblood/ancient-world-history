//
//  StoryCollection.swift
//  Ancient World Stories
//

import Foundation

struct StoryCollection: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let colorHex: String
    let storyIds: [UUID]
}
