import Foundation
import AtlasCore

// Heal sheet spoken — peel de AtlasCodeHealReceiptSheet+A11ySpoken.

extension AtlasCodeHealReceiptSheet {
    func spokenSheetLabel() -> String {
        var parts = ["recibo de cura", heal.mode]
        if heal.stepReceipts.isEmpty {
            parts.append("sem passos no recibo")
        } else {
            parts.append("\(heal.stepReceipts.count) passo\(heal.stepReceipts.count == 1 ? "" : "s")")
            parts.append("\(completedStepCount) concluído\(completedStepCount == 1 ? "" : "s")")
        }
        if let blocked = heal.blocked, !blocked.isEmpty {
            parts.append("bloqueado, \(blocked)")
        }
        return parts.joined(separator: ", ")
    }
}
