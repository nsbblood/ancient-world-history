//
//  VoiceSelectorView.swift
//  Ancient World Stories
//
//  Voice selection for TTS (System vs Neural AI)
//

import SwiftUI

// DEPRECATED: Voice selection removed - all users use default voice for caching
// This view is kept for backwards compatibility but not used
struct VoiceSelectorView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack {
                    Text("Voice selection is no longer available")
                        .font(.serifBody())
                        .foregroundColor(.secondaryText)
                        .padding()
                }
            }
            .navigationTitle("Voice Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.serifBody())
                    .foregroundColor(.appAccent)
                }
            }
        }
    }
}

#Preview {
    VoiceSelectorView()
}
