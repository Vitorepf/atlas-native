import Foundation

/// Contratos da superfície 24/7 do Atlas Continuous Stewardship Loop.
/// Esta família é deliberadamente independente de threads/conversas: missão,
/// lock, ciclo, backlog e recibos pertencem ao Autônomos, não a um chat.
public struct AtlasAutonomosAreasResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let readOnly: Bool
    public let areas: [AtlasAutonomosArea]
    public let areaCount: Int
    public let defaultArea: String?
    public let defaultFocus: String?
}

/// Projeção Foundation-only dos sinais que o runner realmente publica. A
/// prioridade é operacional: kill > pausa > lease ativo > ocioso.
public enum AtlasAutonomosLoopPhase: String, Sendable, Equatable {
    case idle
    case running
    case paused
    case terminated
}

public struct AtlasAutonomosLoopStatus: Sendable, Equatable {
    public let lockHeld: Bool
    public let lockAvailable: Bool?
    public let pauseActive: Bool
    public let killSwitchActive: Bool

    public init(runState: JSONObject) {
        lockHeld = runState["lock"]?["held"]?.boolValue ?? false
        lockAvailable = runState["lock"]?["available"]?.boolValue
        pauseActive = runState["pause"]?["active"]?.boolValue ?? false
        killSwitchActive = runState["kill_switch"]?["active"]?.boolValue ?? false
    }

    public var phase: AtlasAutonomosLoopPhase {
        if killSwitchActive { return .terminated }
        if pauseActive { return .paused }
        return lockHeld ? .running : .idle
    }
}

/// Placement público que o runtime realmente publicou. Cada campo é opcional:
/// a casca mostra ausência como indisponível, nunca a infere da área ou do
/// repositório. Caminhos absolutos não pertencem a este contrato.
public struct AtlasAutonomosRuntimePlacement: Sendable, Equatable {
    public let host: String?
    public let acquiredAt: String?
    public let leaseTTLSeconds: Int?
    public let environment: String?
    public let workspace: String?
    public let repository: String?
    public let branch: String?

    public init(runState: JSONObject) {
        let holder = runState["lock"]?["holder"]
        let runtime = holder?["runtime"]
        host = holder?["host"]?.stringValue
        acquiredAt = holder?["acquired_at"]?.stringValue
        leaseTTLSeconds = holder?["lease_ttl_seconds"]?.doubleValue.map { Int($0) }
        environment = runtime?["environment"]?.stringValue
        workspace = runtime?["workspace"]?.stringValue
        repository = runtime?["repository"]?.stringValue
        branch = runtime?["branch"]?.stringValue
    }

    public var hasVerifiedHost: Bool { !(host?.isEmpty ?? true) }
}

public struct AtlasAutonomosArea: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let areaName: String
    public let focus: String
    public let autonomyTier: Int
    public let maxTierForArea: Int
    public let devMode: String
    public let registered: Bool
    public let objective: String
    public let ownedSystems: [String]
    public let repoScope: AtlasAutonomosRepositoryScope
    public let stopConditions: [String]
    public let runState: JSONObject

    enum CodingKeys: String, CodingKey {
        case id = "areaId", areaName, focus, autonomyTier, maxTierForArea,
             devMode, registered, objective, ownedSystems, repoScope,
             stopConditions, runState
    }

    public var loopStatus: AtlasAutonomosLoopStatus { AtlasAutonomosLoopStatus(runState: runState) }
    public var repositoryNames: [String] { repoScope.repos }
    public var isLocked: Bool { loopStatus.lockHeld }
}

/// A superfície móvel recebe só os nomes públicos dos repositórios. Regras de
/// paths e demais topologia ficam no contrato canônico do servidor.
public struct AtlasAutonomosRepositoryScope: Codable, Sendable, Equatable {
    public let repos: [String]
}

public struct AtlasAutonomosLiveResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let areaId: String
    public let focus: String
    public let portfolioId: String
    public let readOnly: Bool
    /// Resumo explicitamente público do cockpit. O read model completo fica
    /// no servidor até existir um contrato de detalhe provider-safe.
    public let cockpit: AtlasAutonomosCockpitSummary
    public let runState: JSONObject

    public var loopStatus: AtlasAutonomosLoopStatus { AtlasAutonomosLoopStatus(runState: runState) }
    public var runtimePlacement: AtlasAutonomosRuntimePlacement { AtlasAutonomosRuntimePlacement(runState: runState) }
    public var isRunning: Bool { loopStatus.phase == .running }
    public var isPaused: Bool { loopStatus.phase == .paused }
    public var isKilled: Bool { loopStatus.phase == .terminated }
}

public struct AtlasAutonomosCockpitSummary: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let status: String
}

public struct AtlasAutonomosCyclesResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let areaId: String
    public let focus: String
    public let ledgerRecordCountTotal: Int
    public let returnedCount: Int
    /// Histórico já sanitizado pelo servidor: nenhum recibo bruto, referência
    /// de diagnóstico, ID interno ou backlog de plano atravessa para a casca.
    public let cycles: [AtlasAutonomosCycle]
}

/// Um marco público e cronológico da missão Autônomos. Todos os campos vêm da
/// allow-list do servidor; não representa prompt, stdout, workcell interno ou
/// um identificador de execução.
public struct AtlasAutonomosCycle: Codable, Sendable, Equatable, Identifiable {
    public let cycleIndex: Int
    public let outcome: String
    public let cycleFinalStatus: String
    public let mergePerformed: Bool
    public let mergeHash: String
    public let loopReceiptIntegrity: String
    public let blockers: [String]
    public let repaired: Bool
    public let retried: Bool
    public let quarantined: Bool
    public let quarantineReason: String
    public let recordedAt: String

    public var id: String { "\(cycleIndex):\(recordedAt)" }
}

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
