import SwiftUI
import AtlasCore

// Checks revelados — peel de ArtifactSheet+Mount.
// Row → ArtifactSheet+MountCheckRow.swift

extension ArtifactSheet {
    @ViewBuilder
    var mountChecks: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(deliveryChecks.enumerated()), id: \.element.id) { index, check in
                if index < mountRevealed {
                    mountCheckRow(index: index, check: check)
                }
            }
        }
    }
}
