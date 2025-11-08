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
        
        // Load remote data and configure RevenueCat concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.contentLoader.loadAllData()
            }
            
            group.addTask {
                await self.configureRevenueCat()
                await self.profileManager.checkPremiumStatus()
            }
        }
        
        // Add a small delay to ensure the splash screen is visible for a minimum duration
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        withAnimation {
            isDataLoaded = true
            print("✨ Splash complete, showing main app")
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
