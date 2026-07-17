import SwiftUI
import AtlasCore

/// Frota global — quiet line — peel de AutonomosFleetSection+Summary.

extension AutonomosFleetSummary {
    var quietSummaryLine: some View {
        Text("\(fleet.agents.count) agente\(fleet.agents.count == 1 ? "" : "s") · \(fleet.activeCount) ativo\(fleet.activeCount == 1 ? "" : "s") · silêncio")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("frota quieta, \(fleet.agents.count) agentes, \(fleet.activeCount) ativos")
            .accessibilityIdentifier(A11yID.autonomosFleetQuiet)
    }
}
