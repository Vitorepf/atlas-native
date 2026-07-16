import SwiftUI

// Design system CANÔNICO do Atlas (dark) — slate teal warm "Codex canon" + atlas
// gold. Portado 1:1 dos tokens do app original (atlas-app/design/tokens.ts).
// NÃO é preto: o canvas é #1d2b34 (slate teal), o acento é #d4a85a (atlas gold).
enum AtlasTheme {
    // Superfícies (z-axis por profundidade de slate teal)
    static let bg = Color(hex: 0x1D2B34)          // canvas principal
    static let bgRecessed = Color(hex: 0x15212A)  // afundado (footer/sidebar)
    static let surface = Color(hex: 0x243743)      // surface canon (cards, pílula)
    static let surfaceHi = Color(hex: 0x2D4351)   // elevado (raised/pressed)

    // Divisores (≈ branco alpha baixo sobre slate)
    static let separator = Color(hex: 0x313F47)
    static let separatorSoft = Color(hex: 0x27353E)

    // Ink (texto)
    static let textPrimary = Color(hex: 0xD6DDE2)   // corpo
    static let textSecondary = Color(hex: 0x95A3AC) // secundário mudo
    static let textTertiary = Color(hex: 0x677482)  // captions/faint

    // Atlas gold (bronze canon) + info
    static let accent = Color(hex: 0xD4A85A)        // atlas gold
    static let goldVeil = Color(hex: 0xD4A85A, alpha: 0.10)  // fill sutil (pill ativa)
    static let goldBorder = Color(hex: 0xD4A85A, alpha: 0.34)
    static let prussian = Color(hex: 0x7FA7C4)      // info / azul (vivo em AtlasMarkdownView)

    // Cores de domínio com uso real na casca
    static let domOperacional = Color(hex: 0x9B7A3F) // bronze
    static let domAutonomos = Color(hex: 0x6FA06A)   // verde (moss clareado p/ dark)

    enum Space {
        static let screen: CGFloat = 20
        static let row: CGFloat = 16
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

private struct AtlasCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let fillOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(AtlasTheme.surface.opacity(fillOpacity)))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(AtlasTheme.separator, lineWidth: 1))
    }
}

extension View {
    /// Chrome canônico de card: surface + borda separator + cantos 14.
    func atlasCard(cornerRadius: CGFloat = 14, fillOpacity: Double = 1) -> some View {
        modifier(AtlasCardModifier(cornerRadius: cornerRadius, fillOpacity: fillOpacity))
    }
}
