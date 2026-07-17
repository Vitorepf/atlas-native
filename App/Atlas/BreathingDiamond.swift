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
        applyBreathHandlers(breathingDiamondShape)
    }
}
