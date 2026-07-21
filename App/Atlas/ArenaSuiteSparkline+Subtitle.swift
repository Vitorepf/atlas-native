import SwiftUI
import Charts
import AtlasCore

/// Suite subtitle — peel de ArenaSuiteSparkline.

extension AtlasArenaSuite {
    var arenaSubtitleText: String {
        guard isMeasured else { return "não medido" }
        let rounds = runsTotal == 1 ? "1 rodada" : "\(runsTotal) rodadas"
        if let relative = ArenaDisplay.relative(lastRunAt) { return "\(rounds) · \(relative)" }
        return rounds
    }
}
