//
//  PaywallView.swift
//  Ancient World Stories
//
//  Premium subscription paywall with RevenueCat integration
//  Single-screen, non-scrollable layout with parchment aesthetic
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Binding var isPresented: Bool

    @State private var selectedPlan: String = "$rc_annual" // Default to yearly
    @State private var isProcessing = false
    @State private var offerings: Offerings?
    @State private var errorMessage: String?
    
    // Helper to find packages from any available offering
    private var yearlyPackage: Package? {
        guard let offerings = offerings else { return nil }
        if let current = offerings.current,
           let package = current.package(identifier: "$rc_annual") {
            return package
        }
        // Try alternative offerings
        for offering in offerings.all.values {
            if let package = offering.package(identifier: "$rc_annual") {
                return package
            }
        }
        return nil
    }
    
    private var weeklyPackage: Package? {
        guard let offerings = offerings else { return nil }
        if let current = offerings.current,
           let package = current.package(identifier: "$rc_weekly") {
            return package
        }
        // Try alternative offerings
        for offering in offerings.all.values {
            if let package = offering.package(identifier: "$rc_weekly") {
                return package
            }
        }
        return nil
    }
    
    // Computed property for button text
    private var buttonText: String {
        selectedPlan == "$rc_annual" ? "Continue" : "Try Free"
    }
    
    // Computed property for trial info
    private var trialInfo: String {
        if selectedPlan == "$rc_annual" {
            if let package = yearlyPackage {
                return "Then \(package.storeProduct.localizedPriceString)/year"
            }
            return "Then $39.99/year"
        } else {
            if let package = weeklyPackage {
                return "3-day free trial, then \(package.storeProduct.localizedPriceString)/week"
            }
            return "3-day free trial, then $4.99/week"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Warm parchment background (matching app theme)
                Color.appBackground
                    .ignoresSafeArea()

                // Subtle papyrus texture overlay
                LinearGradient(
                    colors: [
                        Color.appSecondary.opacity(0.3),
                        Color.appBackground,
                        Color.appSecondary.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Golden light rays overlay (subtle)
                RadialGradient(
                    colors: [
                        Color.appAccent.opacity(0.15),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 50,
                    endRadius: 400
                )
                .ignoresSafeArea()
                .onAppear {
                    // Try to get cached offerings immediately on appear
                    loadCachedOfferingsIfAvailable()
                }
                
                VStack(spacing: 0) {
                    // Top bar: Close button only
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appText.opacity(0.7))
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.appText.opacity(0.08))
                                )
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Spacer(minLength: 0)

                    // Header with crown icon and radial glow (more compact)
                    VStack(spacing: 8) {
                        ZStack {
                            // Warm glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.appAccent.opacity(0.3),
                                            Color.appAccent.opacity(0.1),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 8,
                                        endRadius: 50
                                    )
                                )
                                .frame(width: 100, height: 100)

                            // Bronze/gold crown
                            Image(systemName: "crown.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "D4AF37"), // Deep gold
                                            Color.appAccent,
                                            Color(hex: "8B6914")  // Dark gold
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.appAccent.opacity(0.4), radius: 10, x: 0, y: 4)
                        }

                        Text("Unlock the Ancient World")
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(.appText)
                            .multilineTextAlignment(.center)

                        Text("Journey through time. Experience every civilization.")
                            .font(.system(size: 13, weight: .medium, design: .serif))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    Spacer(minLength: 0)

                    // Features (more compact, only 3 features)
                    VStack(spacing: 10) {
                        VibrantFeature(icon: "scroll.fill", title: "100+ Epic Stories", description: "From pharaohs to emperors")
                        VibrantFeature(icon: "waveform", title: "Immersive Audio", description: "Professional narration")
                        VibrantFeature(icon: "globe.americas.fill", title: "15+ Civilizations", description: "Across time and space")
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 0)

                    // Subscription Plans (more compact)
                    if yearlyPackage != nil || weeklyPackage != nil {
                        VStack(spacing: 10) {
                            // Yearly Plan
                            if let yearly = yearlyPackage {
                                SubscriptionCard(
                                    package: yearly,
                                    isSelected: selectedPlan == "$rc_annual",
                                    showBadge: true,
                                    onSelect: { selectedPlan = "$rc_annual" }
                                )
                            }

                            // Weekly Plan
                            if let weekly = weeklyPackage {
                                SubscriptionCard(
                                    package: weekly,
                                    isSelected: selectedPlan == "$rc_weekly",
                                    showBadge: false,
                                    onSelect: { selectedPlan = "$rc_weekly" }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // Loading or Error state
                        VStack(spacing: 16) {
                            if let error = errorMessage {
                                // Error state
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red.opacity(0.8))

                                Text("Unable to load subscriptions")
                                    .font(.system(size: 16, weight: .semibold, design: .serif))
                                    .foregroundColor(.appText)

                                Text(error)
                                    .font(.system(size: 12, design: .serif))
                                    .foregroundColor(.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)

                                Button {
                                    errorMessage = nil
                                    fetchOfferings()
                                } label: {
                                    Text("Retry")
                                        .font(.system(size: 14, weight: .semibold, design: .serif))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 10)
                                        .background(Color.appAccent)
                                        .cornerRadius(8)
                                }
                            } else {
                                // Loading state
                                ProgressView()
                                    .tint(.appAccent)

                                Text("Loading subscription options...")
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(.secondaryText)
                            }
                        }
                        .frame(height: 150)
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 0)

                    // Subscribe Button (more compact)
                    Button(action: subscribe) {
                        HStack(spacing: 8) {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text(buttonText)
                                    .font(.system(size: 18, weight: .bold, design: .serif))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "D4AF37"), // Deep gold
                                    Color.appAccent,
                                    Color(hex: "8B6914")  // Dark gold
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.appAccent.opacity(0.4), radius: 12, x: 0, y: 4)
                        .opacity((yearlyPackage != nil || weeklyPackage != nil) ? 1.0 : 0.5)
                    }
                    .disabled(isProcessing || (yearlyPackage == nil && weeklyPackage == nil))
                    .padding(.horizontal, 20)

                    // Trial info
                    Text(trialInfo)
                        .font(.system(size: 11, weight: .medium, design: .serif))
                        .foregroundColor(.secondaryText)
                        .padding(.top, 6)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    // Legal links
                    HStack(spacing: 16) {
                        Button("Terms") {
                            if let url = URL(string: "https://dainty.app/terms") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(.secondaryText)

                        Button("Privacy") {
                            if let url = URL(string: "https://dainty.app/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(.secondaryText)

                        Button("Restore") {
                            restorePurchases()
                        }
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(.secondaryText)
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    // MARK: - RevenueCat Methods

    // Try to load cached offerings immediately for instant display
    private func loadCachedOfferingsIfAvailable() {
        // Check if RevenueCat is configured
        guard Purchases.isConfigured else {
            print("❌ RevenueCat is not configured!")
            errorMessage = "RevenueCat is not initialized. Please restart the app."
            return
        }

        // Try to fetch offerings - RevenueCat will use cache if available
        Task {
            do {
                let offerings = try await Purchases.shared.offerings()

                await MainActor.run {
                    self.offerings = offerings
                    print("✅ Offerings loaded (from cache or network)")

                    if let current = offerings.current {
                        print("   Current offering: \(current.identifier)")
                        print("   Available packages: \(current.availablePackages.map { $0.identifier })")

                        let foundYearlyPackage = current.package(identifier: "$rc_annual")
                        let foundWeeklyPackage = current.package(identifier: "$rc_weekly")

                        if foundYearlyPackage == nil && foundWeeklyPackage == nil {
                            self.errorMessage = "No subscription packages found. Please check RevenueCat Dashboard."
                        }
                    } else if offerings.all.values.first == nil {
                        self.errorMessage = "No subscription offerings configured in RevenueCat Dashboard."
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load subscriptions: \(error.localizedDescription)"
                    print("❌ RevenueCat error: \(error)")
                }
            }
        }
    }

    private func fetchOfferings() {
        print("🔄 Fetching RevenueCat offerings...")
        
        // Check if RevenueCat is configured
        guard Purchases.isConfigured else {
            print("❌ RevenueCat is not configured!")
            errorMessage = "RevenueCat is not initialized. Please restart the app."
            return
        }
        
        print("✅ RevenueCat is configured")
        
        Task {
            do {
                let offerings = try await Purchases.shared.offerings()
                
                await MainActor.run {
                    print("📦 Offerings received:")
                    print("   - All offerings: \(offerings.all.keys.joined(separator: ", "))")
                    
                    self.offerings = offerings
                    
                    if let current = offerings.current {
                        print("✅ Current offering: \(current.identifier)")
                        print("   Available packages: \(current.availablePackages.map { $0.identifier })")
                        print("   Package count: \(current.availablePackages.count)")
                        
                        // Check for specific packages
                        let foundYearlyPackage = current.package(identifier: "$rc_annual")
                        let foundWeeklyPackage = current.package(identifier: "$rc_weekly")
                        
                        if foundYearlyPackage == nil {
                            print("⚠️ Yearly package (ancient.year) not found!")
                        } else {
                            print("✅ Yearly package found: \(foundYearlyPackage!.storeProduct.localizedTitle) - \(foundYearlyPackage!.storeProduct.localizedPriceString)")
                        }
                        
                        if foundWeeklyPackage == nil {
                            print("⚠️ Weekly package (ancient.week) not found!")
                        } else {
                            print("✅ Weekly package found: \(foundWeeklyPackage!.storeProduct.localizedTitle) - \(foundWeeklyPackage!.storeProduct.localizedPriceString)")
                        }
                        
                        // If no packages found, show helpful error
                        if foundYearlyPackage == nil && foundWeeklyPackage == nil {
                            self.errorMessage = "No subscription packages found. Please check RevenueCat Dashboard:\n1. Ensure offerings are created\n2. Ensure packages 'ancient.year' and 'ancient.week' are added to the offering\n3. Ensure products are synced from App Store Connect"
                        }
                    } else {
                        print("⚠️ No current offering found")
                        print("   Available offerings: \(offerings.all.keys.joined(separator: ", "))")
                        
                        // Try to use the first available offering if any exist
                        if let firstOffering = offerings.all.values.first {
                            print("🔄 Found alternative offering: \(firstOffering.identifier)")
                            print("   Packages: \(firstOffering.availablePackages.map { $0.identifier })")
                            
                            // Check if this offering has our packages
                            let foundYearlyPackage = firstOffering.package(identifier: "$rc_annual")
                            let foundWeeklyPackage = firstOffering.package(identifier: "$rc_weekly")
                            
                            if foundYearlyPackage != nil || foundWeeklyPackage != nil {
                                // We found packages in an alternative offering, use them
                                print("✅ Found packages in alternative offering: \(firstOffering.identifier)")
                                // Clear error message since we can use these packages
                                self.errorMessage = nil
                            } else {
                                self.errorMessage = "No subscription offerings configured in RevenueCat Dashboard.\n\nPlease:\n1. Go to RevenueCat Dashboard\n2. Create an offering (identifier: 'default')\n3. Add packages 'ancient.year' and 'ancient.week'\n4. Ensure products are synced from App Store Connect"
                            }
                        } else {
                            self.errorMessage = "No subscription offerings configured in RevenueCat Dashboard.\n\nPlease:\n1. Go to RevenueCat Dashboard\n2. Create an offering (identifier: 'default')\n3. Add packages 'ancient.year' and 'ancient.week'\n4. Ensure products are synced from App Store Connect"
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    let errorDescription = error.localizedDescription
                    self.errorMessage = "Failed to load subscriptions: \(errorDescription)\n\nPlease check:\n1. Internet connection\n2. RevenueCat Dashboard configuration\n3. App Store Connect products"
                    print("❌ RevenueCat error: \(error)")
                    print("   Error type: \(type(of: error))")
                    print("   Error details: \(error)")
                    
                    if let rcError = error as? ErrorCode {
                        print("   RevenueCat error code: \(rcError)")
                    }
                }
            }
        }
    }
    
    private func subscribe() {
        let package: Package?
        if selectedPlan == "$rc_annual" {
            package = yearlyPackage
        } else {
            package = weeklyPackage
        }
        
        guard let package = package else {
            errorMessage = "Unable to load subscription options. Please try again."
            return
        }

        isProcessing = true

        Task {
            do {
                let (_, customerInfo, _) = try await Purchases.shared.purchase(package: package)

                await MainActor.run {
                    isProcessing = false
                    let hasPremium = customerInfo.entitlements["premium"]?.isActive == true
                    print("✅ Purchase successful - Premium: \(hasPremium)")

                    if hasPremium {
                        ProfileManager.shared.isPremium = true
                        Task {
                            await ProfileManager.shared.checkPremiumStatus()
                        }
                        isPresented = false
                    } else {
                        errorMessage = "Purchase completed but premium not activated"
                        print("❌ Premium entitlement not active after purchase")
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    print("❌ Purchase error: \(error)")
                }
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.restorePurchases()
                let hasPremium = customerInfo.entitlements["premium"]?.isActive == true

                await MainActor.run {
                    if hasPremium {
                        ProfileManager.shared.isPremium = true
                        Task {
                            await ProfileManager.shared.checkPremiumStatus()
                        }
                        isPresented = false
                        print("✅ Purchases restored successfully")
                    } else {
                        errorMessage = "No active subscriptions found"
                        print("⚠️ No active premium subscription found")
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
                print("❌ Restore error: \(error)")
            }
        }
    }
}

// MARK: - Vibrant Feature Row
struct VibrantFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appAccent.opacity(0.25),
                                Color.appAccent.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appAccent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(.appText)

                Text(description)
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(.secondaryText)
            }

            Spacer()
        }
    }
}

// MARK: - Subscription Card (RevenueCat)
struct SubscriptionCard: View {
    let package: Package
    let isSelected: Bool
    let showBadge: Bool
    let onSelect: () -> Void

    private var isWeekly: Bool {
        package.storeProduct.subscriptionPeriod?.unit == .week
    }

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(package.storeProduct.localizedTitle)
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundColor(.appText)

                        if showBadge {
                            Text("BEST VALUE")
                                .font(.system(size: 9, weight: .black, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "D4AF37"),
                                                    Color.appAccent
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        } else if isWeekly {
                            Text("3-DAY TRIAL")
                                .font(.system(size: 9, weight: .black, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                    }

                    Text(package.storeProduct.subscriptionPeriod?.unit == .year ? "Save 85% • Full Access" : "3 days free, then weekly")
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(.secondaryText)
                }

                Spacer()

                Text(package.storeProduct.localizedPriceString)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.appAccent)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected ? Color.white : Color.white.opacity(0.6)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ?
                        LinearGradient(
                            colors: [
                                Color(hex: "D4AF37"),
                                Color.appAccent
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.appText.opacity(0.2), Color.appText.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? Color.appAccent.opacity(0.3) : Color.appText.opacity(0.1), radius: isSelected ? 10 : 4, x: 0, y: 3)
        }
    }
}

// MARK: - Preview
#Preview {
    // Configure RevenueCat for preview
    let _ = {
        if !Purchases.isConfigured {
            Purchases.logLevel = .debug
            Purchases.configure(withAPIKey: "appl_QugKNOckInPdncYbLMcQxYPdvtm")
        }
    }()

    return PaywallView(isPresented: .constant(true))
}
