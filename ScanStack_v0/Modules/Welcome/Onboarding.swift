//
//  Onboarding.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 01/07/2026.
//
//  Architecture: Stationary Frame + Sliding Content Deck
//  ─────────────────────────────────────────────────────
//  • Onboarding        → Root container. Owns `currentStep` state.
//                        Renders the fixed chrome (navbar + bottom controls)
//                        and the sliding center deck in one ZStack layer.
//
//  • OnboardingSlide   → Protocol-like enum describing each page's content.
//
//  • Slide1CardView    → Visual mockup canvas for step 0  (from Welcome_1)
//  • Slide2CardView    → Visual mockup canvas for step 1  (from Welcome_2)
//  • Slide3CardView    → Visual mockup canvas for step 2  (from Welcome_3)
//
//  • OnboardingSlidingDeck → Hosts the three SlideCardViews in a ZStack
//                            with horizontal slide transitions.
//

import SwiftUI

// MARK: - Root Container ──────────────────────────────────────────────────────

struct Onboarding: View {

    // ── Navigation out of onboarding
    @State private var navigateToRegistration = false

    // ── Slide state (0 = step 1, 1 = step 2, 2 = step 3)
    @State private var currentStep: Int = 0

    // ── Direction flag so the transition plays forward or backward
    @State private var slideForward: Bool = true

    // Total number of onboarding steps
    private let totalSteps = 3

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

                // ── 1. Background — always stationary ─────────────────────
                Color("AccentColor")
                    .ignoresSafeArea()

                // ── 2. Stationary chrome layer ─────────────────────────────
                //    Navbar at top, bottom controls at bottom.
                //    This VStack never animates.
                VStack(spacing: 0) {

                    // Top Navbar
                    navBar

                    Spacer()

                    // Bottom controls (indicators + CTA button)
                    bottomControls
                }
                .zIndex(2) // sits above the sliding deck

                // ── 3. Sliding content deck ────────────────────────────────
                //    Only the card mockup, headline, and body copy slide.
                OnboardingSlidingDeck(
                    currentStep: currentStep,
                    slideForward: slideForward
                )
                .zIndex(1)
            }
            // Navigate to Registration when the user taps "Get Started"
            .navigationDestination(isPresented: $navigateToRegistration) {
                Registeration()
            }
        }
    }

    // MARK: Navbar ─────────────────────────────────────────────────────────────

    private var navBar: some View {
        HStack {
            Text("ScanStack")
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.horizontal, 20)

            Spacer()

            Button {
                navigateToRegistration = true
            } label: {
                Text("Skip")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("skip_btn"))
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }

    // MARK: Bottom Controls ────────────────────────────────────────────────────

    private var bottomControls: some View {
        VStack(alignment: .center, spacing: 0) {

            // Progress indicators
            HStack(alignment: .center, spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Capsule()
                        .fill(index == currentStep ? Color(hex: "006289") : Color(hex: "ABADAF"))
                        .frame(width: index == currentStep ? 28 : 6, height: 6)
                        // Smooth width morph when the active dot changes
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentStep)
                }
            }
            .padding(.top, 36)

            // CTA button
            Button {
                handleNextTap()
            } label: {
                HStack(alignment: .center) {
                    Text(currentStep == totalSteps - 1 ? "Get Started" : "Next")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)

                    Image(systemName: "arrowshape.right.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                }
                .frame(width: 338, height: 68, alignment: .center)
                .background(
                    LinearGradient(
                        colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(1000)
            }
            .padding(.top, 22)
            .shadow(radius: 6)
            .shadow(color: Color("btn_gradiant_color_1").opacity(0.3), radius: 6, x: 2, y: 2)
        }
        .padding(.bottom, 36)
    }

    // MARK: Actions ────────────────────────────────────────────────────────────

    private func handleNextTap() {
        if currentStep < totalSteps - 1 {
            slideForward = true
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                currentStep += 1
            }
        } else {
            navigateToRegistration = true
        }
    }
}

// MARK: - Sliding Deck ────────────────────────────────────────────────────────

/// Renders only the center section that slides: card mockup + headline + body.
/// The parent's stationary chrome is completely independent of this view.
struct OnboardingSlidingDeck: View {

    let currentStep: Int
    let slideForward: Bool

