import SwiftUI

/// Spoken labels dos controles de instância — peel de AutonomosAreaControls.

extension AutonomosAreaControls {
    var spokenContainerLabel: String {
        if canControl {
            return "controles da instância \(areaName)"
        }
        return "controles indisponíveis, instância \(areaName) não registrada"
    }

    var spokenContainerHint: String {
        canControl
            ? "pausar, transferir, encerrar ou iniciar ciclo"
            : "controles bloqueados até a instância estar registrada no servidor"
    }
}
