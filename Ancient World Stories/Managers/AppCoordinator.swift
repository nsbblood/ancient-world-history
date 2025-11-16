import SwiftUI
import Combine
import RevenueCat

@MainActor
class AppCoordinator: ObservableObject {
    @Published var isDataLoaded = false
    
    private let contentLoader = ContentLoader.shared
    private let profileManager = ProfileManager.shared
    
    func startInitialization() async {
        print("🚀 Starting app initialization...")

        // Configure UI Appearance first - this is synchronous and fast
        configureAppearance()

        // Initialize ProfileManager and load its local data
        profileManager.loadInitialDataIfNeeded()

        // FAST PATH: Only load essential data for quick launch
        contentLoader.loadInitialData()

        // Show UI immediately after essential data is loaded
        withAnimation {
            isDataLoaded = true
            print("✨ App ready - showing UI (\(contentLoader.civilizations.count) civs loaded)")
        }

        // BACKGROUND: Configure RevenueCat and load remaining data
        Task.detached(priority: .background) { [weak self] in
            await self?.configureRevenueCat()
            await self?.profileManager.checkPremiumStatus()
        }
    }
    
    private func configureRevenueCat() async {
        if Purchases.isConfigured {
            print("⚠️ RevenueCat already configured, skipping setup...")
            return
        }

        print("🔧 Configuring RevenueCat...")
        Purchases.configure(withAPIKey: "appl_QugKNOckInPdncYbLMcQxYPdvtm")
        print("✅ RevenueCat configured successfully")

        // Pre-fetch offerings in background - don't block if it fails
        Task.detached(priority: .utility) {
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
