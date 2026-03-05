//
//  AudioManager.swift
//  Ancient World Stories
//
//  Created by Claude Code
//

import SwiftUI
import Combine

@MainActor
class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()

    @Published var isPlaying = false
    @Published var currentProgress: Double = 0.0

    private override init() {
        super.init()
    }

    func pause() {
        isPlaying = false
    }

    func resume() {
        isPlaying = true
    }

    func stop() {
        isPlaying = false
        currentProgress = 0.0
    }
}
