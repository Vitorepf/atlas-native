import Foundation
import AtlasCore

// WAVE-173 density peel — AutonomosModel Decide

// MARK: - Decide / digest
extension AutonomosModel {
    func refreshDigest() async {
        do {
            digest = try await client.autonomosDigest()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    func decide(
        _ decision: AtlasAutonomosOperatorDecision,
        findingHash: String,
        operatorActor: String,
        rationale: String = "",
        riskLevel: AtlasAutonomosRiskLevel = .medium,
        inboxItemId: String? = nil,
        workOrderId: String? = nil,
        evidencePackHash: String? = nil
    ) async {
        guard let area = selectedArea else { return }
        controlError = nil
        do {
            let input = AtlasAutonomosOperatorDecisionInput(
                operatorActor: operatorActor,
                decision: decision,
                findingHash: findingHash,
                rationale: rationale,
                riskLevel: riskLevel,
                inboxItemId: inboxItemId,
                workOrderId: workOrderId,
                evidencePackHash: evidencePackHash
            )
            lastDecisionReceipt = try await client.decideAutonomosOperatorAction(area: area.id, input: input)
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}
