import Foundation
import AtlasCore

// Step counts — peel de AtlasCodeHealReceiptSheet+A11y.

extension AtlasCodeHealReceiptSheet {
    var completedStepCount: Int {
        heal.stepReceipts.filter { $0.status == "completed" }.count
    }

    var hasCompletedHeal: Bool { completedStepCount > 0 }
}
