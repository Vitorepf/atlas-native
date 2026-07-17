import Foundation
import AtlasCore

// Outcome spoken — peel de AtlasCodeHealReceiptSheet+A11ySpoken.

extension AtlasCodeHealReceiptSheet {
    func spokenBlockedLabel(_ blocked: String) -> String {
        "cura bloqueada, \(blocked)"
    }

    func spokenEmptyStepsLabel() -> String {
        "recibo sem passos registrados pelo servidor"
    }
}
