//
//  ExploreView.swift
//  Ancient World Stories
//
//  Interactive map showing ancient civilizations with timeline filtering
//

import SwiftUI
import MapKit

struct ExploreView: View {
    @StateObject private var contentLoader = ContentLoader.shared
    @State private var selectedCivilization: Civilization?
    @State private var showStoriesSheet = false
    @State private var timelineYear: Double = -3000
    @State private var showTimeTravel = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35, longitude: 25),
            span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 80)
        )
    )
    
    // Filter civilizations based on timeline
    private var filteredCivilizations: [Civilization] {
        contentLoader.civilizations.filter { civilization in
            let year = Int(timelineYear)
            return civilization.startYear <= year && civilization.endYear >= year
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Map
            Map(position: $cameraPosition) {
                ForEach(filteredCivilizations) { civilization in
                    Annotation(civilization.name, coordinate: civilization.coordinate) {
                        CivilizationMarker(civilization: civilization)
                            .onTapGesture {
                                selectedCivilization = civilization
                                showStoriesSheet = true
                            }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            
            // Timeline Slider Overlay
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    TimelineSlider(
                        year: $timelineYear,
                        filteredCount: filteredCivilizations.count
                    )
                    .padding(.horizontal, 20)

                    Button {
                        selectedCivilization = contentLoader.civilizations.randomElement()
                        showTimeTravel = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 18))
                            Text("Zaman Yolculuğu")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showStoriesSheet) {
            if let civilization = selectedCivilization {
                CivilizationDetailSheet(civilization: civilization)
            } else {
                EmptyCivilizationSheet(onDismiss: { showStoriesSheet = false })
            }
        }
        .sheet(isPresented: $showTimeTravel) {
            if let civilization = selectedCivilization {
                CivilizationDetailSheet(civilization: civilization)
            } else {
                EmptyCivilizationSheet(onDismiss: { showTimeTravel = false })
            }
        }
    }
}

// MARK: - Civilization Marker
struct CivilizationMarker: View {
    let civilization: Civilization
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            
            Text(civilization.name.components(separatedBy: " ").last ?? "")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                )
        }
    }
}

// MARK: - Timeline Slider
struct TimelineSlider: View {
    @Binding var year: Double
    let filteredCount: Int
    
    private var yearDisplay: String {
        let yearInt = Int(year)
        if yearInt < 0 {
            return "\(abs(yearInt)) BC"
        } else {
            return "\(yearInt) AD"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Year Display
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Timeline")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(yearDisplay)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Civilization Count Badge
                HStack(spacing: 6) {
                    Image(systemName: "building.columns.fill")
                        .font(.caption)
                    
                    Text("\(filteredCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            
            // Slider
            Slider(value: $year, in: -3500...1800, step: 100)
                .tint(.orange)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
        )
    }
}

// MARK: - Civilization Detail Sheet
struct CivilizationDetailSheet: View {
    let civilization: Civilization
    @StateObject private var contentLoader = ContentLoader.shared
    @Environment(\.dismiss) private var dismiss
    
    private var stories: [Story] {
        contentLoader.stories(for: civilization.id)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(civilization.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label(civilization.region, systemImage: "mappin.circle.fill")
                            Spacer()
                            Label(civilization.eraDisplay, systemImage: "clock.fill")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Text(civilization.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    
                    // Stories Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Stories")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("\(stories.count)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange, .red],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                        
                        if stories.isEmpty {
                            ContentUnavailableView(
                                "No Stories Yet",
                                systemImage: "book.closed",
                                description: Text("Stories for this civilization are coming soon.")
                            )
                            .padding(.vertical, 40)
                        } else {
                            ForEach(stories) { story in
                                NavigationLink(destination: ChaptersView(story: story, civilization: civilization)) {
                                    StoryCard(story: story, civilization: civilization)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.appAccent)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .background(Color.appBackground)
        }
    }
}


// MARK: - Empty Civilization Sheet
struct EmptyCivilizationSheet: View {
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "map")
                    .font(.system(size: 60))
                    .foregroundColor(.appAccent)

                Text("No Civilizations Found")
                    .font(.serifTitle2())
                    .foregroundColor(.appText)

                Text("Please check back later for ancient civilizations to explore.")
                    .font(.serifBody())
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.appAccent)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ExploreView()
}
