import AtlasCore
import SwiftUI

// Content switch — peel de AtlasCodeRadarView.

extension AtlasCodeRadarView {
    @ViewBuilder
    var radarContent: some View {
        switch model.phase {
        case .idle, .loading:
            TraceEvidenceLoading(text: "lendo o seu workspace…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier(A11yID.radarLoading)
        case .failed(let message):
            AtlasCodeLoadFailureEmpty(
                headline: "não consegui ler o workspace",
                message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                onRetry: { Task { await model.load() } }
            )
            .accessibilityLabel(spokenFailed(message))
            .accessibilityHint("reconecta ao servidor Atlas")
            .accessibilityIdentifier(A11yID.radarFailure)
        case .loaded:
            if let workspace = model.workspace {
                AtlasCodeRadarLoadedContent(workspace: workspace, model: model, onOpenRepo: onOpenRepo)
            } else {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel(spokenEmptyWorkspace())
            }
        }
    }
}
