import Foundation
import AtlasCore

/// Spoken do gráfico composto — peel de ArenaCompositeChart (CICLO C).
/// Séries e rodadas só quando o histórico publica valores.

enum ArenaCompositeChartA11y {
    static func spokenChart(_ engine: AtlasArenaCompositeEngine) -> String {
        let plotted = engine.history.filter {
            $0.composite != nil || $0.withAtlas != nil || $0.withoutAtlas != nil
        }
        guard !plotted.isEmpty else { return "" }
        var parts = ["gráfico de histórico do motor \(engine.engine)"]
        let rounds = plotted.count
        parts.append(rounds == 1 ? "1 rodada" : "\(rounds) rodadas")
        if plotted.contains(where: { $0.composite != nil }) { parts.append("linha composta") }
        if plotted.contains(where: { $0.withAtlas != nil }) { parts.append("linha com Atlas") }
        if plotted.contains(where: { $0.withoutAtlas != nil }) { parts.append("linha sem Atlas") }
        return parts.joined(separator: ", ")
    }
}
