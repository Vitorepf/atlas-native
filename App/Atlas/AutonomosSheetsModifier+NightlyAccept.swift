import SwiftUI
import AtlasCore

// Accept side-effect da missão noturna — peel de AutonomosSheetsModifier+Nightly.

extension AutonomosSheetsModifier {
    func nightlyAcceptIfEnqueued(
        proposal: NightlyProposalController.ProposalPayload,
        previous: AtlasAutonomosStartRunResponse?
    ) async {
        if model.lastStartRunReceipt != previous,
           model.lastStartRunReceipt?.isEnqueued == true {
            await nightly.accept(proposal)
        }
    }
}
