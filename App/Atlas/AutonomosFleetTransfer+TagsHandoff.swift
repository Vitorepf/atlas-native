import SwiftUI
import AtlasCore

// Handoff tags — peel de AutonomosFleetTransfer+Tags.

extension AutonomosTransferStatus {
    @ViewBuilder
    var transferHandoffTags: some View {
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
    }
}
