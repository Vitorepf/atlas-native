import SwiftUI
import AtlasCore

// Transfer status label — peel de AutonomosFleetTransfer+Header.

extension AutonomosTransferStatus {
    var transferHeaderStatus: some View {
        Text(transfer.handoff.status)
            .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
    }
}
