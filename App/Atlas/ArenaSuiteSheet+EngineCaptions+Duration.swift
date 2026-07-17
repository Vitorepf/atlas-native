import SwiftUI
import AtlasCore

// Duration caption — peel de ArenaSuiteSheet+EngineCaptions.

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineDurationCaption(_ engine: AtlasArenaSuiteEngine) -> some View {
        if let duration = ArenaSuiteSheetA11yCaptions.durationCaption(for: engine) {
            Text(duration)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
