import SwiftUI
import AtlasCore

// History section — peel shell.
// Loaded → AutonomosFleetHistory+Loaded.swift

struct AutonomosFleetHistorySection: View {
    let history: AtlasAutonomosFleetHistoryResponse

    var visibleEvents: [AtlasAutonomosFleetHistoryEvent] {
        Array(history.events.prefix(AutonomosFleetHistoryA11y.visibleCap))
    }

    var body: some View {
        if history.events.isEmpty {
            AutonomosFleetEmptyState(kind: .noHistory)
        } else {
            historyLoadedBody
        }
    }
}
