import SwiftUI
import AtlasCore

// Engine card header — peel de ArenaSuiteSheet+EngineCard.

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCardHeader(_ engine: AtlasArenaSuiteEngine) -> some View {
        HStack {
            Text(ArenaDisplay.engine(engine.engine))
                .font(.system(.headline))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Spacer()
            engineCardScore(engine)
        }
    }
}
