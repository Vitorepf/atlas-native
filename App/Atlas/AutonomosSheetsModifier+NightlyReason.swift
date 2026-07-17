import SwiftUI
import AtlasCore

// Reason sheet content — peel de AutonomosSheetsModifier+Nightly.

extension AutonomosSheetsModifier {
    func nightlyReasonSheet(for proposal: NightlyProposalController.ProposalPayload) -> some View {
        AutonomosReasonSheet(
            title: "Preparar missão noturna",
            explainer: "Ensaio (dry-run): a frota recebe a missão proposta e o recibo entra na fila; só o lease confirma execução.",
            reasonOptional: true,
            initialReason: proposal.prefilledReason
        ) { actor, reason in
            nightlyStartDryRun(proposal: proposal, actor: actor, reason: reason)
        }
    }
}
