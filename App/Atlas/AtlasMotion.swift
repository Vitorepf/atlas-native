import SwiftUI

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

// Losango bronze respirando (SyncDiamond) — a resposta viva.
struct BreathingDiamond: View {
    let size: CGFloat
    let reduceMotion: Bool
    @State private var on = false
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(AtlasTheme.accent)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(45))
            .scaleEffect(on ? 1.18 : 1)
            .opacity(on ? 0.45 : 1)
            .onAppear { if !reduceMotion { withAnimation(AtlasMotion.breath(0.9)) { on = true } } else { on = false } }
    }
}

// Botão com press-scale spring (tato físico).
struct PressableScale: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(configuration.isPressed ? .easeOut(duration: 0.12) : .spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
