import SwiftUI
import AtlasCore

// Cores + spoken — peel de ArenaEngineIndexRow.

extension ArenaEngineIndexRow {
    func metric(_ label: String, _ value: String, color: Color) -> some View {
        Text("\(label) \(value)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(color)
            .monospacedDigit()
            .accessibilityHidden(true)
    }

    func metricColor(_ value: Double?, fallback: Color = AtlasTheme.accent) -> Color {
        value == nil ? AtlasTheme.textTertiary : fallback
    }

    func deltaColor(_ delta: Double?) -> Color {
        guard let delta else { return AtlasTheme.textTertiary }
        return delta < 0 ? AtlasTheme.alert : AtlasTheme.accent
    }

    var accessibilityText: String {
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
