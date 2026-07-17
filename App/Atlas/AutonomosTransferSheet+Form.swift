import SwiftUI
import AtlasCore

// Form sections — peel de AutonomosTransferSheet (régua ≤100).

extension AutonomosTransferSheet {
    @ViewBuilder
    var transferForm: some View {
        Form {
            Section("Missão (preservada)") {
                Text(areaName)
                    .accessibilityLabel(AutonomosTransferSheetA11y.spokenMission(areaName))
                Text(focus).font(AtlasFont.mono(11)).foregroundStyle(.secondary)
                    .accessibilityLabel(AutonomosTransferSheetA11y.spokenFocus(focus))
            }
            Section("Lock atual (verificado)") {
                if hasPlacement {
                    placementFields
                } else {
                    Text("Nenhum lock publicado neste recorte — a transferência exige lease vivo.")
                        .font(.footnote).foregroundStyle(.secondary)
                        .accessibilityLabel(AutonomosTransferSheetA11y.spokenNoLock)
                }
            }
            if hasPlacement {
                Section("Alvo") {
                    Text("Desconhecido até target_claimed. A fila escolhe o worker; este app não promete host futuro.")
                        .font(.footnote).foregroundStyle(.secondary)
                        .accessibilityLabel(AutonomosTransferSheetA11y.spokenTargetUnknown)
                        .accessibilityHint(AutonomosTransferSheetA11y.targetHint)
                }
                Section("Operador") {
                    TextField("Quem autoriza", text: $actor)
                        .accessibilityIdentifier(A11yID.autonomosTransferActor)
                        .accessibilityHint("nome de quem autoriza a transferência")
                }
                Section("Motivo") {
                    TextField("Motivo auditável", text: $reason, axis: .vertical).lineLimit(3...6)
                        .accessibilityIdentifier(A11yID.autonomosTransferReason)
                        .accessibilityHint("motivo público registrado no ledger")
                }
            }
        }
    }
}
