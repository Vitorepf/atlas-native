import SwiftUI
import Charts
import AtlasCore

/// Sparkline compartilhado pela row e por `ArenaSuiteSheet` (módulo interno).
/// Subtitle → ArenaSuiteSparkline+Subtitle.swift
struct SuiteSparkline: View {
    let engine: AtlasArenaSuiteEngine

    var body: some View {
        Chart(engine.history) { point in
            if let score = point.score {
                LineMark(x: .value("rodada", point.roundAt), y: .value("score", score))
                    .foregroundStyle(point.arm == .withAtlas ? AtlasTheme.accent : AtlasTheme.textSecondary)
                    .interpolationMethod(.linear)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .accessibilityHidden(true)
    }
}
