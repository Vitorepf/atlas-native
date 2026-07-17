import SwiftUI

// Toolbar reason — peel de AutonomosReasonSheet+Form.
// Confirm → AutonomosReasonSheet+ToolbarConfirm.swift

extension AutonomosReasonSheet {
    @ToolbarContentBuilder
    var reasonToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                title: "Cancelar",
                spokenLabel: "cancelar ação governada",
                spokenHint: "fecha sem registrar recibo",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
        reasonConfirmToolbar
    }
}
