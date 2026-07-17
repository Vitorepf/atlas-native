import SwiftUI
import AtlasCore

// Seção OPERAÇÃO — peel de RootHomeSections+Loaded.

extension RootHomeSections {
    @ViewBuilder
    var operacaoSection: some View {
        sectionLabel("OPERAÇÃO", accessibilityID: A11yID.homeOperacaoSection)
        WorkspaceRow(icon: "bolt.horizontal.circle", name: "Autônomos", count: nil) {
            onNavigate(.autonomos)
        }
        .accessibilityLabel("Autônomos, abre frota e digest")
        .accessibilityIdentifier(A11yID.homeAutonomosEntry)
        rowDivider
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
