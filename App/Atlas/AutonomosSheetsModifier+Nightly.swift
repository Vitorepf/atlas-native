import SwiftUI
import AtlasCore

// Folha da missão noturna — peel de AutonomosSheetsModifier.

extension AutonomosSheetsModifier {
    @ViewBuilder
    func nightlyStartSheet(on content: some View) -> some View {
        content
            .sheet(item: $nightlyStartProposal) { proposal in
                AutonomosReasonSheet(
                    title: "Preparar missão noturna",
                    explainer: "Ensaio (dry-run): a frota recebe a missão proposta e o recibo entra na fila; só o lease confirma execução.",
                    reasonOptional: true,
                    initialReason: proposal.prefilledReason
                ) { actor, reason in
                    Task {
                        let previous = model.lastStartRunReceipt
                        await model.startRun(mode: .dryRun, operatorActor: actor, operatorReason: reason)
                        if model.lastStartRunReceipt != previous,
                           model.lastStartRunReceipt?.isEnqueued == true {
                            await nightly.accept(proposal)
                        }
                    }
                }
            }
    }
}
