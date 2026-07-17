import AtlasCore
import SwiftUI

// Radar loaded/failed branches — peel de AtlasCodeRadarView+Content.

extension AtlasCodeRadarView {
    @ViewBuilder
    var radarLoadedOrEmpty: some View {
        if let workspace = model.workspace {
            AtlasCodeRadarLoadedContent(workspace: workspace, model: model, onOpenRepo: onOpenRepo)
        } else {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel(spokenEmptyWorkspace())
        }
    }

    @ViewBuilder
    func radarFailed(_ message: String) -> some View {
        AtlasCodeLoadFailureEmpty(
            headline: "não consegui ler o workspace",
            message: message.trimmingCharacters(in: .whitespacesAndNewlines),
            onRetry: { Task { await model.load() } }
        )
        .accessibilityLabel(spokenFailed(message))
        .accessibilityHint("reconecta ao servidor Atlas")
        .accessibilityIdentifier(A11yID.radarFailure)
    }
}
