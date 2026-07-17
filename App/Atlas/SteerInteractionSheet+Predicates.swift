import SwiftUI
import AtlasCore

// Steer predicates — peel de SteerInteractionSheet.

extension SteerInteractionSheet {
    var canSubmit: Bool {
        !instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var matchedReceipt: AtlasInteractionSteerResponse? {
        guard let receipt = model.lastSteerReceipt else { return nil }
        if let receiptTrace = receipt.traceId, receiptTrace != traceId.rawValue { return nil }
        return receipt
    }
}
