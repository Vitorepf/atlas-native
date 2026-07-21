import SwiftUI
import AtlasCore

// Toolbar — peel de ChangeReviewSheet.

extension ChangeReviewSheet {
    var reviewToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                spokenLabel: "fechar revisão de mudanças",
                spokenHint: "volta para a conversa",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}
