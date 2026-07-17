import SwiftUI
import AtlasCore

// Toolbar steer — peel de SteerInteractionSheet.
// Submit → SteerInteractionSheet+ToolbarSubmit.swift

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                title: "Cancelar",
                spokenLabel: "cancelar redirecionamento",
                spokenHint: "fecha sem enviar instrução",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
        steerSubmitItem
    }
}
