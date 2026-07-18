import SwiftUI
import AtlasCore

// Suites + run button — peel de AtlasArenaView+Loaded.

extension AtlasArenaView {
    @ViewBuilder
    func loadedArenaTail(_ composite: AtlasArenaComposite) -> some View {
        if let scoreboard = model.scoreboard, !scoreboard.suites.isEmpty {
            // O operador vive das CAPACIDADES; a lista de benchmarks é
            // bastidor — uma linha, expande a pedido. Regressão fura o colapso.
            let regressed = scoreboard.suites.filter { $0.engines.contains(where: \.regressed) }.count
            AutonomosDigestToggleLine(
                title: "suítes",
                detail: "\(scoreboard.suites.count) medidas\(regressed > 0 ? " · \(regressed) em regressão" : "")",
                expanded: $suitesExpanded,
                a11yID: A11yID.arenaSuitesToggle
            )
            // Regressão NÃO força as 10 suítes abertas: o banner do topo já
            // grita a exceção e a linha acima a diz — a lista abre a pedido.
            if suitesExpanded {
                ArenaSuitesSection(
                    scoreboard: scoreboard,
                    reduceMotion: reduceMotion,
                    onSuiteTap: { selectedSuite = $0 }
                )
            }
        }
        runMeasurementButton
    }
}
