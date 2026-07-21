import SwiftUI
import AtlasCore

// Empty engines — peel de ArenaRunSheet+FormEngine.

extension ArenaRunSheet {
    @ViewBuilder
    var engineFormEmpty: some View {
        Text("nenhum motor publicado")
            .font(.system(.subheadline))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityIdentifier(A11yID.arenaRunEnginesEmpty)
            .accessibilityLabel(spokenEmptyEngines())
    }
}
