import SwiftUI
import AtlasCore

// Replay spoken collapsed — peel de ExecutionProof+Replay.
// Metrics → ExecutionProof+ReplaySpokenCollapse+Metrics.swift

extension ExecutionProof {
    var spokenCollapsed: String {
        spokenCollapsed(expanded: false)
    }

    func spokenCollapsed(expanded: Bool) -> String {
        (
            ["prova da execução", expanded ? "expandida" : "recolhida"]
            + spokenCollapsedMetricsParts()
        ).joined(separator: ", ")
    }
}