    var body: some View {
        // Use a GeometryReader so each card can fill its natural vertical space
        // without shifting the stationary chrome above or below it.
        GeometryReader { geo in
            ZStack {
                
                switch currentStep {
                case 0:
                    Slide1ContentView()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .transition(slideTransition(forward: slideForward))
                        .id("slide-0")

                case 1:
                    Slide2ContentView()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .transition(slideTransition(forward: slideForward))
                        .id("slide-1")

                case 2:
                    Slide3ContentView()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .transition(slideTransition(forward: slideForward))
                        .id("slide-2")

                default:
                    EmptyView()
                }
            }
            // The animation wraps only the deck's content swap
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: currentStep)
        }
    }

    private func slideTransition(forward: Bool) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: forward ? .trailing : .leading),
            removal:   .move(edge: forward ? .leading  : .trailing)
        )
    }
}

// MARK: - Slide 1 Content (Welcome_1 centre section) ─────────────────────────

struct Slide1ContentView: View {

    @State private var animateCard = false

    var body: some View {
        VStack(spacing: 10) {

            // Spacer to push content down past the navbar height
            Spacer().frame(height: 56)

            // ── Mockup card canvas ──────────────────────────────────────────
            ZStack {
                // Glow ellipse
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 370, height: 328)
                    .opacity(0.25)
                    .blur(radius: 64)

                // Back-left card
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.gray.opacity(0.05))
                    .frame(width: 150, height: 258)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .rotationEffect(.degrees(animateCard ? -14 : 0))
                    .offset(x: animateCard ? -70 : 0, y: animateCard ? 10 : 0)

                // Back-right card
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.gray.opacity(0.05))
                    .frame(width: 150, height: 258)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .rotationEffect(.degrees(animateCard ? 14 : 0))
                    .offset(x: animateCard ? 70 : 0, y: animateCard ? 10 : 0)

                // Front white card
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 224, height: 258)
                    .cornerRadius(32)

                // Card interior
                VStack(alignment: .leading, spacing: 20) {
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 190, height: 128)
                            .cornerRadius(16)

                        Image("welcome1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 190, height: 128)
                            .opacity(0.6)
                            .blendMode(.overlay)
                            .cornerRadius(16)
                            .clipped()

                        Image("welcome1_ai")
                            .clipped()
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Capsule()
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 160, height: 8)
                        Capsule()
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 100, height: 8)
                    }

                    HStack(spacing: 12) {
                        Capsule()
                            .fill(Color.cyan)
                            .frame(width: 28, height: 6)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.cyan.opacity(0.2)))

                        Capsule()
                            .fill(Color.purple.opacity(0.6))
                            .frame(width: 28, height: 6)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.purple.opacity(0.15)))
                    }
                }

                // Floating badges (positioned relative to ZStack)
                Image("classified")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 77)
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
                    .offset(x: 95, y: 85)

                Image("extraction")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 77)
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
                    .offset(x: -95, y: 150)
            }
            // Clip so the badges don't overflow the deck area
            //.clipped()

            // ── Headline + body ─────────────────────────────────────────────
            VStack(alignment: .center, spacing: 0) {
                Text("Stop digging")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(Color(hex: "2C2F31"))

                Text("Start Finding")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "006289"), Color(hex: "831BD7")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Your gallery is full of information. ScanStack uses AI to read your screenshots and organize them automatically.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "595C5E"))
                    .frame(width: 283)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
                animateCard = true
            }
        }
        .onDisappear {
            animateCard = false
        }
    }
}

// MARK: - Slide 2 Content (Welcome_2 centre section) ─────────────────────────

struct Slide2ContentView: View {

