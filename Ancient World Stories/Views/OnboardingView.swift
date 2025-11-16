//
//  OnboardingView.swift
//  Ancient World Stories
//
//  Premium onboarding with museum-quality animations
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var showPaywall = false
    @State private var buttonPulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            // App theme parchment background
            Color.appBackground
                .ignoresSafeArea()

            // Subtle gradient overlay
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
            
            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ?
                                  Color.appAccent :
                                  Color.appText.opacity(0.25))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 60)
                
                // Content
                TabView(selection: $currentPage) {
                    OnboardingPage1()
                        .tag(0)
                    
                    OnboardingPage2()
                        .tag(1)
                    
                    OnboardingPage3()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom button with gentle pulsing animation
                Button(action: {
                    if currentPage < 2 {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentPage += 1
                        }
                    } else {
                        // Show paywall with slide animation
                        showPaywall = true
                    }
                }) {
                    Text(currentPage < 2 ? "Continue" : "Get Started")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "D4AF37"),
                                    Color.appAccent,
                                    Color(hex: "8B6914")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.appAccent.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            // When paywall is dismissed, complete onboarding immediately
            hasCompletedOnboarding = true
        } content: {
            PaywallView(isPresented: $showPaywall)
        }
        .task {
            // Load Supabase data in background while user sees onboarding
            print("📚 Loading data during onboarding...")
            await ContentLoader.shared.loadInitialData()
            print("✅ Data loaded and ready!")
        }
    }
}

// MARK: - Page 1: Welcome
struct OnboardingPage1: View {
    @State private var iconScale: CGFloat = 0.9
    @State private var titleOpacity: Double = 0
    @State private var descriptionOpacity: Double = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon with radial glow and scale animation
            ZStack {
                // Radial glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.appAccent.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(iconScale * 0.95)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appAccent.opacity(0.15),
                                Color.appSecondary.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(iconScale * 0.97)

                Image(systemName: "building.columns.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.appAccent)
                    .scaleEffect(iconScale)
            }

            VStack(spacing: 16) {
                Text("Journey Through Time")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)

                Text("Discover captivating stories from ancient civilizations. From Mesopotamia to Greece, experience history like never before.")
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(.appText.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(descriptionOpacity)
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
                descriptionOpacity = 1.0
            }
        }
    }
}

// MARK: - Page 2: Features
struct OnboardingPage2: View {
    @State private var iconScale: CGFloat = 0.9
    @State private var titleOpacity: Double = 0
    @State private var descriptionOpacity: Double = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon with radial glow and scale animation
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.appAccent.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(iconScale * 0.95)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appAccent.opacity(0.15),
                                Color.appSecondary.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(iconScale * 0.97)

                Image(systemName: "map.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.appAccent)
                    .scaleEffect(iconScale)
            }

            VStack(spacing: 16) {
                Text("Explore & Listen")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)

                Text("Navigate through an interactive map, discover civilizations by era, and listen to stories with immersive audio narration.")
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(.appText.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(descriptionOpacity)
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
                descriptionOpacity = 1.0
            }
        }
    }
}

// MARK: - Page 3: Premium
struct OnboardingPage3: View {
    @State private var iconScale: CGFloat = 0.9
    @State private var titleOpacity: Double = 0
    @State private var featuresOpacity: Double = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon with radial glow and scale animation
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.appAccent.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(iconScale * 0.95)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appAccent.opacity(0.15),
                                Color.appSecondary.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(iconScale * 0.97)

                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.appAccent)
                    .scaleEffect(iconScale)
            }

            VStack(spacing: 24) {
                Text("Unlock All Stories")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)

                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "checkmark.circle.fill", text: "Access 100+ ancient stories")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Audio narration for all chapters")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Offline reading mode")
                    FeatureRow(icon: "checkmark.circle.fill", text: "New stories added weekly")
                }
                .padding(.horizontal, 32)
                .opacity(featuresOpacity)
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
                featuresOpacity = 1.0
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color.appAccent)

            Text(text)
                .font(.system(size: 16, design: .serif))
                .foregroundColor(.appText.opacity(0.85))
        }
    }
}

// MARK: - Papyrus Texture Overlay
struct PapyrusTexture: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for _ in 0..<200 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let length = CGFloat.random(in: 2...8)
                    let angle = CGFloat.random(in: 0...(2 * .pi))

                    var path = Path()
                    path.move(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(
                        x: x + cos(angle) * length,
                        y: y + sin(angle) * length
                    ))

                    context.stroke(
                        path,
                        with: .color(Color.appText.opacity(0.1)),
                        lineWidth: 0.5
                    )
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
}
