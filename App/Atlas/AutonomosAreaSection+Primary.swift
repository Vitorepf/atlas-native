import SwiftUI

// Botões pausar/retomar/transferir/encerrar — peel de AutonomosAreaControls.
// Secondary → AutonomosAreaSection+PrimarySecondary.swift

extension AutonomosAreaControls {
    var primaryButtons: some View {
        HStack(spacing: 8) {
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
            secondaryActionButtons
        }
    }
}
