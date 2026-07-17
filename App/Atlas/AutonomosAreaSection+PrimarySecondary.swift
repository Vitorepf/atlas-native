import SwiftUI

// Transfer/Encerrar — peel de AutonomosAreaSection+Primary.

extension AutonomosAreaControls {
    var secondaryActionButtons: some View {
        HStack(spacing: 8) {
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
