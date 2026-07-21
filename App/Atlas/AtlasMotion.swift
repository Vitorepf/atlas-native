import SwiftUI
import UIKit

// Cycle 044 fuse → AtlasMotion.swift

// Fundação de motion do Atlas — porte dos tokens editoriais (tokens.ts). Ritmo
// calmo, nunca overshoot Material: curva editorial + springs damping ≥0.8.
enum AtlasMotion {
    static let instinct: Double = 0.18
    static let considered: Double = 0.32

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
}

// Botão com press-scale spring (tato físico). Reduce Motion = sem scale nem bounce.
struct PressableScale: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.96 : 1))
            .animation(
                reduceMotion
                    ? nil
                    : (configuration.isPressed
                        ? .easeOut(duration: AtlasMotion.instinct)
                        // Editorial: damping ≥0.8 — never Material overshoot.
                        : .spring(response: 0.25, dampingFraction: 0.82)),
                value: configuration.isPressed
            )
    }
}


// Cycle 044 fuse → BreathingDiamond.swift

// Losango bronze respirando (SyncDiamond) — indicador decorativo de execução viva.
// Sempre silenciado no VoiceOver; o spoken composto vive no container pai.
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
