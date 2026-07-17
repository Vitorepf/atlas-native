import SwiftUI
import AtlasCore

// Arena entry row — peel de RootHomeSections+Operacao.
// A11y → RootHomeSections+ArenaEntry+A11y.swift

extension RootHomeSections {
    @ViewBuilder
    var arenaEntryRow: some View {
        arenaEntryA11y(
            WorkspaceRow(
                icon: "chart.line.uptrend.xyaxis",
                name: "Arena",
                count: nil,
                detail: session.arena.regressionException,
                badge: session.arena.regressionException != nil
            ) {
                onNavigate(.arena)
            }
        )
    }
}
