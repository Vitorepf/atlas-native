import Foundation

public extension AtlasClient {
    func revertAutonomosCycle(
        area: String,
        cycle: String,
        input: AtlasAutonomosCycleRevertInput
    ) async throws -> AtlasAutonomosCycleRevertResponse {
        guard !input.operatorActor.isEmpty else {
            throw AtlasAutonomosClientError.missingOperatorActor
        }
        guard !input.reason.isEmpty else {
            throw AtlasAutonomosClientError.missingRevertReason
        }
        return try await post(
            AtlasRoute.autonomosCycleRevert(area: area, cycle: cycle),
            body: input,
            timeout: 30
        )
    }

    func controlAutonomosRun(
        area: String,
        input: AtlasAutonomosRunControlInput
    ) async throws -> AtlasAutonomosRunControlResponse {
        guard !input.operatorActor.isEmpty else {
            throw AtlasAutonomosClientError.missingOperatorActor
        }
        return try await post(
            AtlasRoute.autonomosRunControl(area: area),
            body: input,
            timeout: 30
        )
    }

    func startAutonomosRun(
        area: String,
        input: AtlasAutonomosStartRunInput
    ) async throws -> AtlasAutonomosStartRunResponse {
        guard !input.operatorActor.isEmpty else {
            throw AtlasAutonomosClientError.missingOperatorActor
        }
        guard input.mode != .execute || !input.operatorReason.isEmpty else {
            throw AtlasAutonomosClientError.missingOperatorReasonForExecute
        }
        return try await post(
            AtlasRoute.autonomosStartRun(area: area),
            body: input,
            timeout: 30
        )
    }

    func transferAutonomosMission(
        area: String,
        input: AtlasAutonomosTransferInput
    ) async throws -> AtlasAutonomosTransferResponse {
        guard !input.operatorActor.isEmpty else {
            throw AtlasAutonomosClientError.missingOperatorActor
        }
        guard !input.reason.isEmpty else {
            throw AtlasAutonomosClientError.missingTransferReason
        }
        return try await post(
            AtlasRoute.autonomosTransfer(area: area),
            body: input,
            timeout: 30
        )
    }

    func autonomosTransferStatus(
        area: String,
        handoffId: String
    ) async throws -> AtlasAutonomosTransferResponse {
        try await get(AtlasRoute.autonomosTransferStatus(area: area, handoffId: handoffId))
    }
}
