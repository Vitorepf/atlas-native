import SwiftUI

// Tipografia do Atlas: Fraunces (serif editorial) pro masthead e títulos — a
// identidade do app original — com SF Pro no corpo/listas (clareza estilo Cursor).
//
// DYNAMIC TYPE: todo Font.custom sai com `relativeTo:` — a tipografia inteira
// escala com o ajuste de texto do operador (acessibilidade não é opcional).
// O textStyle âncora deriva do tamanho base: título escala como título, corpo
// como corpo, legenda como legenda — a hierarquia editorial sobrevive ao zoom.
enum AtlasFont {
    /// Serif Fraunces. Pesos mapeados pros nomes PostScript dos .ttf bundleados.
    static func serif(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        let name: String
        switch weight {
        case .bold, .heavy, .black: name = "Fraunces-Bold"
        case .semibold: name = "Fraunces-SemiBold"
        case .medium: name = "Fraunces-Medium"
        default: name = "Fraunces-Regular"
        }
        return .custom(name, size: size, relativeTo: anchor(size))
    }

    static func serifItalic(_ size: CGFloat) -> Font {
        .custom("Fraunces-Italic", size: size, relativeTo: anchor(size))
    }

    /// JetBrains Mono (código) — o mono do Atlas.
    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom(weight == .medium ? "JetBrainsMono-Medium" : "JetBrainsMono-Regular",
                size: size, relativeTo: anchor(size))
    }

    private static func anchor(_ size: CGFloat) -> Font.TextStyle {
        switch size {
        case 28...: return .largeTitle
        case 22..<28: return .title2
        case 17..<22: return .body
        case 14..<17: return .callout
        case 12..<14: return .footnote
        default: return .caption2
        }
    }
}
