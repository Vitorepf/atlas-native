import SwiftUI
import AtlasCore

// History loaded body — peel de AutonomosFleetHistory.

extension AutonomosFleetHistorySection {
    var historyLoadedBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            // A legenda conta o total: mostrar 6 de N sem dizer N faz o operador
            // ler "6" como "tudo". Nada cortado em silêncio.
            AutonomosChrome.sectionCaption(history.events.count > AutonomosFleetHistoryA11y.visibleCap
                           ? "HISTÓRICO DA FROTA · 6 DE \(history.events.count)"
                           : "HISTÓRICO DA FROTA")
            ForEach(Array(visibleEvents.enumerated()), id: \.element.id) { index, event in
                historyEventRow(event: event, index: index, visibleCount: visibleEvents.count)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AutonomosFleetHistoryA11y.spokenSection(total: history.events.count))
        .accessibilityIdentifier(A11yID.autonomosFleetHistorySection)
    }
}
