import SwiftUI
import AtlasCore

// Submit toolbar item — peel de SteerInteractionSheet+Toolbar.

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerSubmitItem: some ToolbarContent {
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
