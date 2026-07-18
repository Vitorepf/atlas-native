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
            // Sem ponto vermelho (ordem 2026-07-18): a sublinha "N regressões"
            // é o sinal — dois avisos para o mesmo fato é ruído.
            detail: session.arena.regressionSummary,
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
