import SwiftUI
import Charts
import AtlasCore

// Partial coverage — peel de ArenaEngineIndexRow+Title.

extension ArenaEngineIndexRow {
    @ViewBuilder
    var partialCoverageLine: some View {
        if engine.isPartialCoverage {
            Text("cobertura parcial \(Int((engine.coverage * 100).rounded()))%")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
