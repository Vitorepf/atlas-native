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
            // Home NÃO fala de regressão (ordem 2026-07-18, repetida): a linha
            // é limpa; o assunto vive DENTRO da Arena.
            a11yID: A11yID.arenaHomeEntry,
            spokenOverride: arenaSpokenLabel(
                regression: nil,
                domainUnavailable: session.arena.isDomainUnavailable
            ),
            spokenHint: "abre medição de regressão"
        ) {
            onNavigate(.arena)
        }
    }
}
