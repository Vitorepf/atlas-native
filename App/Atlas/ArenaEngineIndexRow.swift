import SwiftUI
import Charts
import AtlasCore

// Linha de engine no índice composto — peel de ArenaIndexSection (régua ~120).
// Metric/a11y → ArenaEngineIndexRow+A11y.swift

struct ArenaEngineIndexRow: View {
    let engine: AtlasArenaCompositeEngine
    let reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            HStack(spacing: 10) {
                metric("c/Atlas", ArenaFormat.score(engine.withAtlasComposite), color: metricColor(engine.withAtlasComposite))
                metric("sem", ArenaFormat.score(engine.withoutAtlasComposite), color: metricColor(engine.withoutAtlasComposite, fallback: AtlasTheme.textSecondary))
                if engine.atlasMultiplier != nil {
                    metric("N×M", ArenaFormat.multiplier(engine.atlasMultiplier), color: AtlasTheme.textPrimary)
                }
            }
            if engine.isPartialCoverage {
                Text("cobertura parcial \(Int((engine.coverage * 100).rounded()))%")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }
}
