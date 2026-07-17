import SwiftUI
import AtlasCore

// Transfer status header — peel de AutonomosFleetTransfer.

extension AutonomosTransferStatus {
    var transferHeader: some View {
        HStack(spacing: 10) {
            Text(transfer.handoff.status)
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Spacer()
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRefresh()
            } label: {
                Image(systemName: "arrow.clockwise").font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .accessibilityLabel("atualizar status da transferência")
            .accessibilityHint("busca o recibo mais recente do servidor")
            .accessibilityIdentifier(A11yID.autonomosTransferRefresh)
        }
    }
}
