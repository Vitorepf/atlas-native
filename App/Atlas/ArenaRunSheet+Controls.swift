import SwiftUI
import AtlasCore

/// Controles reutilizáveis do sheet de medição Arena — peel de ArenaRunSheet.
/// Toggle → ArenaRunSheet+Toggle.swift
/// Section → ArenaRunSheet+Section.swift
/// Copy → ArenaRunSheet+ControlsCopy.swift
extension ArenaRunSheet {
    func receiptCard(_ receipt: AtlasArenaStartReceipt) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            receiptCardCopy(receipt)
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenReceiptLabel(receipt))
        .accessibilityIdentifier(A11yID.arenaRunReceipt)
    }
}
