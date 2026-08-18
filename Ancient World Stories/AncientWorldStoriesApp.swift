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
    @StateObject private var contentLoader = ContentLoader.shared
    @ObservedObject private var profileManager = ProfileManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0

    init() {
        configureAppearance()

        // RevenueCat must be configured before paywall / premium checks
        if !Purchases.isConfigured {
            Purchases.configure(withAPIKey: "appl_QugKNOckInPdncYbLMcQxYPdvtm")
            print("✅ RevenueCat configured")
        }

        print("✅ App init completed - showing UI immediately")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else if let error = contentLoader.error,
                          contentLoader.civilizations.isEmpty || contentLoader.chapters.isEmpty {
                    errorScreen(message: error)
                } else if contentLoader.civilizations.isEmpty || contentLoader.chapters.isEmpty {
                    loadingScreen
                } else {
                    mainTabView
                }
            }
            .task {
                profileManager.loadInitialDataIfNeeded()
                contentLoader.loadInitialData()
                await profileManager.checkPremiumStatus()
                profileManager.startObservingEntitlements()
            }
            .onChange(of: scenePhase) { _, newPhase in
                // A subscription can lapse or be cancelled while the app is backgrounded.
                guard newPhase == .active else { return }
                Task { await profileManager.checkPremiumStatus() }
            }
        }
    }

    private var loadingScreen: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.appAccent)

                ProgressView()
                    .tint(.appAccent)
                    .scaleEffect(1.2)

                Text("Loading your stories...")
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(.appText.opacity(0.7))
            }
        }
    }

    private func errorScreen(message: String) -> some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.appAccent)

                Text("Unable to load stories")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(.appText)

                Text(message)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.appText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button("retry".localized) {
                    contentLoader.reload()
                }
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(.black)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(Color.appAccent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
                    Label("tab.episodes".localized, systemImage: "list.bullet")
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
