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
    // Remove @StateObject to prevent early initialization
    // ContentLoader will be accessed directly when needed
    @State private var profileManager: ProfileManager?

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                // Show onboarding immediately - it will load data itself
                OnboardingView()
            } else {
                // Show main UI immediately - tabs will load data as needed
                mainTabView
            }
        }
        .task {
            // Only initialize essentials - NO network calls!
            await initializeEssentials()
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
