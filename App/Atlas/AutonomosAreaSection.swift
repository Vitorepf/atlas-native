import SwiftUI

/// C13: disponibilidade vem de canControlSelectedArea (POSTs existem e são
/// governados) — nunca de live.readOnly, que descreve apenas o GET.
/// Cycle → AutonomosAreaSection+Cycle.swift
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
    @Environment(\.accessibilityReduceMotion) var reduceMotion

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
            cycleButtons
        }
        .disabled(!canControl)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(spokenContainerLabel)
        .accessibilityHint(spokenContainerHint)
        .accessibilityIdentifier(A11yID.autonomosAreaControls)
    }
}
