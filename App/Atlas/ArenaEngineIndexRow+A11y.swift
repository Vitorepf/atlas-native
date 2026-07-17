import SwiftUI
import AtlasCore

// Cores + spoken — peel de ArenaEngineIndexRow.
// Spoken → ArenaEngineIndexRow+A11ySpoken.swift

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
}
