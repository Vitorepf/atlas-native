import SwiftUI
import AtlasCore

// Alvo section — peel de AutonomosTransferSheet+Operator.

extension AutonomosTransferSheet {
    @ViewBuilder
    var transferOperatorTargetSection: some View {
        Section("Alvo") {
            Text("Desconhecido até target_claimed. A fila escolhe o worker; este app não promete host futuro.")
                .font(.footnote).foregroundStyle(.secondary)
                .accessibilityLabel(AutonomosTransferSheetA11yConfirm.spokenTargetUnknown)
                .accessibilityHint(AutonomosTransferSheetA11yConfirm.targetHint)
        }
    }
}
