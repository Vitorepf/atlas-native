import SwiftUI
import AtlasCore

// Milestone tags — peel de AutonomosTransferStatus body.

extension AutonomosTransferStatus {
    @ViewBuilder
    var transferTags: some View {
        HStack(spacing: 6) {
            AutonomosChrome.tag(transfer.handoff.focus)
            if let host = transfer.handoff.source.host?.nonEmpty {
                AutonomosChrome.tag("fonte \(host)")
            }
            if transfer.isTargetClaimed, let host = transfer.handoff.target.host?.nonEmpty {
                AutonomosChrome.tag("alvo \(host)")
            }
        }
        .accessibilityHidden(true)
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
