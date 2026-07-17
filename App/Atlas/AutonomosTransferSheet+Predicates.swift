import SwiftUI
import AtlasCore

// Transfer predicates — peel de AutonomosTransferSheet.

extension AutonomosTransferSheet {
    var hasPlacement: Bool { placement?.hasVerifiedPlacement == true }

    var canConfirm: Bool {
        hasPlacement
            && !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
