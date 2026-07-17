import SwiftUI

// Form — peel de AutonomosReasonSheet.
// Toolbar → AutonomosReasonSheet+Toolbar.swift
// Reason → AutonomosReasonSheet+FormReason.swift
// Operator → AutonomosReasonSheet+FormOperator.swift

extension AutonomosReasonSheet {
    var reasonForm: some View {
        Form {
            Section("Ação governada") {
                Text(title)
                    .accessibilityAddTraits(.isHeader)
                Text(explainer).font(.footnote).foregroundStyle(.secondary)
            }
            operatorSection
            reasonSection
        }
    }
}
