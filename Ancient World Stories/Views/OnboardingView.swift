//
//  OnboardingView.swift
//  Ancient World Stories
//
//  Cinematic onboarding with ancient world atmosphere
//

import SwiftUI

// MARK: - Main Onboarding View
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            // Cinematic dark background
            Color.black.ignoresSafeArea()

            // Main onboarding content
            if !showPaywall {
                onboardingContent
                    .transition(.opacity)
            }

            // Paywall with smooth transition
            if showPaywall {
                PaywallView(isPresented: $showPaywall)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(2)
                    .onDisappear {
                        hasCompletedOnboarding = true
                    }
            }
        }
        .task {
            ContentLoader.shared.loadInitialData()
        }
    }

    var onboardingContent: some View {
        ZStack {
            // Animated background particles
            FloatingParticlesView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: 10) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(currentPage == index ?
                                  Color(hex: "D4AF37") :
                                  Color.white.opacity(0.2))
                            .frame(width: currentPage == index ? 24 : 8, height: 4)
                            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentPage)
                    }
                }
                .padding(.top, 60)

                // Pages
                TabView(selection: $currentPage) {
                    OnboardingPage1()
                        .tag(0)

                    OnboardingPage2()
                        .tag(1)

                    OnboardingPage3()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom button
                Button(action: {
                    if currentPage < 2 {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentPage += 1
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showPaywall = true
                        }
                    }
                }) {
                    HStack(spacing: 10) {
                        Text(currentPage < 2 ?
                             NSLocalizedString("onboarding.continue", comment: "") :
                             NSLocalizedString("onboarding.get_started", comment: ""))
                            .font(.system(size: 18, weight: .bold, design: .serif))

                        Image(systemName: currentPage < 2 ? "arrow.right" : "sparkles")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
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
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: "D4AF37").opacity(0.4), radius: 16, x: 0, y: 6)
                }
                .padding(.horizontal, 32)

                // Skip button
                if currentPage < 2 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showPaywall = true
                        }
                    }) {
                        Text("onboarding.skip".localized)
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 12)
                }

                Spacer().frame(height: 40)
            }
        }
    }
}

// MARK: - Floating Particles Background
struct FloatingParticlesView: View {
    @State private var particles: [Particle] = []
    @State private var animationPhase: CGFloat = 0

    struct Particle: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
        let speed: Double
        let symbol: String
    }

    private let ancientSymbols = ["𓂀", "𓁿", "𓃭", "𓆣", "☉", "✦", "◆", "⬥", "𓇯", "𓊝"]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Deep dark gradient background
                LinearGradient(
                    colors: [
                        Color(hex: "0A0A0F"),
                        Color(hex: "121218"),
                        Color(hex: "0D0D14")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Warm ambient glow from top
                RadialGradient(
                    colors: [
                        Color(hex: "D4AF37").opacity(0.08),
                        Color(hex: "8B6914").opacity(0.03),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 20,
                    endRadius: geo.size.height * 0.7
                )

                // Bottom warm glow
                RadialGradient(
                    colors: [
                        Color(hex: "A98358").opacity(0.06),
                        Color.clear
                    ],
                    center: .bottom,
                    startRadius: 10,
                    endRadius: geo.size.height * 0.5
                )

                // Floating golden particles
                ForEach(particles) { particle in
                    Text(particle.symbol)
                        .font(.system(size: particle.size))
                        .foregroundColor(Color(hex: "D4AF37").opacity(particle.opacity))
                        .position(
                            x: particle.x + sin(animationPhase * particle.speed) * 20,
                            y: particle.y + cos(animationPhase * particle.speed * 0.7) * 15
                        )
                        .blur(radius: particle.size > 12 ? 1 : 0)
                }
            }
            .onAppear {
                particles = (0..<25).map { _ in
                    Particle(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height),
                        size: CGFloat.random(in: 6...18),
                        opacity: Double.random(in: 0.05...0.2),
                        speed: Double.random(in: 0.3...1.2),
                        symbol: ancientSymbols.randomElement()!
                    )
                }
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    animationPhase = .pi * 2
                }
            }
        }
    }
}

// MARK: - Page 1: Welcome / Journey Through Time
struct OnboardingPage1: View {
    @State private var ringScale: CGFloat = 0.6
    @State private var ringOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.3
    @State private var iconOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var glowPulse: CGFloat = 0.8

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Animated icon composition
            ZStack {
                // Outer pulsing ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "D4AF37").opacity(0.4),
                                Color(hex: "8B6914").opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(glowPulse)
                    .opacity(ringOpacity * 0.5)

                // Inner ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "D4AF37").opacity(0.6),
                                Color(hex: "A98358").opacity(0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)

                // Radial glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "D4AF37").opacity(0.15),
                                Color(hex: "D4AF37").opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 220, height: 220)
                    .scaleEffect(glowPulse)

                // Main icon
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 72, weight: .thin))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "F2D06B"),
                                Color(hex: "D4AF37"),
                                Color(hex: "A98358")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                    .shadow(color: Color(hex: "D4AF37").opacity(0.5), radius: 20, x: 0, y: 0)
            }
            .frame(height: 240)

            Spacer().frame(height: 48)

            // Title
            VStack(spacing: 16) {
                Text(NSLocalizedString("onboarding.welcome", comment: ""))
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Text(NSLocalizedString("onboarding.welcome_message", comment: ""))
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundColor(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 40)
                    .opacity(subtitleOpacity)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                ringScale = 1.0
                ringOpacity = 1.0
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
                subtitleOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(1.0)) {
                glowPulse = 1.1
            }
        }
    }
}

