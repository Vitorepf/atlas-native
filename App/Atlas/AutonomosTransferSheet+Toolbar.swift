import SwiftUI
import AtlasCore

// Toolbar transfer — peel de AutonomosTransferSheet.

extension AutonomosTransferSheet {
    @ToolbarContentBuilder
    var transferToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                title: "Cancelar",
                spokenLabel: AutonomosTransferSheetA11y.spokenCancel,
                spokenHint: "fecha sem transferir",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Confirmar") {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onConfirm(actor, reason)
                dismiss()
            }
            .disabled(!canConfirm)
            .accessibilityIdentifier(A11yID.autonomosTransferSubmit)
            .accessibilityLabel(AutonomosTransferSheetA11y.spokenConfirm(canConfirm: canConfirm))
            .accessibilityHint(
                AutonomosTransferSheetA11y.spokenConfirmHint(
                    canConfirm: canConfirm,
                    hasPlacement: hasPlacement
                )
            )
        }
    }
}
