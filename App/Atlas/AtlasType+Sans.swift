import SwiftUI
import UIKit

// SF Pro com Dynamic Type — peel de AtlasType.
//
// `.font(.system(size:))` é FIXO: ignora o ajuste de texto do operador.
// `.atlasSans(size, weight)` ancora o tamanho na mesma régua do serif/mono
// (anchor) e escala via UIFontMetrics com a categoria lida do environment —
// na régua padrão o resultado é pixel-idêntico ao que era.

extension View {
    func atlasSans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> some View {
        modifier(AtlasSansFont(size: size, weight: weight))
    }
}

struct AtlasSansFont: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize
    let size: CGFloat
    let weight: Font.Weight

    func body(content: Content) -> some View {
        content.font(AtlasFont.sans(size, weight: weight, at: typeSize))
    }
}

extension AtlasFont {
    /// SF escalado por categoria explícita (o modifier entrega a do environment).
    /// Lookup puro na curva pré-computada — zero UIKit em body.
    @MainActor
    static func sans(_ size: CGFloat, weight: Font.Weight, at typeSize: DynamicTypeSize) -> Font {
        .system(size: size * AtlasSansScale.factor(uiTextStyle(anchor(size)), typeSize),
                weight: weight)
    }
}
