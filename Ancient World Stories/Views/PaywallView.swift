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
    let onComplete: () -> Void
    let onDismiss: () -> Void
    
    @State private var selectedPlan: String = "ancient.year" // Default to yearly
    @State private var isProcessing = false
    @State private var offerings: Offerings?
    @State private var errorMessage: String?
    
    // Computed property for button text
    private var buttonText: String {
        selectedPlan == "ancient.year" ? "Continue" : "Try Free"
    }
    
    // Computed property for trial info
    private var trialInfo: String {
        if selectedPlan == "ancient.year" {
            if let offerings = offerings,
               let current = offerings.current,
               let package = current.package(identifier: "ancient.year") {
                return "Then \(package.storeProduct.localizedPriceString)/year"
            }
            return "Then $39.99/year"
        } else {
            if let offerings = offerings,
               let current = offerings.current,
               let package = current.package(identifier: "ancient.week") {
                return "3-day free trial, then \(package.storeProduct.localizedPriceString)/week"
            }
            return "3-day free trial, then $4.99/week"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Ancient parchment gradient background (matching onboarding)
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.90, blue: 0.67), // #f3e5ab soft parchment
                        Color(red: 0.84, green: 0.75, blue: 0.54)  // #d6c08a warm stone
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Subtle texture overlay
                Color.white.opacity(0.03)
                    .ignoresSafeArea()
                    .blendMode(.overlay)
                
                VStack(spacing: 0) {
                    // Top bar: Close button only
                    HStack {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.7))
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.4))
                                )
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer(minLength: 8)

                    // Header with crown icon and radial glow
                    VStack(spacing: 8) {
                        ZStack {
                            // Radial glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 0.94, green: 0.82, blue: 0.54).opacity(0.4),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color(red: 0.84, green: 0.58, blue: 0.23))
                        }
                        
                        Text("Unlock Premium")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))

                        Text("Get unlimited access to all ancient stories")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    Spacer(minLength: 8)

                    // Features (compact)
                    VStack(spacing: 10) {
                        CompactFeature(icon: "book.fill", title: "100+ Stories")
                        CompactFeature(icon: "speaker.wave.3.fill", title: "Audio Narration")
                        CompactFeature(icon: "arrow.down.circle.fill", title: "Offline Mode")
                        CompactFeature(icon: "sparkles", title: "Weekly Updates")
                    }
                    .padding(.horizontal, 32)

                    Spacer(minLength: 8)

                    // Try Free Toggle - Independent switch
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Try Free Trial")
                                .font(.system(size: 16, weight: .semibold, design: .serif))
                                .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))

                            Text("3-day free trial, then billed")
                                .font(.system(size: 12, design: .serif))
                                .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.7))
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { selectedPlan == "ancient.week" },
                            set: { isOn in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedPlan = isOn ? "ancient.week" : "ancient.year"
                                }
                            }
                        ))
                        .tint(Color(red: 0.84, green: 0.58, blue: 0.23))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.3))
                    )
                    .padding(.horizontal, 20)

                    Spacer(minLength: 6)

                    // Subscription Plans
                    VStack(spacing: 12) {
                        if let offerings = offerings,
                           let current = offerings.current {

                            // Yearly Plan
                            if let yearlyPackage = current.package(identifier: "ancient.year") {
                                SubscriptionCard(
                                    package: yearlyPackage,
                                    isSelected: selectedPlan == "ancient.year",
                                    showBadge: true,
                                    onSelect: { selectedPlan = "ancient.year" }
                                )
                            }

                            // Weekly Plan
                            if let weeklyPackage = current.package(identifier: "ancient.week") {
                                SubscriptionCard(
                                    package: weeklyPackage,
                                    isSelected: selectedPlan == "ancient.week",
                                    showBadge: false,
                                    onSelect: { selectedPlan = "ancient.week" }
                                )
                            }
                        } else {
                            // Fallback static plans while loading
                            StaticSubscriptionCard(
                                title: "Yearly",
                                price: "$39.99",
                                period: "per year",
                                pricePerWeek: "$0.77/week",
                                badge: "Save 85%",
                                isSelected: selectedPlan == "ancient.year",
                                onSelect: { selectedPlan = "ancient.year" }
                            )

                            StaticSubscriptionCard(
                                title: "Weekly",
                                price: "$4.99",
                                period: "per week",
                                pricePerWeek: "$4.99/week",
                                badge: nil,
                                isSelected: selectedPlan == "ancient.week",
                                onSelect: { selectedPlan = "ancient.week" }
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 8)

                    // Subscribe Button (always visible)
                    Button(action: subscribe) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(buttonText)
                                    .font(.system(size: 18, weight: .semibold, design: .serif))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.94, green: 0.82, blue: 0.54),
                                    Color(red: 0.84, green: 0.58, blue: 0.23)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.84, green: 0.58, blue: 0.23).opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isProcessing)
                    .padding(.horizontal, 20)
                    
                    // Trial info
                    Text(trialInfo)
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.7))
                        .padding(.top, 8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Legal links
                    HStack(spacing: 16) {
                        Button("Terms") {
                            // Open terms
                        }
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.6))
                        
                        Button("Privacy") {
                            // Open privacy
                        }
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.6))
                        
                        Button("Restore") {
                            restorePurchases()
                        }
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.6))
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            fetchOfferings()
        }
    }

    // MARK: - RevenueCat Methods
    private func fetchOfferings() {
        Task {
            do {
                let offerings = try await Purchases.shared.offerings()
                await MainActor.run {
                    self.offerings = offerings
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    print("❌ RevenueCat error: \(error)")
                }
            }
        }
    }
    
    private func subscribe() {
        guard let offerings = offerings,
              let current = offerings.current,
              let package = current.package(identifier: selectedPlan) else {
            // Fallback: complete without purchase for testing
            onComplete()
            return
        }
        
        isProcessing = true
        
        Task {
            do {
                let (_, customerInfo, _) = try await Purchases.shared.purchase(package: package)
                
                await MainActor.run {
                    isProcessing = false
                    if customerInfo.entitlements["premium"]?.isActive == true {
                        onComplete()
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
                if customerInfo.entitlements["premium"]?.isActive == true {
                    await MainActor.run {
                        onComplete()
                    }
                }
            } catch {
                print("❌ Restore error: \(error)")
            }
        }
    }
}

// MARK: - Compact Feature Row
struct CompactFeature: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.84, green: 0.58, blue: 0.23))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color(red: 0.94, green: 0.82, blue: 0.54).opacity(0.4))
                )
            
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))
            
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
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(package.storeProduct.localizedTitle)
                            .font(.system(size: 17, weight: .bold, design: .serif))
                            .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))
                        
                        if showBadge {
                            Text("Save 85%")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.94, green: 0.82, blue: 0.54),
                                                    Color(red: 0.84, green: 0.58, blue: 0.23)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                    }
                    
                    Text(package.storeProduct.subscriptionPeriod?.unit == .year ? "Best Value" : "Weekly Access")
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.7))
                }
                
                Spacer()
                
                Text(package.storeProduct.localizedPriceString)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected ?
                        Color(red: 0.94, green: 0.82, blue: 0.54).opacity(0.4) :
                        Color.white.opacity(0.4)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ?
                        Color(red: 0.84, green: 0.58, blue: 0.23) :
                        Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.3),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
        }
    }
}

// MARK: - Static Subscription Card (Fallback)
struct StaticSubscriptionCard: View {
    let title: String
    let price: String
    let period: String
    let pricePerWeek: String
    let badge: String?
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title)
                            .font(.system(size: 17, weight: .bold, design: .serif))
                            .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))
                        
                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.94, green: 0.82, blue: 0.54),
                                                    Color(red: 0.84, green: 0.58, blue: 0.23)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                    }
                    
                    Text(title == "Yearly" ? "Best Value" : "Weekly Access")
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))
                    
                    Text(period)
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.6))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected ?
                        Color(red: 0.94, green: 0.82, blue: 0.54).opacity(0.4) :
                        Color.white.opacity(0.4)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ?
                        Color(red: 0.84, green: 0.58, blue: 0.23) :
                        Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.3),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
        }
    }
}

// MARK: - Preview
#Preview {
    PaywallView(onComplete: {}, onDismiss: {})
}
