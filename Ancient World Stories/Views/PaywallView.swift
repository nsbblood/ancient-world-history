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

    @State private var selectedPlan: String = "$rc_annual"
    @State private var isProcessing = false
    @State private var offerings: Offerings?
    @State private var errorMessage: String?
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
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
        selectedPlan == "$rc_annual" ? "paywall.continue".localized : "paywall.try_free".localized
    }

    // Computed property for trial info
    private var trialInfo: String {
        if selectedPlan == "$rc_annual" {
            if let package = yearlyPackage {
                return "paywall.then_price".localized(with: package.storeProduct.localizedPriceString)
            }
            return "paywall.then_price".localized(with: "$39.99")
        } else {
            if let package = weeklyPackage {
                return "paywall.then_price_week".localized(with: package.storeProduct.localizedPriceString)
            }
            return "paywall.then_price_week".localized(with: "$4.99")
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark cinematic background
                Color(hex: "0A0A0F")
                    .ignoresSafeArea()

                // Warm ambient glow
                RadialGradient(
                    colors: [
                        Color(hex: "D4AF37").opacity(0.08),
                        Color(hex: "8B6914").opacity(0.03),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 20,
                    endRadius: geometry.size.height * 0.6
                )
                .ignoresSafeArea()

                // Bottom warm glow
                RadialGradient(
                    colors: [
                        Color(hex: "A98358").opacity(0.05),
                        Color.clear
                    ],
                    center: .bottom,
                    startRadius: 10,
                    endRadius: geometry.size.height * 0.4
                )
                .ignoresSafeArea()
                .onAppear {
                    loadCachedOfferingsIfAvailable()
                    withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                        contentOpacity = 1.0
                        contentOffset = 0
                    }
                }

                VStack(spacing: 0) {
                    // Top bar: Close button
                    HStack {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.08))
                                )
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Spacer(minLength: 0)

                    // Header with crown icon and radial glow
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(hex: "D4AF37").opacity(0.2),
                                            Color(hex: "D4AF37").opacity(0.05),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 8,
                                        endRadius: 50
                                    )
                                )
                                .frame(width: 100, height: 100)

                            Image(systemName: "crown.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "F2D06B"),
                                            Color(hex: "D4AF37"),
                                            Color(hex: "B8860B")
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(hex: "D4AF37").opacity(0.5), radius: 15)
                        }

                        Text("paywall.title".localized)
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("paywall.subtitle".localized)
                            .font(.system(size: 13, weight: .medium, design: .serif))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                    Spacer(minLength: 0)

                    // Features
                    VStack(spacing: 10) {
                        VibrantFeature(icon: "scroll.fill", title: "paywall.epic_stories".localized, description: "paywall.epic_stories_subtitle".localized)
                        VibrantFeature(icon: "waveform", title: "paywall.immersive_audio".localized, description: "paywall.immersive_audio_subtitle".localized)
                        VibrantFeature(icon: "globe.americas.fill", title: "paywall.civilizations".localized, description: "paywall.civilizations_subtitle".localized)
                    }
                    .padding(.horizontal, 24)
                    .opacity(contentOpacity)

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
                                    .foregroundColor(.orange.opacity(0.8))

                                Text("paywall.unable_to_load".localized)
                                    .font(.system(size: 16, weight: .semibold, design: .serif))
                                    .foregroundColor(.white)

                                Text(error)
                                    .font(.system(size: 12, design: .serif))
                                    .foregroundColor(.white.opacity(0.5))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)

                                Button {
                                    errorMessage = nil
                                    fetchOfferings()
                                } label: {
                                    Text("retry".localized)
                                        .font(.system(size: 14, weight: .semibold, design: .serif))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 10)
                                        .background(Color(hex: "D4AF37"))
                                        .cornerRadius(8)
                                }
                            } else {
                                // Loading state
                                ProgressView()
                                    .tint(.appAccent)

                                Text("paywall.loading_subscriptions".localized)
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .frame(height: 150)
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 0)

                    // Subscribe Button
                    Button(action: subscribe) {
                        HStack(spacing: 8) {
                            if isProcessing {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text(buttonText)
                                    .font(.system(size: 18, weight: .bold, design: .serif))
                            }
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "F2D06B"),
                                    Color(hex: "D4AF37"),
                                    Color(hex: "C49A2B")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color(hex: "D4AF37").opacity(0.35), radius: 16, x: 0, y: 6)
                        .opacity((yearlyPackage != nil || weeklyPackage != nil) ? 1.0 : 0.5)
                    }
                    .disabled(isProcessing || (yearlyPackage == nil && weeklyPackage == nil))
                    .padding(.horizontal, 20)
                    .opacity(contentOpacity)

                    // Trial info
                    Text(trialInfo)
                        .font(.system(size: 11, weight: .medium, design: .serif))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.top, 6)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    // Legal links
                    HStack(spacing: 16) {
                        Button("paywall.terms".localized) {
                            if let url = URL(string: "https://dainty.app/terms") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(.white.opacity(0.3))

                        Button("paywall.privacy".localized) {
                            if let url = URL(string: "https://dainty.app/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(.white.opacity(0.3))

                        Button("paywall.restore".localized) {
                            restorePurchases()
                        }
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(.white.opacity(0.3))
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    // MARK: - RevenueCat Methods

    private static let yearlyPackageId = "$rc_annual"
    private static let weeklyPackageId = "$rc_weekly"

    // Try to load cached offerings immediately for instant display
    private func loadCachedOfferingsIfAvailable() {
        Task {
            guard await waitForRevenueCatConfiguration() else {
                await MainActor.run {
                    errorMessage = "Subscriptions are still initializing. Please try again in a moment."
                }
                return
            }
            await loadOfferings()
        }
    }

    private func fetchOfferings() {
        print("🔄 Fetching RevenueCat offerings...")
        Task {
            guard await waitForRevenueCatConfiguration() else {
                await MainActor.run {
                    errorMessage = "Subscriptions are still initializing. Please try again in a moment."
                }
                return
            }
            await loadOfferings()
        }
    }

    /// RevenueCat may finish configuring slightly after first paint — wait briefly instead of failing hard.
    private func waitForRevenueCatConfiguration(attempts: Int = 15) async -> Bool {
        for _ in 0..<attempts {
            if Purchases.isConfigured { return true }
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        return Purchases.isConfigured
    }

    private func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()

            await MainActor.run {
                self.offerings = offerings
                self.errorMessage = nil

                if let current = offerings.current {
                    let yearly = current.package(identifier: Self.yearlyPackageId)
                    let weekly = current.package(identifier: Self.weeklyPackageId)

                    if let yearly {
                        print("✅ Yearly package: \(yearly.storeProduct.localizedPriceString)")
                    }
                    if let weekly {
                        print("✅ Weekly package: \(weekly.storeProduct.localizedPriceString)")
                    }

                    if yearly == nil && weekly == nil {
                        self.errorMessage = "No subscription packages found. Expected '\(Self.yearlyPackageId)' and/or '\(Self.weeklyPackageId)' in RevenueCat."
                    }
                } else if let firstOffering = offerings.all.values.first {
                    let yearly = firstOffering.package(identifier: Self.yearlyPackageId)
                    let weekly = firstOffering.package(identifier: Self.weeklyPackageId)
                    if yearly == nil && weekly == nil {
                        self.errorMessage = "No subscription packages found in offering '\(firstOffering.identifier)'."
                    }
                } else {
                    self.errorMessage = "No subscription offerings configured in RevenueCat."
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load subscriptions: \(error.localizedDescription)"
                print("❌ RevenueCat error: \(error)")
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
                    .fill(Color(hex: "D4AF37").opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "D4AF37"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(.white.opacity(0.9))

                Text(description)
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(.white.opacity(0.45))
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
                            .foregroundColor(.white)

                        if showBadge {
                            Text("paywall.best_value".localized)
                                .font(.system(size: 9, weight: .black, design: .serif))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "F2D06B"),
                                                    Color(hex: "D4AF37")
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        } else if isWeekly {
                            Text("paywall.trial".localized)
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

                    Text(package.storeProduct.subscriptionPeriod?.unit == .year ? "paywall.save_85".localized : "paywall.trial_days".localized)
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(.white.opacity(0.45))
                }

                Spacer()

                Text(package.storeProduct.localizedPriceString)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "D4AF37"))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected ? Color.white.opacity(0.08) : Color.white.opacity(0.03)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ?
                        LinearGradient(
                            colors: [
                                Color(hex: "D4AF37").opacity(0.8),
                                Color(hex: "A98358").opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            )
            .shadow(color: isSelected ? Color(hex: "D4AF37").opacity(0.2) : Color.clear, radius: 12, x: 0, y: 4)
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