    var body: some View {
        VStack(spacing: 10) {

            Spacer().frame(height: 56)

            // ── Mockup card canvas ──────────────────────────────────────────
            ZStack {
                // Glow ellipse
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 370, height: 328)
                    .opacity(0.25)
                    .blur(radius: 64)

                // Tilted background card
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("btn_gradiant_color_0").opacity(0.2),
                                Color("btn_gradiant_color_1").opacity(0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(48)
                    .frame(width: 312, height: 322)
                    .rotationEffect(.degrees(8))
                    .padding(.top)

                // Main white card
                RoundedRectangle(cornerRadius: 32)
                    .fill(.white)
                    .frame(width: 326, height: 268)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color(hex: "ABADAF").opacity(0.2), lineWidth: 1.4)
                    )
                    .padding(.top)

                // Skeleton text lines inside card
                VStack(alignment: .center) {
                    HStack(alignment: .center) {
                        Capsule()
                            .fill(Color(hex: "DADDE0").opacity(0.6))
                            .frame(width: 96, height: 16)
                        Spacer()
                        Capsule()
                            .fill(Color(hex: "DADDE0").opacity(0.6))
                            .frame(width: 48, height: 16)
                    }
                    .frame(width: 260)
                    .padding(.top, -10)
                    .padding(.bottom, 20)

                    VStack(alignment: .leading) {
                        Capsule().fill(Color(hex: "DADDE0").opacity(0.6)).frame(width: 260, height: 12)
                        Capsule().fill(Color(hex: "DADDE0").opacity(0.6)).frame(width: 260, height: 12)
                        Capsule().fill(Color(hex: "DADDE0").opacity(0.6)).frame(width: 180, height: 12)
                    }
                    .padding(.bottom, 30)

                    VStack(alignment: .leading) {
                        Capsule().fill(Color(hex: "DADDE0").opacity(0.6)).frame(width: 260, height: 12)
                        Capsule().fill(Color(hex: "DADDE0").opacity(0.6)).frame(width: 180, height: 12)
                        Capsule().fill(Color(hex: "DADDE0").opacity(0.6)).frame(width: 190, height: 12)
                    }
                }
                .frame(width: 260)

                // Glassmorphic "TEXT DETECTED" badge
                ZStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TEXT DETECTED")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "006289"))

                        Text("Total: Rs.124.53")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(Color(hex: "2C2F31"))
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background {
                        ZStack {
                            Capsule().fill(.ultraThinMaterial)
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "2DBCFE").opacity(0.08),
                                            Color(hex: "A370F7").opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Capsule()
                                .stroke(Color.white.opacity(0.65), lineWidth: 1.5)
                                .blur(radius: 0.5)
                                .mask(
                                    Capsule().fill(
                                        LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                                    )
                                )
                        }
                    }
                    .overlay {
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "2DBCFE").opacity(0.8), Color(hex: "A370F7").opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: Color(hex: "A370F7").opacity(0.12), radius: 12, x: 0, y: 8)
                }
                .offset(x: -20, y: 80)

                // "AI VISION" pill badge
                ZStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("btn_gradiant_color_0").opacity(1),
                                    Color("btn_gradiant_color_1").opacity(1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 80, height: 30)

                    Text("AI VISION")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(Color("btn_gradiant_color_1"))
                        .padding()
                        .glassEffect()
                        .overlay {
                            Capsule()
                                .stroke(
                                    LinearGradient(colors: [Color(.white)], startPoint: .top, endPoint: .bottom),
                                    lineWidth: 2.5
                                )
                        }
                        .frame(width: 108, height: 50)
                }
                .offset(x: 90, y: 50)
            }

            // ── Headline + body ─────────────────────────────────────────────
            VStack(alignment: .center, spacing: 0) {
                Text("Search Inside")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(Color(hex: "2C2F31"))

                Text("Your Photos")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "006289"), Color(hex: "831BD7")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("ScanStack instantly turns text, numbers, and details within your screenshots into searchable information, organizing your gallery automatically.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "595C5E"))
                    .frame(width: 340)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 8)
            }
            .padding(.top, 8)

            Spacer()
        }
    }
}

// MARK: - Slide 3 Content (Welcome_3 centre section) ─────────────────────────

struct Slide3ContentView: View {

    var body: some View {
        VStack(spacing: 10) {

            Spacer().frame(height: 56)

            // ── Mockup card canvas ──────────────────────────────────────────
            Image("welcome3")
                .resizable()
                .scaledToFill()
                .frame(width: 338, height: 326)
                .clipped()

            // ── Headline + body ─────────────────────────────────────────────
            VStack(alignment: .center, spacing: 0) {
                Text("Secure &")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(Color(hex: "2C2F31"))

                Text("Actionable")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "006289"), Color(hex: "831BD7")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Protect sensitive docs with FaceID and take action on links or numbers with one tap. Your data stays 100% on your device.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "595C5E"))
                    .frame(width: 303)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 8)
            }
            .padding(.top, 8)
            Spacer()
        }
    }
}

// MARK: - Preview ─────────────────────────────────────────────────────────────

#Preview {
    Onboarding()
}
