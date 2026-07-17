import SwiftUI
import AtlasCore

// Operador section — peel de AutonomosTransferSheet+Operator.

extension AutonomosTransferSheet {
    @ViewBuilder
    var transferOperatorActorSection: some View {
        Section("Operador") {
            TextField("Quem autoriza", text: $actor)
                .accessibilityIdentifier(A11yID.autonomosTransferActor)
                .accessibilityHint("nome de quem autoriza a transferência")
        }
    }
}
