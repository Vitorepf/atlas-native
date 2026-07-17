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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
            HStack(spacing: 8) {
                Button("Novo ciclo · ensaio") { tap(onDryRun) }
                    .buttonStyle(AutonomosPrimaryButtonStyle())
                    .accessibilityLabel(spoken("novo ciclo ensaio, \(areaName)"))
                    .accessibilityHint(hint("inicia ciclo de ensaio sem efeito real"))
                Button("Executar de verdade") { tap(onExecute) }
                    .buttonStyle(AutonomosSecondaryButtonStyle())
                    .accessibilityLabel(spoken("executar de verdade, \(areaName)"))
                    .accessibilityHint(hint("inicia ciclo real com governança"))
            }
        }
        .disabled(!canControl)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(spokenContainerLabel)
        .accessibilityHint(spokenContainerHint)
        .accessibilityIdentifier(A11yID.autonomosAreaControls)
    }

    private func tap(_ action: () -> Void) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        action()
    }

    private func spoken(_ label: String) -> String {
        canControl ? label : "\(label), indisponível"
    }

    private func hint(_ text: String) -> String {
        canControl ? text : spokenContainerHint
    }
}
