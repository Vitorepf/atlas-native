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

extension View {
    func atlasGlassCircle() -> some View { modifier(AtlasGlassCircle()) }
}
