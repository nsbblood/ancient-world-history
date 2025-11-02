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
            // Ancient parchment gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.90, blue: 0.67), // #f3e5ab soft parchment
                    Color(red: 0.84, green: 0.75, blue: 0.54)  // #d6c08a warm stone
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Papyrus texture overlay (5% opacity)
            PapyrusTexture()
                .opacity(0.05)
                .ignoresSafeArea()
                .blendMode(.overlay)
            
            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? 
                                  Color(red: 0.84, green: 0.58, blue: 0.23) : 
                                  Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.3))
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
                    withAnimation(.easeInOut(duration: 0.4)) {
                        if currentPage < 2 {
                            currentPage += 1
                        } else {
                            showPaywall = true
                        }
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
                                    Color(red: 0.94, green: 0.82, blue: 0.54),
                                    Color(red: 0.84, green: 0.58, blue: 0.23)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.84, green: 0.58, blue: 0.23).opacity(0.4), radius: 8, x: 0, y: 4)
                        .scaleEffect(buttonPulse)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                    ) {
                        buttonPulse = 1.03
                    }
                }
            }
            
            // Paywall slides in from right
            if showPaywall {
                PaywallView(onComplete: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        hasCompletedOnboarding = true
                    }
                }, onDismiss: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showPaywall = false
                    }
                })
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
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
                // Radial glow effect with subtle parallax
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.94, green: 0.82, blue: 0.54).opacity(0.4),
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
                                Color(red: 0.94, green: 0.82, blue: 0.54).opacity(0.2),
                                Color(red: 0.84, green: 0.58, blue: 0.23).opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(iconScale * 0.97)

                Image(systemName: "building.columns.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.84, green: 0.58, blue: 0.23))
                    .scaleEffect(iconScale)
            }

            VStack(spacing: 16) {
                Text("Journey Through Time")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)

                Text("Discover captivating stories from ancient civilizations. From Mesopotamia to Greece, experience history like never before.")
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.8))
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
                                Color(red: 0.94, green: 0.82, blue: 0.54).opacity(0.4),
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
                                Color(red: 0.94, green: 0.82, blue: 0.54).opacity(0.2),
                                Color(red: 0.84, green: 0.58, blue: 0.23).opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(iconScale * 0.97)

                Image(systemName: "map.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.84, green: 0.58, blue: 0.23))
                    .scaleEffect(iconScale)
            }

            VStack(spacing: 16) {
                Text("Explore & Listen")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)

                Text("Navigate through an interactive map, discover civilizations by era, and listen to stories with immersive audio narration.")
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.8))
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
                                Color(red: 0.94, green: 0.82, blue: 0.54).opacity(0.4),
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
                                Color(red: 0.94, green: 0.82, blue: 0.54).opacity(0.2),
                                Color(red: 0.84, green: 0.58, blue: 0.23).opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(iconScale * 0.97)

                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.84, green: 0.58, blue: 0.23))
                    .scaleEffect(iconScale)
            }

            VStack(spacing: 24) {
                Text("Unlock All Stories")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))
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
                .foregroundColor(Color(red: 0.84, green: 0.58, blue: 0.23))
            
            Text(text)
                .font(.system(size: 16, design: .serif))
                .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.9))
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
                        with: .color(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.15)),
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
