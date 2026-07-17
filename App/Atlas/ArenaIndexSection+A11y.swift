import Foundation
import AtlasCore

/// Spoken labels do índice Arena — peel de ArenaIndexSection (régua ≤100).

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

    func engineRowSpoken(_ engine: AtlasArenaCompositeEngine) -> String {
        let delta = engine.delta.map { ", variação \(ArenaFormat.signed($0))" } ?? ""
        let partial = engine.isPartialCoverage
            ? ", cobertura parcial \(Int((engine.coverage * 100).rounded())) por cento" : ""
        return "\(engine.engine), composto \(ArenaFormat.score(engine.composite))\(delta)\(partial)"
    }
}
