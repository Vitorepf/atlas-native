import SwiftUI
import AtlasCore

// Arena entry row — peel de RootHomeSections+Operacao.

extension RootHomeSections {
    @ViewBuilder
    var arenaEntryRow: some View {
        WorkspaceRow(
            icon: "chart.line.uptrend.xyaxis",
            name: "Arena",
            count: nil,
            detail: session.arena.regressionException,
            badge: session.arena.regressionException != nil
        ) {
            onNavigate(.arena)
        }
        .accessibilityLabel(arenaSpokenLabel(
            regression: session.arena.regressionException,
            domainUnavailable: session.arena.isDomainUnavailable
        ))
        .accessibilityHint("abre medição de regressão")
        .accessibilityIdentifier(A11yID.arenaHomeEntry)
    }
}
