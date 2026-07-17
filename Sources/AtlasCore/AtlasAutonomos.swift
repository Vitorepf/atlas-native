import Foundation

public extension AtlasClient {
    func listAutonomosAreas() async throws -> AtlasAutonomosAreasResponse {
        try await get(AtlasRoute.autonomosAreas)
    }

    func autonomosLive(area: String, focus: String? = nil) async throws -> AtlasAutonomosLiveResponse {
        let query = atlasQueryString([("focus", focus.map { .string($0) })])
        return try await get("\(AtlasRoute.autonomosLive(area: area))\(query)")
    }

    func autonomosCycles(area: String, focus: String? = nil, tail: Int = 20) async throws -> AtlasAutonomosCyclesResponse {
        let query = atlasQueryString([
            ("focus", focus.map { .string($0) }),
            ("tail", .int(tail)),
        ])
        return try await get("\(AtlasRoute.autonomosCycles(area: area))\(query)")
    }

    func autonomosDelivered(area: String, focus: String? = nil, limit: Int = 20) async throws -> AtlasAutonomosDeliveredResponse {
        let query = atlasQueryString([
            ("focus", focus.map { .string($0) }),
            ("limit", .int(limit)),
        ])
        return try await get("\(AtlasRoute.autonomosDone(area: area))\(query)")
    }

    func autonomosBacklog(area: String, focus: String? = nil, limit: Int = 20) async throws -> AtlasAutonomosBacklogResponse {
        let query = atlasQueryString([
            ("focus", focus.map { .string($0) }),
            ("limit", .int(limit)),
        ])
        return try await get("\(AtlasRoute.autonomosBacklog(area: area))\(query)")
    }

    /// Fonte global de agentes reais. O endpoint é separado da área de loop;
    /// callers devem preservar essa proveniência na apresentação.
    func autonomosFleet() async throws -> AtlasAutonomosFleetResponse {
        try await get(AtlasRoute.agentsStatus)
    }

    func autonomosFleetHistory(limit: Int = 100) async throws -> AtlasAutonomosFleetHistoryResponse {
        let query = atlasQueryString([("limit", .int(limit))])
        return try await get("\(AtlasRoute.agentsHistory)\(query)")
    }

    /// Projeção global da fila de tarefas do Autônomos. Ela não é atribuída à
    /// área selecionada porque o servidor não publica essa relação.
    func autonomosTaskHealth() async throws -> AtlasAutonomosTaskHealthResponse {
        try await get(AtlasRoute.agentsTaskHealth)
    }

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

    func autonomosDigest(
        hours: Int? = nil,
        area: String? = nil,
        limit: Int? = nil
    ) async throws -> AtlasAutonomosDigestResponse {
        let query = atlasQueryString([
            ("hours", hours.map { .int($0) }),
            ("area", area.map { .string($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("\(AtlasRoute.autonomosDigest)\(query)")
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

public enum AtlasAutonomosClientError: Error, Sendable, Equatable {
    case missingOperatorActor
    case missingOperatorReasonForExecute
    case missingFindingHash
    case missingRationaleForHighRiskAccept
    case missingTransferReason
    case missingRevertReason
}
