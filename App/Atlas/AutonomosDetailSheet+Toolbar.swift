import SwiftUI
import AtlasCore

// Toolbar detail — peel de AutonomosDetailSheet.

extension AutonomosPublicDetailSheet {
    @ToolbarContentBuilder
    var detailToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                spokenLabel: spokenCloseLabel(),
                spokenHint: "fecha a projeção pública",
                accessibilityID: A11yID.autonomosDetailClose,
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}
