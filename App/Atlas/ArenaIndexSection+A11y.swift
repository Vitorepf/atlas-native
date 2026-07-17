import Foundation
import AtlasCore

/// Spoken labels do índice Arena — peel de ArenaIndexSection (régua ≤100).
/// Engine → ArenaIndexSection+A11yEngine.swift

extension ArenaIndexSection {
    var sectionSpokenLabel: String {
        var parts = ["índice composto, \(composite.engines.count) motores", coverageCaption]
        if !composite.weightsPublic.isEmpty {
            parts.append("\(composite.weightsPublic.count) pesos públicos")
        }
        if let engine = chartEngine {
            let chartSpoken = ArenaCompositeChartA11y.spokenChart(engine)
            if !chartSpoken.isEmpty { parts.append(chartSpoken) }
        }
        return parts.joined(separator: ", ")
    }
}
