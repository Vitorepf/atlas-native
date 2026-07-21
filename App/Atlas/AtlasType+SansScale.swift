import SwiftUI
import UIKit

// Cycle 040 fuse → AtlasType+SansScale.swift

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
