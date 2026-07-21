import SwiftUI
import AtlasCore

// Predicates do receipt sheet — peel de SelfConstructionReceiptSheet.

extension SelfConstructionReceiptSheet {
    var canSubmitRevert: Bool {
        !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
