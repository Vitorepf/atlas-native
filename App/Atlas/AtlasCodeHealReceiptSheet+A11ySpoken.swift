import Foundation
import AtlasCore

// Spoken labels do recibo — peel de AtlasCodeHealReceiptSheet+A11y.
// Sheet → AtlasCodeHealReceiptSheet+A11ySheetSpoken.swift

extension AtlasCodeHealReceiptSheet {
    func spokenMastheadLabel() -> String {
        hasCompletedHeal
            ? "curado sozinho, modo \(heal.mode)"
            : "cura, modo \(heal.mode)"
    }

    func spokenSilenceLabel() -> String {
        "você não foi necessário, cura concluída sem portão"
    }

    func spokenBlockedLabel(_ blocked: String) -> String {
        "cura bloqueada, \(blocked)"
    }

    func spokenEmptyStepsLabel() -> String {
        "recibo sem passos registrados pelo servidor"
    }
}
