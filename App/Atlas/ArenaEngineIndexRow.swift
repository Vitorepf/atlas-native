import SwiftUI
import Charts
import AtlasCore

// Linha de engine no índice composto — peel de ArenaIndexSection (régua ~120).

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
                Spacer(minLength: 8)
                Text(ArenaFormat.score(engine.composite))
                    .font(AtlasFont.mono(18))
                    .foregroundStyle(engine.composite == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                Text(ArenaFormat.signed(engine.delta))
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(deltaColor(engine.delta))
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
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
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private func metric(_ label: String, _ value: String, color: Color) -> some View {
        Text("\(label) \(value)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(color)
            .monospacedDigit()
    }

    private func metricColor(_ value: Double?, fallback: Color = AtlasTheme.accent) -> Color {
        value == nil ? AtlasTheme.textTertiary : fallback
    }

    private func deltaColor(_ delta: Double?) -> Color {
        guard let delta else { return AtlasTheme.textTertiary }
        return delta < 0 ? AtlasTheme.alert : AtlasTheme.accent
    }

    private var accessibilityText: String {
        var parts = ["\(engine.engine), composto \(ArenaFormat.score(engine.composite))"]
        if let delta = engine.delta {
            parts.append("variação \(ArenaFormat.signed(delta))")
        }
        parts.append("com Atlas \(ArenaFormat.score(engine.withAtlasComposite))")
        if let multiplier = engine.atlasMultiplier {
            parts.append("multiplicador \(ArenaFormat.multiplier(multiplier))")
        }
        if engine.isPartialCoverage {
            parts.append("cobertura parcial \(Int((engine.coverage * 100).rounded())) por cento")
        }
        return parts.joined(separator: ", ")
    }
}
