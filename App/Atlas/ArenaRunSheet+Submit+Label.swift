import SwiftUI
import AtlasCore

// Submit label — peel de ArenaRunSheet+Submit.

extension ArenaRunSheet {
    var submitButtonLabel: some View {
        Text("Rodar medição")
            .font(.system(.body, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Capsule().fill(input.isLocallyValidForSubmission ? AtlasTheme.goldVeil : AtlasTheme.surfaceHi))
            .overlay(Capsule().stroke(input.isLocallyValidForSubmission ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
    }
}
