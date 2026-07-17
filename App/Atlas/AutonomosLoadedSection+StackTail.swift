import SwiftUI
import AtlasCore

// Cauda frota/saúde/histórico/erro — peel de AutonomosLoadedSection+Stack.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackTail: some View {
        runReceiptLines
        if let fleet = model.fleet {
            AutonomosFleetSection(
                fleet: fleet,
                incidentPresent: model.taskHealth?.incidents.present == true,
                auditModeEnabled: auditModeEnabled
            )
        }
        if let health = model.taskHealth {
            AutonomosTaskHealthSection(health: health)
        }
        if let history = model.fleetHistory {
            AutonomosFleetHistorySection(history: history)
        }
        if let error = model.controlError {
            AutonomosErrorCard(message: error)
                .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 6)))
        }
    }
}
