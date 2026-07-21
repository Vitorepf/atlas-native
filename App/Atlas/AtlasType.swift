import SwiftUI
import UIKit

// Cycle 044 fuse → AtlasType.swift

// Tipografia do Atlas: Fraunces (serif editorial) pro masthead e títulos — a
// identidade do app original — com SF Pro no corpo/listas (clareza estilo Cursor).
//
// DYNAMIC TYPE: todo Font.custom sai com `relativeTo:` — a tipografia inteira
// escala com o ajuste de texto do operador (acessibilidade não é opcional).
enum AtlasFont {
    /// Serif Fraunces. Só SemiBold é usado na casca (28/28); Regular é o
    /// fallback do default — Bold/Medium foram podados (0 chamadas).
    static func serif(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        let name: String
        switch weight {
        case .semibold: name = "Fraunces-SemiBold"
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
}

extension AtlasFont {
    static func anchorLarge(_ size: CGFloat) -> Font.TextStyle? {
        switch size {
        case 28...: return .largeTitle
        case 22..<28: return .title2
        case 17..<22: return .body
        default: return nil
        }
    }
}

extension AtlasFont {
    static func anchorSmall(_ size: CGFloat) -> Font.TextStyle {
        switch size {
        case 14..<17: return .callout
        case 12..<14: return .footnote
        default: return .caption2
        }
    }
}

extension AtlasFont {
    static func anchor(_ size: CGFloat) -> Font.TextStyle {
        anchorLarge(size) ?? anchorSmall(size)
    }
}

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

extension AtlasFont {
    static func uiTextStyle(_ style: Font.TextStyle) -> UIFont.TextStyle {
        switch style {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        default: return .body
        }
    }

    static func contentCategory(_ typeSize: DynamicTypeSize) -> UIContentSizeCategory {
        switch typeSize {
        case .xSmall: return .extraSmall
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        case .xLarge: return .extraLarge
        case .xxLarge: return .extraExtraLarge
        case .xxxLarge: return .extraExtraExtraLarge
        case .accessibility1: return .accessibilityMedium
        case .accessibility2: return .accessibilityLarge
        case .accessibility3: return .accessibilityExtraLarge
        case .accessibility4: return .accessibilityExtraExtraLarge
        case .accessibility5: return .accessibilityExtraExtraExtraLarge
        @unknown default: return .large
        }
    }
}

//
// UIFontMetrics/UIFont em body corrompia heap: o engine de acessibilidade
// avalia bodies fora da main e UIKit não é thread-safe (SIGSEGV com sítio
// aleatório na bateria XCUITest). A curva oficial da Apple é lida UMA vez,
// na main, no launch (AtlasApp força `prime()`); depois o sans é lookup puro.

@MainActor
enum AtlasSansScale {
    private static var table: [UIFont.TextStyle: [DynamicTypeSize: CGFloat]] = [:]

    /// Chamar no launch (main). Idempotente.
    static func prime() {
        guard table.isEmpty else { return }
        let styles: [UIFont.TextStyle] = [
            .largeTitle, .title1, .title2, .title3, .headline, .subheadline,
            .body, .callout, .footnote, .caption1, .caption2,
        ]
        for style in styles {
            let metrics = UIFontMetrics(forTextStyle: style)
            var row: [DynamicTypeSize: CGFloat] = [:]
            for typeSize in DynamicTypeSize.allCases {
                let traits = UITraitCollection(
                    preferredContentSizeCategory: AtlasFont.contentCategory(typeSize))
                row[typeSize] = metrics.scaledValue(for: 100, compatibleWith: traits) / 100
            }
            table[style] = row
        }
    }

    static func factor(_ style: UIFont.TextStyle, _ typeSize: DynamicTypeSize) -> CGFloat {
        prime()
        return table[style]?[typeSize] ?? 1
    }
}
