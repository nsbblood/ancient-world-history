//
//  AncientWorldStoriesApp.swift
//  Ancient World Stories Universe
//
//  Created by Claude Code
//

import SwiftUI
import RevenueCat

@main
struct AncientWorldStoriesApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0

    init() {
        // Configure UI appearance first (fast, synchronous)
        configureAppearance()

        // Run RevenueCat in BACKGROUND THREAD (non-blocking)
        Task.detached {
            if !Purchases.isConfigured {
                Purchases.configure(withAPIKey: "appl_QugKNOckInPdncYbLMcQxYPdvtm")
                print("✅ RevenueCat configured in background")
            }
        }

        // ProfileManager doesn't need to wait - it's lightweight now
        print("✅ App init completed - showing UI immediately")
    }

    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else {
                mainTabView
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("tab.home".localized, systemImage: "book.fill")
                }
                .tag(0)

            CivilizationsView()
                .tabItem {
                    Label("Episodes", systemImage: "list.bullet")
                }
                .tag(1)

            ExploreView()
                .tabItem {
                    Label("tab.explore".localized, systemImage: "map.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("tab.profile".localized, systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.accentColor)
    }

    private func configureAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(red: 0.102, green: 0.110, blue: 0.129, alpha: 1.0)
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(red: 0.129, green: 0.133, blue: 0.153, alpha: 1.0)

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        UITabBar.appearance().tintColor = UIColor(red: 0.831, green: 0.686, blue: 0.216, alpha: 1.0)
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 0.588, green: 0.608, blue: 0.655, alpha: 1.0)
    }
}

#Preview {
    OnboardingView()
}

