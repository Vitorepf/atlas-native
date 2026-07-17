import SwiftUI
import AtlasCore

// Transfer confirm toolbar item — peel de AutonomosTransferSheet+Toolbar.

extension AutonomosTransferSheet {
    @ToolbarContentBuilder
    var transferConfirmItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Confirmar") {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onConfirm(actor, reason)
                dismiss()
            }
            .disabled(!canConfirm)
            .accessibilityIdentifier(A11yID.autonomosTransferSubmit)
            .accessibilityLabel(AutonomosTransferSheetA11yConfirm.spokenConfirm(canConfirm: canConfirm))
            .accessibilityHint(
                AutonomosTransferSheetA11yConfirm.spokenConfirmHint(
                    canConfirm: canConfirm,
                    hasPlacement: hasPlacement
                )
            )
        }
    }
}
