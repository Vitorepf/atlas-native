import SwiftUI
import AtlasCore

// Dry-run start task — peel de AutonomosSheetsModifier+Nightly.

extension AutonomosSheetsModifier {
    func nightlyStartDryRun(proposal: NightlyProposalController.ProposalPayload, actor: String, reason: String) {
        Task {
            let previous = model.lastStartRunReceipt
            await model.startRun(mode: .dryRun, operatorActor: actor, operatorReason: reason)
            await nightlyAcceptIfEnqueued(proposal: proposal, previous: previous)
        }
    }
}
