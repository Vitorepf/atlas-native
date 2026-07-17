import SwiftUI

// Form — peel de AutonomosReasonSheet.
// Toolbar → AutonomosReasonSheet+Toolbar.swift
// Reason → AutonomosReasonSheet+FormReason.swift

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
            reasonSection
        }
    }
}
