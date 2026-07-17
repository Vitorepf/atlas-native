import SwiftUI
import AtlasCore

// Metric color helpers — peel de ArenaEngineIndexRow+A11y.

extension ArenaEngineIndexRow {
    func metricColor(_ value: Double?, fallback: Color = AtlasTheme.accent) -> Color {
        value == nil ? AtlasTheme.textTertiary : fallback
    }

    func deltaColor(_ delta: Double?) -> Color {
        guard let delta else { return AtlasTheme.textTertiary }
        return delta < 0 ? AtlasTheme.alert : AtlasTheme.accent
    }
}
