import SwiftUI
import Charts
import AtlasCore

// Title + score row — peel de ArenaEngineIndexRow.
// Coverage → ArenaEngineIndexRow+Coverage.swift

extension ArenaEngineIndexRow {
    var titleRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(engine.engine)
                .font(.system(.body, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityHidden(true)
            Spacer(minLength: 8)
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
