import SwiftUI
import AtlasCore

// Operator sections — peel de AutonomosTransferSheet+Form.

extension AutonomosTransferSheet {
    @ViewBuilder
    var transferOperatorSections: some View {
        Section("Alvo") {
            Text("Desconhecido até target_claimed. A fila escolhe o worker; este app não promete host futuro.")
                .font(.footnote).foregroundStyle(.secondary)
                .accessibilityLabel(AutonomosTransferSheetA11yConfirm.spokenTargetUnknown)
                .accessibilityHint(AutonomosTransferSheetA11yConfirm.targetHint)
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
