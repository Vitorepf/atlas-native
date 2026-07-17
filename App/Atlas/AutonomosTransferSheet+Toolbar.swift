import SwiftUI
import AtlasCore

// Toolbar transfer — peel de AutonomosTransferSheet.
// Confirm → AutonomosTransferSheet+ToolbarConfirm.swift

extension AutonomosTransferSheet {
    @ToolbarContentBuilder
    var transferToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                title: "Cancelar",
                spokenLabel: AutonomosTransferSheetA11yConfirm.spokenCancel,
                spokenHint: "fecha sem transferir",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
        transferConfirmItem
    }
}
