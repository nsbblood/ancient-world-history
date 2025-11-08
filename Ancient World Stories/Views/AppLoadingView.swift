//
//  AppLoadingView.swift
//  Ancient World Stories
//
//  Created by Enes Arıkan on 8.11.2025.
//

import SwiftUI
import RevenueCat

struct AppLoadingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    @State private var profileManager: ProfileManager?
    @State private var showLoading = true
    @State private var loadingProgress: CGFloat = 0

    var body: some View {
        ZStack {
            // Main content - show immediately after LaunchScreen
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else {
                    mainTabView
                }
            }

            // Minimal loading bar at bottom - only while loading
            if showLoading {
                VStack {
                    Spacer()

                    // Simple progress bar at bottom
                    VStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 4)

                                // Progress fill
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.831, green: 0.686, blue: 0.216),
                                                Color(red: 0.545, green: 0.412, blue: 0.078)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * loadingProgress, height: 4)
                            }
                        }
                        .frame(height: 4)

                        Text("Loading...")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                }
                .transition(.opacity)
            }
        }
        .task {
            await initializeWithAnimation()
        }
    }

    private func initializeWithAnimation() async {
        // Record start time for minimum display duration
        let startTime = Date()

        // Start animating progress immediately
        Task {
            await animateProgress()
        }

        // Initialize essentials
        await initializeEssentials()

        // Make sure progress reaches 100%
        loadingProgress = 1.0

        // Ensure minimum display time of 0.5 seconds (so progress bar is visible)
        let elapsed = Date().timeIntervalSince(startTime)
        let minimumDuration: TimeInterval = 0.5
        if elapsed < minimumDuration {
            let remaining = minimumDuration - elapsed
            try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
        }

        // Small delay to show completion
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s

        // Hide loading screen
        withAnimation(.easeOut(duration: 0.5)) {
            showLoading = false
        }
    }

    private func animateProgress() async {
        // Smooth progress animation
        let steps = 30
        for i in 0...steps {
            loadingProgress = CGFloat(i) / CGFloat(steps)
            try? await Task.sleep(nanoseconds: 30_000_000) // 30ms per step = smooth animation
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            LazyView(HomeView())
                .tabItem {
                    Label("Home", systemImage: "book.fill")
                }
                .tag(0)

            LazyView(CivilizationsView())
                .tabItem {
                    Label("Episodes", systemImage: "list.bullet")
                }
                .tag(1)

            LazyView(ExploreView())
                .tabItem {
                    Label("Explore", systemImage: "map.fill")
                }
                .tag(2)

            LazyView(ProfileView())
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.accentColor)
    }

    private func initializeEssentials() async {
        print("🚀 Starting minimal initialization...")

        // ONLY initialize ProfileManager - fast, local only
        let manager = ProfileManager.shared
        manager.loadInitialDataIfNeeded()
        self.profileManager = manager

        // Configure RevenueCat in background - don't wait for it
        Task.detached {
            await MainActor.run {
                Task {
                    await self.configureRevenueCat()
                    await manager.checkPremiumStatus()
                }
            }
        }

        print("✨ Essential initialization complete - UI ready!")
    }

    private func configureRevenueCat() async {
        if Purchases.isConfigured {
            print("⚠️ RevenueCat already configured, skipping setup...")
            return
        }

        print("🔧 Configuring RevenueCat...")
        Purchases.configure(withAPIKey: "appl_QugKNOckInPdncYbLMcQxYPdvtm")
        print("✅ RevenueCat configured successfully")

        do {
            let offerings = try await Purchases.shared.offerings()
            print("✅ Offerings pre-fetched: \(offerings.current?.identifier ?? "none")")
            if let current = offerings.current {
                print("   Packages: \(current.availablePackages.map { $0.identifier })")
            }
        } catch {
            print("⚠️ Failed to pre-fetch offerings: \(error)")
        }
    }
}

// MARK: - LazyView for performance optimization
struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
