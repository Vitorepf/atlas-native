import Foundation
import AtlasCore

// Masthead spoken — peel de AtlasCodeHealReceiptSheet+A11ySpoken.

extension AtlasCodeHealReceiptSheet {
    func spokenMastheadLabel() -> String {
        hasCompletedHeal
            ? "curado sozinho, modo \(heal.mode)"
            : "cura, modo \(heal.mode)"
    }

    func spokenSilenceLabel() -> String {
        "você não foi necessário, cura concluída sem portão"
    }
}
