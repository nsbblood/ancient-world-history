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
    init() {
        configureRevenueCat()
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func configureRevenueCat() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_QugKNOckInPdncYbLMcQxYPdvtm")

        // Check premium status on app launch
        Task { @MainActor in
            await ProfileManager.shared.checkPremiumStatus()
        }
    }

    private func configureAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(Color.appBackground)
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.primaryText),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.primaryText),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.cardBackground)

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        UITabBar.appearance().tintColor = UIColor(Color.accentColor)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.secondaryText)
    }
}

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    @State private var showSplash = true

    var body: some View {
        ZStack {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else {
                    mainTabView
                }
            }
            .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "book.fill")
                }
                .tag(0)

            CivilizationsView()
                .tabItem {
                    Label("Episodes", systemImage: "list.bullet")
                }
                .tag(1)

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "map.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.accentColor)
    }

}

// MARK: - Splash View
struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.appAccent.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)

                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "D4AF37"),
                                    Color.appAccent,
                                    Color(hex: "8B6914")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(scale)

                Text("Ancient World Stories")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.appText)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                opacity = 1.0
            }
        }
    }
}

#Preview {
    ContentView()
}
