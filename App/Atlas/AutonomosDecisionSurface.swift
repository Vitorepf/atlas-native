import SwiftUI
import AtlasCore

// MARK: - Surface

/// Decisions organ (WAVE-026) — one domain: published backlog → face → decide.
/// WAVE-156 density peel — host (list/detail/sections peels).
struct AutonomosDecisionSurface: View {
    let model: AutonomosModel
    let destination: AutonomosDestination
    let onNavigate: (AutonomosDestination) -> Void

    @State var pendingDecision: PendingDecision?

    var face: AutonomosDecisionFace {
        AutonomosDecisionJudgment.face(
            backlog: model.backlog,
            areaSelected: model.selectedArea != nil,
            error: model.controlError
        )
    }

    var items: [AutonomosDecisionItem] {
        AutonomosDecisionJudgment.items(from: model.backlog)
    }

    var body: some View {
        Group {
            switch destination {
            case .decisionInbox, .decisionOrder:
                detailBody
            default:
                listBody
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityIdentifier(A11yID.autonomosDecisions)
        .sheet(item: $pendingDecision) { pending in
            AutonomosReasonSheet(
                title: AutonomosDecisionJudgment.decisionLabel(pending.decision),
                explainer: pending.explainer,
                reasonOptional: !pending.requiresRationale
            ) { actor, reason in
                Task {
                    await model.decide(
                        pending.decision,
                        findingHash: pending.item.findingHash,
                        operatorActor: actor,
                        rationale: reason,
                        riskLevel: AutonomosDecisionJudgment.riskLevel(from: pending.item.riskLevel),
                        inboxItemId: pending.item.inboxItemId,
                        workOrderId: pending.item.workOrderId
                    )
                }
            }
        }
        .task(id: model.selectedAreaID) {
            guard model.selectedAreaID != nil else { return }
            await model.refreshSelected()
        }
    }
}

// MARK: - Pending decision sheet state

struct PendingDecision: Identifiable {
    let item: AutonomosDecisionItem
    let decision: AtlasAutonomosOperatorDecision
    let requiresRationale: Bool

    var id: String { "\(item.id)|\(decision.rawValue)" }

    var explainer: String {
        "Registra \(AutonomosDecisionJudgment.decisionLabel(decision).lowercased()) sobre «\(item.title)». Não inicia execução sozinho — só o julgamento do operador."
    }
}
