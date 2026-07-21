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
            // Fallback pré-26: recessed quieto (mockup home), não surface chapado.
            content.background(
                Capsule().fill(AtlasTheme.bgRecessed.opacity(0.82))
                    .overlay(Capsule().stroke(AtlasTheme.separator.opacity(0.9), lineWidth: 1)))
        }
    }
}

/// Chrome único da pílula agêntica = craft Home (lei pétrea pílula §2).
/// Vidro + fio de ouro artesanal. Só o convite muda por superfície.
struct AtlasAgenticPillChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            // Hit-test friendly fill sob glass no iOS 26 (identifier não some).
            .background { Capsule().fill(AtlasTheme.bgRecessed.opacity(0.01)) }
            .atlasGlassCapsule()
            .overlay(
                Capsule()
                    .strokeBorder(Self.goldFilament, lineWidth: 0.75)
            )
    }

    /// Fio de ouro da home — não goldBorder chapado, não shadow solto.
    static var goldFilament: LinearGradient {
        LinearGradient(
            colors: [
                AtlasTheme.accent.opacity(0.22),
                AtlasTheme.accent.opacity(0.04),
                AtlasTheme.accent.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func atlasGlassCircle() -> some View { modifier(AtlasGlassCircle()) }
    /// Mesma lei para pílulas/cápsulas de chrome (composer da home, new pill).
    func atlasGlassCapsule() -> some View { modifier(AtlasGlassCapsule()) }
    /// Chrome canônico da pílula: glass + fio de ouro Home. Use em toda superfície.
    func atlasAgenticPillChrome() -> some View { modifier(AtlasAgenticPillChrome()) }
}
