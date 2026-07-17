import SwiftUI

// Pause/resume toggle — peel de AutonomosAreaSection+Primary.

extension AutonomosAreaControls {
    @ViewBuilder
    var pauseResumeButton: some View {
        if isPaused {
            Button("Retomar") { tap(onResume) }
                .buttonStyle(AutonomosPrimaryButtonStyle())
                .accessibilityLabel(spoken("retomar \(areaName)"))
                .accessibilityHint(hint("retoma a instância pausada"))
        } else {
            Button("Pausar") { tap(onPause) }
                .buttonStyle(AutonomosSecondaryButtonStyle())
                .accessibilityLabel(spoken("pausar \(areaName)"))
                .accessibilityHint(hint("pausa a instância sem encerrar"))
        }
    }
}
