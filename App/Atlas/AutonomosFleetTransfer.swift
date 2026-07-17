import SwiftUI
import AtlasCore

/// C13: estados do handoff LITERAIS; host alvo só depois de target_claimed.
/// Body → AutonomosFleetTransfer+Body.swift
struct AutonomosTransferStatus: View {
    let transfer: AtlasAutonomosTransferResponse
    let onRefresh: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            transferBody
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.goldVeil))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosTransferStatus)
    }
}
