import SwiftUI
import AtlasCore

// Submit button — peel de SteerInteractionSheet+ToolbarSubmit.

extension SteerInteractionSheet {
    var steerSubmitButton: some View {
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
