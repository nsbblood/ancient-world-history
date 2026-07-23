//
//  ExploreView.swift
//  Ancient World Stories
//
//  Interactive map showing ancient civilizations with timeline filtering
//

import SwiftUI
import MapKit

// Helper function to extract region from MapCameraPosition
private func extractRegionFromPosition(_ position: MapCameraPosition) -> MKCoordinateRegion? {
    // Use Mirror to extract the associated value from the enum case
    let mirror = Mirror(reflecting: position)

    // Check if this is a region case and extract its value
    if let child = mirror.children.first,
       let region = child.value as? MKCoordinateRegion {
        return region
    }

    return nil
}

struct ExploreView: View {
    @StateObject private var contentLoader = ContentLoader.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var selectedCivilization: Civilization?
    @State private var showStoriesSheet = false
    @State private var timelineYear: Double = -500 // Start at 500 BC to show more civilizations
    @State private var showTimeTravel = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35, longitude: 25),
            span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 80)
        )
    )
    @State private var mapZoomLevel: Double = 1.0 // For tracking zoom level

    // Dynamic map style based on timeline - more ancient = more artistic/drawn look
    private var mapStyle: MapStyle {
        let year = Int(timelineYear)

        // Very ancient times (before 2000 BC) - Satellite imagery for ancient feel
        if year < -2000 {
            return .imagery(elevation: .flat)
        }
        // Ancient times (2000 BC to 500 BC) - Hybrid for historical context
        else if year < -500 {
            return .hybrid(elevation: .flat)
        }
        // Classical period onwards - Standard clean map
        else {
            return .standard(elevation: .flat)
        }
    }
    
    // Filter civilizations based on timeline
    private var filteredCivilizations: [Civilization] {
        contentLoader.filteredCivilizations.filter { civilization in
            let year = Int(timelineYear)
            return civilization.startYear <= year && civilization.endYear >= year
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Map with dynamic style based on timeline
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
            .mapStyle(mapStyle)
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
                MapPitchToggle()
            }
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                // Zoom controls
                VStack(spacing: 12) {
                    Button {
                        zoomIn()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.white, .black.opacity(0.6))
                            .shadow(color: .black.opacity(0.3), radius: 4)
                    }

                    Button {
                        zoomOut()
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.white, .black.opacity(0.6))
                            .shadow(color: .black.opacity(0.3), radius: 4)
                    }
                }
                .padding(.top, 60)
                .padding(.trailing, 16)
            }
            
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
                        selectedCivilization = contentLoader.filteredCivilizations.randomElement()
                        showTimeTravel = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 18))
                            Text("explore.time_travel".localized)
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

    // MARK: - Zoom Functions
    private func zoomIn() {
        // Get current region, if available
        guard let region = getCurrentRegion() else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            let newSpan = MKCoordinateSpan(
                latitudeDelta: max(region.span.latitudeDelta * 0.5, 5),
                longitudeDelta: max(region.span.longitudeDelta * 0.5, 5)
            )
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: region.center,
                    span: newSpan
                )
            )
            mapZoomLevel = min(mapZoomLevel * 2, 10)
        }
    }

    private func zoomOut() {
        // Get current region, if available
        guard let region = getCurrentRegion() else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            let newSpan = MKCoordinateSpan(
                latitudeDelta: min(region.span.latitudeDelta * 2, 180),
                longitudeDelta: min(region.span.longitudeDelta * 2, 180)
            )
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: region.center,
                    span: newSpan
                )
            )
            mapZoomLevel = max(mapZoomLevel * 0.5, 0.1)
        }
    }

    // Helper function to get current region from camera position
    private func getCurrentRegion() -> MKCoordinateRegion? {
        return extractRegionFromPosition(cameraPosition)
    }
}

// MARK: - Civilization Marker
struct CivilizationMarker: View {
    let civilization: Civilization

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)

                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)

                Image(systemName: "building.columns.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }

            // Better contrast for text
            Text(civilization.name.components(separatedBy: " ").last ?? civilization.name)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.75))
                        .shadow(color: .black.opacity(0.3), radius: 2)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
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
                    Text("explore.timeline".localized)
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
    @ObservedObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss

    private var stories: [Story] {
        contentLoader.stories(for: civilization.id)
    }

    var body: some View {
        ZStack {
            // App theme background
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with better spacing and theme colors
                    VStack(alignment: .leading, spacing: 16) {
                        // Civilization name with decorative line
                        VStack(alignment: .leading, spacing: 8) {
                            Text(civilization.name)
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .foregroundColor(.appText)

                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.appAccent, .appAccent.opacity(0.3), .clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 3)
                                .frame(maxWidth: 200)
                        }

                        // Region and Era in themed cards
                        HStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.appAccent)
                                Text(civilization.region)
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(.appText.opacity(0.85))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.appSecondary.opacity(0.3))
                            )

                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.appAccent)
                                Text(civilization.eraDisplay)
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(.appText.opacity(0.85))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.appSecondary.opacity(0.3))
                            )
                        }

                        // Description
                        Text(civilization.description)
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(.appText.opacity(0.75))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appSecondary.opacity(0.15))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)

                    // Stories Section with better styling
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("explore.stories".localized)
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(.appText)

                            Spacer()

                            // Story count badge
                            Text("\(stories.count)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.appAccent, Color(hex: "8B6914")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: .appAccent.opacity(0.3), radius: 4)
                                )
                        }
                        .padding(.horizontal)

                        if stories.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 50))
                                    .foregroundColor(.appAccent.opacity(0.5))

                                Text("explore.no_stories".localized)
                                    .font(.system(size: 20, weight: .semibold, design: .serif))
                                    .foregroundColor(.appText)

                                Text("explore.coming_soon".localized)
                                    .font(.system(size: 16, design: .serif))
                                    .foregroundColor(.appText.opacity(0.65))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            ForEach(stories) { story in
                                NavigationLink(destination: ChaptersView(story: story, civilization: civilization)) {
                                    StoryCard(story: story, civilization: civilization)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.appSecondary.opacity(0.3))
                            .frame(width: 36, height: 36)

                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appText)
                    }
                }
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
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

                Text("explore.no_civilizations".localized)
                    .font(.serifTitle2())
                    .foregroundColor(.appText)

                Text("explore.check_back".localized)
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
