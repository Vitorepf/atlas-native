import Foundation
import SwiftUI

// Cycle 044 fuse → AtlasTheme.swift

// Design system CANÔNICO do Atlas (dark) — slate teal warm + atlas gold.
enum AtlasTheme {}

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
    func atlasCard(cornerRadius: CGFloat = AtlasTheme.Radius.card, fillOpacity: Double = 1) -> some View {
        modifier(AtlasCardModifier(cornerRadius: cornerRadius, fillOpacity: fillOpacity))
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

extension AtlasTheme {
    // Cores de domínio com uso real na casca
    static let domOperacional = Color(hex: 0x9B7A3F) // bronze
    static let domAutonomos = Color(hex: 0x6FA06A)   // verde (moss clareado p/ dark)

    enum Space {
        static let screen: CGFloat = 20
        /// Ritmo vertical das rows da home — um pouco mais compacto que o body
        /// padrão, sem apertar o alvo de toque.
        static let row: CGFloat = 13
    }
}

extension AtlasTheme {
    static let textPrimary = Color(hex: 0xD6DDE2)
    static let textSecondary = Color(hex: 0x95A3AC)
    static let textTertiary = Color(hex: 0x677482)
    static let accent = Color(hex: 0xD4A85A)
    static let goldVeil = Color(hex: 0xD4A85A, alpha: 0.10)
    static let goldBorder = Color(hex: 0xD4A85A, alpha: 0.34)
    static let prussian = Color(hex: 0x7FA7C4)
    static let alert = Color(hex: 0xE08C8C)
}

extension AtlasTheme {
    static let bg = Color(hex: 0x1D2B34)
    static let bgRecessed = Color(hex: 0x15212A)
    static let surface = Color(hex: 0x243743)
    static let surfaceHi = Color(hex: 0x2D4351)
    static let separator = Color(hex: 0x313F47)
    static let separatorSoft = Color(hex: 0x27353E)
}

//
// Três raios e só três: card (superfícies/cartões), control (controles,
// recibos, blocos internos), soft (chrome menor: banners, scrubber).
// Valor fora da lei é escolha deliberada e leva comentário no local
// (ex.: composer 26 = cápsula da pílula de escrita).

extension AtlasTheme {
    enum Radius {
        static let card: CGFloat = 14
        static let control: CGFloat = 12
        static let soft: CGFloat = 10
    }
}


// Liquid Glass circular/capsule chrome (iOS 26+) com fallback quieto.
struct AtlasGlassCircle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Circle())
        } else {
            content.background(Circle().fill(AtlasTheme.surface))
        }
    }
}

struct AtlasGlassCapsule: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Capsule())
        } else {
            content.background(
                Capsule().fill(AtlasTheme.bgRecessed.opacity(0.82))
                    .overlay(Capsule().stroke(AtlasTheme.separator.opacity(0.9), lineWidth: 1)))
        }
    }
}

extension View {
    func atlasGlassCircle() -> some View { modifier(AtlasGlassCircle()) }
    func atlasGlassCapsule() -> some View { modifier(AtlasGlassCapsule()) }
}
