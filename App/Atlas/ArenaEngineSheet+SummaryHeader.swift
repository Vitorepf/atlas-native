import SwiftUI
import Charts
import AtlasCore

// Engine summary header — peel de ArenaEngineSheet+Summary.

extension ArenaEngineSheet {
    var engineSummaryHeader: some View {
        HStack {
            Text("composto")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
            Text(ArenaFormat.score(engine.composite))
                .font(AtlasFont.mono(20))
                .foregroundStyle(engine.composite == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
                .accessibilityHidden(true)
        }
    }
}
