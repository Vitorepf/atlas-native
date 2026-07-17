import SwiftUI

// Confirm action — peel de AutonomosReasonSheet+Toolbar.

extension AutonomosReasonSheet {
    @ToolbarContentBuilder
    var reasonConfirmToolbar: some ToolbarContent {
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
