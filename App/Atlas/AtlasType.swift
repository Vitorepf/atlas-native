import SwiftUI

// Tipografia do Atlas: Fraunces (serif editorial) pro masthead e títulos — a
// identidade do app original — com SF Pro no corpo/listas (clareza estilo Cursor).
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
        return .custom(name, size: size)
    }

    static func serifItalic(_ size: CGFloat) -> Font {
        .custom("Fraunces-Italic", size: size)
    }
}
