import SwiftUI

// Losango bronze respirando (SyncDiamond) — indicador decorativo de execução viva.
// Sempre silenciado no VoiceOver; o spoken composto vive no container pai.
// Handlers → BreathingDiamond+Handlers.swift
struct BreathingDiamond: View {
    let size: CGFloat
    /// Quando nil, lê `@Environment(\.accessibilityReduceMotion)`.
    var reduceMotion: Bool? = nil

    @Environment(\.accessibilityReduceMotion) var envReduceMotion
    @State var on = false

    var effectiveReduceMotion: Bool { reduceMotion ?? envReduceMotion }

    var body: some View {
        applyBreathHandlers(
            RoundedRectangle(cornerRadius: 2)
                .fill(AtlasTheme.accent)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(45))
                .scaleEffect(on ? 1.18 : 1)
                .opacity(on ? 0.45 : 1)
                .accessibilityHidden(true)
        )
    }
}
