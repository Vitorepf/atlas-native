import SwiftUI
import UIKit
import AtlasCore

// Copy style — peel de AtlasMarkdownView+CodeBlock+Copy.
// Metrics → AtlasMarkdownView+CodeBlock+Copy+Metrics.swift

extension CodeBlockView {
    var copyButtonTitle: String {
        guard canCopy else { return "copiar" }
        return copied ? "copiado" : "copiar"
    }

    var copyForeground: Color {
        guard canCopy else { return AtlasTheme.textTertiary.opacity(0.5) }
        return copied ? AtlasTheme.accent : AtlasTheme.textSecondary
    }
}
