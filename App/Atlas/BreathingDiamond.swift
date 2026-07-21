import SwiftUI

// IDLE-COMPRESS fused

// --- BreathingDiamond+AnimatedShape.swift ---
extension BreathingDiamond {
    var breathingDiamondShape: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(AtlasTheme.accent)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(45))
            .scaleEffect(on ? 1.18 : 1)
            .opacity(on ? 0.45 : 1)
            .accessibilityHidden(true)
    }
}

// --- BreathingDiamond+Handlers.swift ---
extension BreathingDiamond {
    func applyBreathHandlers<Content: View>(_ content: Content) -> some View {
        content
            .onAppear {
                if effectiveReduceMotion {
                    on = false
                } else {
                    withAnimation(AtlasMotion.breath(0.9)) { on = true }
                }
            }
            .onChange(of: effectiveReduceMotion) { _, paused in
                if paused {
                    on = false
                } else if !on {
                    withAnimation(AtlasMotion.breath(0.9)) { on = true }
                }
            }
    }
}

// --- BreathingDiamond.swift ---
struct BreathingDiamond: View {
    let size: CGFloat
    var reduceMotion: Bool? = nil

    @Environment(\.accessibilityReduceMotion) var envReduceMotion
    @State var on = false

    var effectiveReduceMotion: Bool { reduceMotion ?? envReduceMotion }

    var body: some View {
        applyBreathHandlers(breathingDiamondShape)
    }
}
