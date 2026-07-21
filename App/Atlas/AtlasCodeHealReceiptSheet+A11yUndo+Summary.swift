import Foundation
import AtlasCore

// Steps summary spoken — peel de AtlasCodeHealReceiptSheet+A11yUndo.

extension AtlasCodeHealReceiptSheet {
    func spokenStepsSummaryLabel() -> String {
        "\(heal.stepReceipts.count) passo\(heal.stepReceipts.count == 1 ? "" : "s") no recibo"
    }
}
