import SwiftUI
import AtlasCore

// Fleet empty wrapper — peel de AutonomosChrome+Empty.
// Copy → AutonomosChrome+FleetEmptyCopy.swift

struct AutonomosFleetEmptyState: View {
    enum Kind { case noAgents, noHistory }

    let kind: Kind

    var body: some View {
        AutonomosCardEmptyState(
            caption: kind == .noAgents ? "frota" : "histórico",
            copy: copy,
            accessibilityIdentifier: kind == .noAgents ? A11yID.autonomosFleetEmpty : A11yID.autonomosFleetHistoryEmpty
        )
    }
}
