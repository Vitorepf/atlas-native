import SwiftUI

// Form — peel de AutonomosReasonSheet.
// Toolbar → AutonomosReasonSheet+Toolbar.swift
// Reason → AutonomosReasonSheet+FormReason.swift
// Operator → AutonomosReasonSheet+FormOperator.swift
// Action → AutonomosReasonSheet+FormAction.swift

extension AutonomosReasonSheet {
    var reasonForm: some View {
        Form {
            actionSection
            operatorSection
            reasonSection
        }
    }
}
