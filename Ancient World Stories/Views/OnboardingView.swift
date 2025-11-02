//
//  OnboardingView.swift
//  Ancient World Stories
//
//  Onboarding experience with ancient parchment aesthetic
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var showPaywall = false
    
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
            
            // Subtle texture overlay
            Color.white.opacity(0.03)
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
                
                // Bottom buttons
                VStack(spacing: 16) {
                    if currentPage < 2 {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        }) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold, design: .serif))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.94, green: 0.82, blue: 0.54), // #f1d78a faded gold
                                            Color(red: 0.84, green: 0.58, blue: 0.23)  // #d69438 antique gold
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(red: 0.84, green: 0.58, blue: 0.23).opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentPage = 2
                            }
                        }) {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium, design: .serif))
                                .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23)) // #7b5e3b antique brown
                        }
                    } else {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showPaywall = true
                            }
                        }) {
                            Text("Get Started")
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
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
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
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon with radial glow
            ZStack {
                // Radial glow effect
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
                
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.84, green: 0.58, blue: 0.23))
            }
            
            VStack(spacing: 16) {
                Text("Journey Through Time")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))
                    .multilineTextAlignment(.center)
                
                Text("Discover captivating stories from ancient civilizations. From Mesopotamia to Greece, experience history like never before.")
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
}

// MARK: - Page 2: Features
struct OnboardingPage2: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon with radial glow
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
                
                Image(systemName: "map.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.84, green: 0.58, blue: 0.23))
            }
            
            VStack(spacing: 16) {
                Text("Explore & Listen")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))
                    .multilineTextAlignment(.center)
                
                Text("Navigate through an interactive map, discover civilizations by era, and listen to stories with immersive audio narration.")
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23).opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
}

// MARK: - Page 3: Premium
struct OnboardingPage3: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon with radial glow
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
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.84, green: 0.58, blue: 0.23))
            }
            
            VStack(spacing: 24) {
                Text("Unlock All Stories")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.48, green: 0.37, blue: 0.23))
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "checkmark.circle.fill", text: "Access 100+ ancient stories")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Audio narration for all chapters")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Offline reading mode")
                    FeatureRow(icon: "checkmark.circle.fill", text: "New stories added weekly")
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
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

// MARK: - Preview
#Preview {
    OnboardingView()
}
