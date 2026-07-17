import SwiftUI
import AtlasCore

// Steer helpers — peel de ConversationComposer+Actions.
// Receipt → ConversationComposer+SteerReceipt.swift

extension ConversationComposer {
    func submitSteer(
        traceId: TraceID,
        instruction: String,
        scope: AtlasInteractionSteerScope
    ) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        Task {
            await model.steerInteraction(traceId: traceId, instruction: instruction, scope: scope)
            if let receipt = steerReceipt(for: traceId) {
                model.toast = steerReceiptText(receipt)
            }
        }
    }
}
