import SwiftUI

// Botões pausar/retomar/transferir/encerrar — peel de AutonomosAreaControls.
// Secondary → AutonomosAreaSection+PrimarySecondary.swift
// Pause → AutonomosAreaSection+PrimaryPause.swift

extension AutonomosAreaControls {
    var primaryButtons: some View {
        HStack(spacing: 8) {
            pauseResumeButton
            secondaryActionButtons
        }
    }
}
