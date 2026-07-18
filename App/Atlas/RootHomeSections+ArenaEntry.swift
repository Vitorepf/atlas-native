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
            detail: session.arena.regressionSummary,
            badge: session.arena.regressionSummary != nil,
            a11yID: A11yID.arenaHomeEntry,
            spokenOverride: arenaSpokenLabel(
                regression: session.arena.regressionSummary,
                domainUnavailable: session.arena.isDomainUnavailable
            ),
            spokenHint: "abre medição de regressão"
        ) {
            onNavigate(.arena)
        }
    }
}
