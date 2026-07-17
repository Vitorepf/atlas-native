import SwiftUI

// Form — peel de AutonomosReasonSheet.
// Toolbar → AutonomosReasonSheet+Toolbar.swift

extension AutonomosReasonSheet {
    var reasonForm: some View {
        Form {
            Section("Ação governada") {
                Text(title)
                    .accessibilityAddTraits(.isHeader)
                Text(explainer).font(.footnote).foregroundStyle(.secondary)
            }
            Section("Operador") {
                TextField("Quem autoriza", text: $actor)
                    .accessibilityIdentifier(A11yID.autonomosReasonActor)
                    .accessibilityHint(spokenActorHint())
            }
            Section(reasonOptional ? "Motivo (opcional no ensaio)" : "Motivo") {
                TextField("Motivo auditável", text: $reason, axis: .vertical).lineLimit(3...6)
                    .accessibilityIdentifier(A11yID.autonomosReasonField)
                    .accessibilityHint(spokenReasonHint())
            }
        }
    }
}
