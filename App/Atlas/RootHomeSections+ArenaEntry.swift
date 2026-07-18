import SwiftUI
import AtlasCore

// Arena entry row — peel de RootHomeSections+Operacao.
// A11y → RootHomeSections+ArenaEntry+A11y.swift

extension RootHomeSections {
    @ViewBuilder
    var arenaEntryRow: some View {
        WorkspaceRow(
            icon: "chart.line.uptrend.xyaxis",
            name: "Arena",
            count: nil,
            detail: session.arena.regressionException,
            badge: session.arena.regressionException != nil,
            a11yID: A11yID.arenaHomeEntry,
            spokenOverride: arenaSpokenLabel(
                regression: session.arena.regressionException,
                domainUnavailable: session.arena.isDomainUnavailable
            ),
            spokenHint: "abre medição de regressão"
        ) {
            onNavigate(.arena)
        }
    }
}
