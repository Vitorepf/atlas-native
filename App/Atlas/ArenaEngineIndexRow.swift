import SwiftUI
import Charts
import AtlasCore

// Linha de engine no índice composto — peel de ArenaIndexSection (régua ~120).
// Metric/a11y → +A11y · Metrics → +Metrics.swift · Title → +Title.swift

struct ArenaEngineIndexRow: View {
    let engine: AtlasArenaCompositeEngine
    let reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleRow
            metricsRow
            partialCoverageLine
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }
}
