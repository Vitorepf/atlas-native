import SwiftUI
import UIKit
import AtlasCore

// Copy helpers — peel de CodeBlockView.
// Action → AtlasMarkdownView+CodeBlock+CopyAction.swift

extension CodeBlockView {
    var lineCount: Int {
        guard !code.isEmpty else { return 0 }
        return code.split(separator: "\n", omittingEmptySubsequences: false).count
    }

    var canCopy: Bool { !code.isEmpty }

    var copyButtonTitle: String {
        guard canCopy else { return "copiar" }
        return copied ? "copiado" : "copiar"
    }

    var copyForeground: Color {
        guard canCopy else { return AtlasTheme.textTertiary.opacity(0.5) }
        return copied ? AtlasTheme.accent : AtlasTheme.textSecondary
    }
}
