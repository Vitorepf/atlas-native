import SwiftUI
import AtlasCore

/// Controles reutilizáveis do sheet de medição Arena — peel de ArenaRunSheet.
/// Toggle → ArenaRunSheet+Toggle.swift
/// Section → ArenaRunSheet+Section.swift
extension ArenaRunSheet {
    func receiptCard(_ receipt: AtlasArenaStartReceipt) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("recibo \(receipt.receiptHash)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .accessibilityHidden(true)
            Text(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
                .font(.system(.callout, weight: .semibold))
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            if receipt.workerImplemented == false {
                Text("worker de medição ainda não implementado")
                    .font(.system(.caption))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenReceiptLabel(receipt))
        .accessibilityIdentifier(A11yID.arenaRunReceipt)
    }
}
