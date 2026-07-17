import SwiftUI
import AtlasCore

// Lock section — peel de AutonomosTransferSheet+Form.

extension AutonomosTransferSheet {
    @ViewBuilder
    var transferLockSection: some View {
        Section("Lock atual (verificado)") {
            if hasPlacement {
                placementFields
            } else {
                Text("Nenhum lock publicado neste recorte — a transferência exige lease vivo.")
                    .font(.footnote).foregroundStyle(.secondary)
                    .accessibilityLabel(AutonomosTransferSheetA11yConfirm.spokenNoLock)
            }
        }
    }
}
