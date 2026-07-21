import SwiftUI
import AtlasCore

// Receipt card — visual truth aligned with Spoken (WAVE-004 honesty).

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
            if model.lastStartEnginesCount > 1 {
                Text("\(model.lastStartEnginesCount) motores · \(model.lastStartRunsPlannedTotal) runs na fila")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
            if receipt.workerImplemented == false {
                // false = worker desligado no servidor (ATLAS_ARENA_WORKER_ENABLED) — never “não implementado”.
                Text(Self.workerGapCopy)
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

    /// Single source for visual + VoiceOver worker gap (WAVE-004 DoD #1).
    static let workerGapCopy = "worker de medição desligado no servidor — fila aguardando"
}
