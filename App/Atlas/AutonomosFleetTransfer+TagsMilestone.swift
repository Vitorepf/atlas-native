import SwiftUI
import AtlasCore

// Milestone tags — peel de AutonomosFleetTransfer+Tags.

extension AutonomosTransferStatus {
    @ViewBuilder
    var transferMilestoneTags: some View {
        if !transfer.transferMilestoneTags.isEmpty {
            HStack(spacing: 6) {
                ForEach(transfer.transferMilestoneTags, id: \.self) { tag in
                    AutonomosChrome.tag(tag)
                }
            }
            .accessibilityHidden(true)
        }
    }
}
