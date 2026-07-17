import Foundation

public enum AtlasAutonomosClientError: Error, Sendable, Equatable {
    case missingOperatorActor
    case missingOperatorReasonForExecute
    case missingFindingHash
    case missingRationaleForHighRiskAccept
    case missingTransferReason
    case missingRevertReason
}

public extension AtlasClient {
    func decideAutonomosOperatorAction(
        area: String,
        input: AtlasAutonomosOperatorDecisionInput
    ) async throws -> AtlasAutonomosOperatorDecisionReceipt {
        guard !input.operatorActor.isEmpty else {
            throw AtlasAutonomosClientError.missingOperatorActor
        }
        guard !input.findingHash.isEmpty else {
            throw AtlasAutonomosClientError.missingFindingHash
        }
        guard input.isLocallyValidForSubmission else {
            throw AtlasAutonomosClientError.missingRationaleForHighRiskAccept
        }
        return try await post(
            AtlasRoute.autonomosOperatorDecision(area: area),
            body: input,
            timeout: 30
        )
    }
}
