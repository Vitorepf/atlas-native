import SwiftUI
import AtlasCore

// Meta obrigatória: branch · autor · tempo (lei do operador 2026-07-19).
// Law de violação continua como 4º token quando existe — exceção, não substituto.

extension AtlasCodeCommitRow {
    @ViewBuilder
    var commitMetaAuthorTime: some View {
        Text(displayBranch)
            .foregroundStyle(branchMetaColor)
            .accessibilityHidden(true)
        Text("·")
            .accessibilityHidden(true)
        Text(displayAuthor)
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
        Text("·")
            .accessibilityHidden(true)
        Text(AtlasCodeRelativeTime.short(from: node.authoredAt))
            .accessibilityHidden(true)
    }

    private var branchMetaColor: Color {
        switch state {
        case .violating: return AtlasCodePalette.alert
        case .onMain, .healed: return AtlasTheme.accent
        case .history: return AtlasTheme.prussian
        }
    }
}
