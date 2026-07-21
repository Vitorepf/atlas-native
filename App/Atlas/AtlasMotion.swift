import SwiftUI
import UIKit

// Cycle 044 fuse → AtlasMotion.swift

// Fundação de motion do Atlas — porte dos tokens editoriais (tokens.ts). Ritmo
// calmo, nunca overshoot Material: curva editorial + springs damping ≥0.8.
enum AtlasMotion {
    static let instinct: Double = 0.18
    static let considered: Double = 0.32
    static let ceremonial: Double = 0.48
    static let sacred: Double = 0.62

    /// Curva editorial (ease-out suave) — a transição padrão.
    static let editorial = Animation.timingCurve(0.22, 1, 0.36, 1, duration: considered)
    /// Chegada da resposta (pousa como papel).
    static let arrival = Animation.spring(response: 0.42, dampingFraction: 0.82)
    /// Respiração de streaming / breath do send.
    static func breath(_ duration: Double = 0.9) -> Animation {
        .easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}

extension AtlasMotion {
    /// Haptics are UI-only; isolate on MainActor for StrictConcurrency.
    @MainActor
    static func softImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    @MainActor
    static func mediumImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    @MainActor
    static func lightImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

extension AtlasMotion {
    @MainActor
    static func successNotification(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

/// Numeric text morph só quando Reduce Motion está desligado.
struct NumericTextTransition: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.contentTransition(.numericText())
        } else {
            content
        }
    }
}

@MainActor
enum AtlasMotionPresentation {
    /// Transição editorial condicional — nil com Reduce Motion.
    static func editorial(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : AtlasMotion.editorial
    }

    /// Identidade com Reduce Motion; editorial caso contrário.
    static func rowTransition(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .identity : .opacity.combined(with: .move(edge: .top))
    }
}

extension View {
    func atlasNumericTransition(reduceMotion: Bool) -> some View {
        modifier(NumericTextTransition(enabled: !reduceMotion))
    }
}
