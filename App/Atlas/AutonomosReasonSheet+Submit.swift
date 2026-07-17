import SwiftUI

// canSubmit — peel de AutonomosReasonSheet.

extension AutonomosReasonSheet {
    var canSubmit: Bool {
        !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (reasonOptional || !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
}
