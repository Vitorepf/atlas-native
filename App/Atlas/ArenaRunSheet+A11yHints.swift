import Foundation
import AtlasCore

// Actor/reason hints — peel de ArenaRunSheet+A11yReceipt.

extension ArenaRunSheet {
    func spokenActorHint() -> String {
        "nome de quem autoriza a medição"
    }

    func spokenReasonHint() -> String {
        "motivo auditável registrado no ledger"
    }
}
