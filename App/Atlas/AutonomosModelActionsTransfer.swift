import Foundation
import AtlasCore

// WAVE-173 density peel — AutonomosModel Transfer

// MARK: - Transfer / revert
extension AutonomosModel {
    func transfer(
        operatorActor: String,
        reason: String
    ) async {
        guard let area = selectedArea else { return }
        controlError = nil
        do {
            let input = AtlasAutonomosTransferInput(
                operatorActor: operatorActor,
                reason: reason,
                focus: area.focus
            )
            lastTransferReceipt = try await client.transferAutonomosMission(area: area.id, input: input)
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    func refreshTransferStatus() async {
        guard let area = selectedArea, let handoffId = lastTransferReceipt?.handoff.handoffId else { return }
        do {
            lastTransferReceipt = try await client.autonomosTransferStatus(area: area.id, handoffId: handoffId)
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    func revertCycle(
        cycle: String,
        operatorActor: String,
        reason: String
    ) async {
        guard let area = selectedArea else { return }
        controlError = nil
        do {
            let input = AtlasAutonomosCycleRevertInput(
                operatorActor: operatorActor,
                reason: reason,
                focus: area.focus
            )
            lastRevertReceipt = try await client.revertAutonomosCycle(
                area: area.id,
                cycle: cycle,
                input: input
            )
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}
