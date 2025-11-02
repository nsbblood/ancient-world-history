// CivilizationsView.swift
import SwiftUI

struct CivilizationsView: View {
    @StateObject private var content = ContentLoader.shared
    @State private var selectedCivilization: Civilization?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Explore Ancient Civilizations")
                            .font(.serifTitle())
                            .foregroundColor(.primaryText)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        if content.isLoading {
                            ProgressView().tint(.accentColor)
                                .frame(maxWidth: .infinity).padding(.vertical, 40)
                        } else {
                            ForEach(content.civilizations) { civ in
                                Button {
                                    selectedCivilization = civ
                                } label: {
                                    CivilizationCard(
                                        civilization: civ,
                                        storyCount: content.storyCount(for: civ.id)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationDestination(item: $selectedCivilization) { civ in
                StoriesView(civilization: civ)
            }
        }
    }
}
