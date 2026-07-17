import SwiftUI

// Botões pausar/retomar/transferir/encerrar — peel de AutonomosAreaControls.

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
            Button("Transferir") { tap(onTransfer) }
                .buttonStyle(AutonomosSecondaryButtonStyle())
                .accessibilityLabel(spoken("transferir \(areaName)"))
                .accessibilityHint(hint("abre a transferência governada"))
            Button("Encerrar") { tap(onKill) }
                .buttonStyle(AutonomosDestructiveButtonStyle())
                .accessibilityLabel(spoken("encerrar \(areaName)"))
                .accessibilityHint(hint("encerra a instância com recibo"))
        }
    }
}
