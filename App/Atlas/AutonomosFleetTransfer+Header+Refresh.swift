import SwiftUI
import AtlasCore

// Transfer refresh control — peel de AutonomosFleetTransfer+Header.

extension AutonomosTransferStatus {
    var transferHeaderRefresh: some View {
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
