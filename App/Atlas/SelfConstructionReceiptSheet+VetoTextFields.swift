import SwiftUI
import AtlasCore

// Veto text fields — peel de SelfConstructionReceiptSheet+VetoFields.
// Actor → SelfConstructionReceiptSheet+VetoTextFields+Actor.swift
// Reason → SelfConstructionReceiptSheet+VetoTextFields+Reason.swift

extension SelfConstructionReceiptSheet {
    var vetoTextFields: some View {
        Group {
            vetoActorField
            vetoReasonField
        }
    }
}
