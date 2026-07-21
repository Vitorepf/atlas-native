import Foundation
import AtlasCore

// Receipt spoken — peel de ArenaRunSheet+A11y.
// Hints → ArenaRunSheet+A11yHints.swift · Error → ArenaRunSheet+A11yError.swift

extension ArenaRunSheet {
    func spokenReceiptLabel(_ receipt: AtlasArenaStartReceipt) -> String {
        var parts = ["recibo \(receipt.receiptHash)"]
        parts.append(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
        if receipt.workerImplemented == false {
            parts.append("worker de medição ainda não implementado")
        }
        return parts.joined(separator: ", ")
    }
}