// MARK: - Page 2: Explore Civilizations
struct OnboardingPage2: View {
    @State private var iconScale: CGFloat = 0.3
    @State private var iconOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var orbitsRotation: Double = 0
    @State private var glowPulse: CGFloat = 0.8

    private let civilizationIcons = [
        ("🏛️", 0.0),   // Greece
        ("🏺", 60.0),  // Pottery
        ("⚔️", 120.0), // Warfare
        ("📜", 180.0), // Scrolls
        ("🗿", 240.0), // Monuments
        ("👑", 300.0),  // Royalty
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                // Orbital ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "D4AF37").opacity(0.2),
                                Color(hex: "A98358").opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
                    .frame(width: 220, height: 220)

                // Orbiting civilization icons
                ForEach(0..<civilizationIcons.count, id: \.self) { index in
                    let (emoji, baseAngle) = civilizationIcons[index]
                    Text(emoji)
                        .font(.system(size: 22))
                        .offset(
                            x: 110 * cos(CGFloat((baseAngle + orbitsRotation) * .pi / 180)),
                            y: 110 * sin(CGFloat((baseAngle + orbitsRotation) * .pi / 180))
                        )
                        .opacity(0.7)
                }

                // Radial glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "D4AF37").opacity(0.12),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 15,
                            endRadius: 90
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(glowPulse)

                // Center icon
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "F2D06B"),
                                Color(hex: "D4AF37"),
                                Color(hex: "A98358")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                    .shadow(color: Color(hex: "D4AF37").opacity(0.4), radius: 15)
            }
            .frame(height: 260)

            Spacer().frame(height: 40)

            VStack(spacing: 16) {
                Text(NSLocalizedString("onboarding.explore_title", comment: ""))
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Text(NSLocalizedString("onboarding.explore_message", comment: ""))
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundColor(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 40)
                    .opacity(subtitleOpacity)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                subtitleOpacity = 1.0
            }
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                orbitsRotation = 360
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5)) {
                glowPulse = 1.1
            }
        }
    }
}

// MARK: - Page 3: Premium Features
struct OnboardingPage3: View {
    @State private var iconScale: CGFloat = 0.3
    @State private var iconOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var featuresVisible: [Bool] = [false, false, false, false]
    @State private var glowPulse: CGFloat = 0.8
    @State private var crownFloat: CGFloat = 0

    private let features: [(icon: String, textKey: String)] = [
        ("scroll.fill", "onboarding.feature_stories"),
        ("waveform", "onboarding.feature_audio"),
        ("icloud.and.arrow.down.fill", "onboarding.feature_offline"),
        ("sparkles", "onboarding.feature_weekly"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Crown with floating animation
            ZStack {
                // Glow rings
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(
                            Color(hex: "D4AF37").opacity(0.1 - Double(i) * 0.03),
                            lineWidth: 0.8
                        )
                        .frame(
                            width: CGFloat(140 + i * 40),
                            height: CGFloat(140 + i * 40)
                        )
                        .scaleEffect(glowPulse)
                }

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "D4AF37").opacity(0.18),
                                Color(hex: "D4AF37").opacity(0.04),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 100
                        )
                    )
                    .frame(width: 220, height: 220)
                    .scaleEffect(glowPulse)

                Image(systemName: "crown.fill")
                    .font(.system(size: 68, weight: .thin))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "F7E7A0"),
                                Color(hex: "D4AF37"),
                                Color(hex: "B8860B")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                    .offset(y: crownFloat)
                    .shadow(color: Color(hex: "D4AF37").opacity(0.6), radius: 25)
            }
            .frame(height: 220)

            Spacer().frame(height: 36)

            // Title
            Text(NSLocalizedString("onboarding.unlock_title", comment: ""))
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .offset(y: titleOffset)
                .opacity(titleOpacity)

            Spacer().frame(height: 32)

            // Features list with staggered animation
            VStack(spacing: 16) {
                ForEach(0..<features.count, id: \.self) { index in
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "D4AF37").opacity(0.12))
                                .frame(width: 40, height: 40)

                            Image(systemName: features[index].icon)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(hex: "D4AF37"))
                        }

                        Text(NSLocalizedString(features[index].textKey, comment: ""))
                            .font(.system(size: 16, weight: .medium, design: .serif))
                            .foregroundColor(.white.opacity(0.8))

                        Spacer()

                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "D4AF37").opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "D4AF37").opacity(0.08), lineWidth: 0.5)
                            )
                    )
                    .opacity(featuresVisible[index] ? 1 : 0)
                    .offset(x: featuresVisible[index] ? 0 : 30)
                }
            }
            .padding(.horizontal, 28)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.1)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
            for i in 0..<features.count {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5 + Double(i) * 0.12)) {
                    featuresVisible[i] = true
                }
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.8)) {
                glowPulse = 1.08
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(0.5)) {
                crownFloat = -8
            }
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
