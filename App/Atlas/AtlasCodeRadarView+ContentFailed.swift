import AtlasCore
import SwiftUI

// Failed branch — peel de AtlasCodeRadarView+ContentBranches.

extension AtlasCodeRadarView {
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
