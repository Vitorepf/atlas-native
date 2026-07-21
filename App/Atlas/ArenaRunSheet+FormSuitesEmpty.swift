import SwiftUI
import AtlasCore

// Suites empty — peel de ArenaRunSheet+FormSuites.

extension ArenaRunSheet {
    var suitesEmptyLabel: some View {
        Text("nenhuma suite com adapter instalado")
            .font(AtlasFont.serifItalic(14))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityIdentifier(A11yID.arenaRunSuitesEmpty)
            .accessibilityLabel(spokenEmptySuites())
    }
}
