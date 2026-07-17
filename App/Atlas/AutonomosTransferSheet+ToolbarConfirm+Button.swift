import SwiftUI
import AtlasCore

// Confirm button — peel de AutonomosTransferSheet+ToolbarConfirm.
// A11y → AutonomosTransferSheet+ToolbarConfirm+A11y.swift

extension AutonomosTransferSheet {
    var transferConfirmButton: some View {
        Button("Confirmar") {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onConfirm(actor, reason)
            dismiss()
        }
        .disabled(!canConfirm)
    }
}
