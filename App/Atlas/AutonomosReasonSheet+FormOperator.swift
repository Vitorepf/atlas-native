import SwiftUI

// Operador section — peel de AutonomosReasonSheet+Form.

extension AutonomosReasonSheet {
    var operatorSection: some View {
        Section("Operador") {
            TextField("Quem autoriza", text: $actor)
                .accessibilityIdentifier(A11yID.autonomosReasonActor)
                .accessibilityHint(spokenActorHint())
        }
    }
}
