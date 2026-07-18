import SwiftUI

// PADRÃO CANÔNICO do botão circular de chrome (ordem do operador
// 2026-07-18: "tudo no padrão Liquid Glass da Apple, documentado").
//
// Regra: TODO botão circular de navegação/chrome (topo de tela, voltar,
// fechar) usa `.atlasGlassCircle()` — Liquid Glass interativo do sistema
// no iOS 26; no alvo mínimo (17) cai no círculo de surface da casa.
// Nunca criar círculo chapado novo: a identidade mora no glifo/ink,
// o vidro é do sistema.

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
                Capsule().fill(AtlasTheme.surface)
                    .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
        }
    }
}

extension View {
    func atlasGlassCircle() -> some View { modifier(AtlasGlassCircle()) }
    /// Mesma lei para pílulas/cápsulas de chrome (composer da home, new pill).
    func atlasGlassCapsule() -> some View { modifier(AtlasGlassCapsule()) }
}
