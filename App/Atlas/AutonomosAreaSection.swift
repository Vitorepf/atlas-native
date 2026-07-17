import SwiftUI

/// C13: disponibilidade vem de canControlSelectedArea (POSTs existem e são
/// governados) — nunca de live.readOnly, que descreve apenas o GET.
struct AutonomosAreaControls: View {
    let areaName: String
    let isPaused: Bool
    let canControl: Bool
    let onResume: () -> Void
    let onPause: () -> Void
    let onTransfer: () -> Void
    let onKill: () -> Void
    let onDryRun: () -> Void
    let onExecute: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if isPaused {
                    Button("Retomar", action: onResume).buttonStyle(AutonomosPrimaryButtonStyle())
                } else {
                    Button("Pausar", action: onPause).buttonStyle(AutonomosSecondaryButtonStyle())
                }
                Button("Transferir", action: onTransfer).buttonStyle(AutonomosSecondaryButtonStyle())
                Button("Encerrar", action: onKill).buttonStyle(AutonomosDestructiveButtonStyle())
            }
            HStack(spacing: 8) {
                Button("Novo ciclo · ensaio", action: onDryRun)
                    .buttonStyle(AutonomosPrimaryButtonStyle())
                Button("Executar de verdade", action: onExecute)
                    .buttonStyle(AutonomosSecondaryButtonStyle())
            }
        }
        .disabled(!canControl)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(spokenContainerLabel)
        .accessibilityHint(spokenContainerHint)
        .accessibilityIdentifier(A11yID.autonomosAreaControls)
    }
}
