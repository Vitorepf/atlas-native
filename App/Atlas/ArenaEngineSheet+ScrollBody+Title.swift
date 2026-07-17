import SwiftUI
import AtlasCore

// Engine title — peel de ArenaEngineSheet+ScrollBody.

extension ArenaEngineSheet {
    var engineScrollTitle: some View {
        Text(engine.engine)
            .font(.system(.title2, weight: .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(ArenaEngineSheetA11y.spokenEngineTitle(engine.engine))
    }
}
