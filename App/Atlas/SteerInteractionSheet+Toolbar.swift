import SwiftUI
import AtlasCore

// Toolbar steer — peel de SteerInteractionSheet.

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                title: "Cancelar",
                spokenLabel: "cancelar redirecionamento",
                spokenHint: "fecha sem enviar instrução",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Enviar") {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onSubmit(instruction, scope)
            }
            .disabled(!canSubmit)
            .accessibilityIdentifier(A11yID.steerSubmit)
            .accessibilityLabel(spokenSubmitLabel(canSubmit: canSubmit))
            .accessibilityHint(spokenSubmitHint(canSubmit: canSubmit))
        }
    }
}
