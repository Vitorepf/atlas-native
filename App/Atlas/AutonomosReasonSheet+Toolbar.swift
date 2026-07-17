import SwiftUI

// Toolbar reason — peel de AutonomosReasonSheet+Form.

extension AutonomosReasonSheet {
    @ToolbarContentBuilder
    var reasonToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                title: "Cancelar",
                spokenLabel: "cancelar ação governada",
                spokenHint: "fecha sem registrar recibo",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Confirmar") {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onConfirm(actor, reason)
                dismiss()
            }
            .disabled(!canSubmit)
            .accessibilityIdentifier(A11yID.autonomosReasonSubmit)
            .accessibilityLabel(spokenConfirmLabel(canSubmit: canSubmit))
            .accessibilityHint(spokenConfirmHint(canSubmit: canSubmit))
        }
    }
}
