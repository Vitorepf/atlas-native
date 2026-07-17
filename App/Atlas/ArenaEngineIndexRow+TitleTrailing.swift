import SwiftUI
import Charts
import AtlasCore

// Score + delta trailing — peel de ArenaEngineIndexRow+Title.

extension ArenaEngineIndexRow {
    var titleTrailing: some View {
        HStack(spacing: 10) {
            Text(ArenaFormat.score(engine.composite))
                .font(AtlasFont.mono(18))
                .foregroundStyle(engine.composite == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
            Text(ArenaFormat.signed(engine.delta))
                .font(AtlasFont.mono(12))
                .foregroundStyle(deltaColor(engine.delta))
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }
}
