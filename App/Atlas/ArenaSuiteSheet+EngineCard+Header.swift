import SwiftUI
import AtlasCore

// Engine card header — peel de ArenaSuiteSheet+EngineCard.

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCardHeader(_ engine: AtlasArenaSuiteEngine) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(ArenaDisplay.engine(engine.engine))
                    .font(AtlasFont.serif(21))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("Índice da suíte · escala 0–10")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .accessibilityHidden(true)
            Spacer()
            engineCardScore(engine)
        }
    }
}
