import SwiftUI
import AtlasCore

// Commit a11y hint — peel de AtlasCodeCommitRow+Meta.

extension AtlasCodeCommitRow {
    var commitAccessibilityHint: String {
        guard !isDimmed else { return "" }
        if onAsk != nil {
            return "abre proveniência; arraste para a esquerda para usar na pílula"
        }
        if onLongPress != nil { return "abre proveniência do commit; pressione e segure para opções" }
        return "abre proveniência do commit"
    }
}
