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

/// Entregas concluídas são somente ciclos cujo ledger confirmou merge real e
/// hash de merge. A casca não transforma tentativa, plano ou intenção em
/// entrega.
public struct AtlasAutonomosDeliveredResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let areaId: String
    public let focus: String
    public let readOnly: Bool
    public let ledgerRecordCountTotal: Int
    public let deliveredTotal: Int
    public let returned: Int
    public let offset: Int
    public let limit: Int
    /// Mesmo contrato público e sanitizado do histórico cronológico. A rota
    /// `done` é somente um recorte de entregas com merge comprovado.
    public let delivered: [AtlasAutonomosCycle]
}

public struct AtlasAutonomosBacklogResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let areaId: String
    public let focus: String
    public let readOnly: Bool
    /// O servidor publica somente a lista paginada de tarefas e seus campos
    /// operacionais declarados; rationale, prompt, payload, path e stdout não
    /// pertencem ao contrato do iPhone.
    public let findings: AtlasAutonomosBacklogFindings
    public let workOrders: [AtlasAutonomosWorkOrder]
    public let inboxItems: [AtlasAutonomosInboxItem]
    public let budgets: AtlasAutonomosBacklogBudgets
}

public struct AtlasAutonomosBacklogFindings: Codable, Sendable, Equatable {
    public let total: Int
    public let distinctTotal: Int
    public let returned: Int
    public let offset: Int
    public let limit: Int
    public let byRisk: [String: Int]
    public let byRoute: [String: Int]
    public let items: [AtlasAutonomosFinding]
}

/// Um finding público identificável pela prova/hash, sem detalhe de diagnóstico
/// nem topologia interna.
public struct AtlasAutonomosFinding: Codable, Sendable, Equatable, Identifiable {
    public let findingHash: String
    public let title: String
    public let source: String
    public let sourceOwner: String
    public let gapKind: String
    public let riskLevel: String
    public let priorityScore: Int
    public let route: String
    public let count: Int
    public let ruleId: String?
    public let ruleText: String?

    public var id: String { findingHash }
}

public struct AtlasAutonomosWorkOrder: Codable, Sendable, Equatable, Identifiable {
    public let workOrderId: String
    public let findingHash: String
    public let title: String
    public let route: String
    public let routesToOwnerService: String
    public let riskLevel: String
    public let priorityScore: Int
    public let requiresBranchIsolation: Bool
    public let operatorDecisionRequired: Bool
    public let evidenceRequired: Bool
    public let executionExecuted: Bool
    public let status: String

    public var id: String { workOrderId }
}

public struct AtlasAutonomosInboxItem: Codable, Sendable, Equatable, Identifiable {
    public let findingHash: String
    public let title: String
    public let route: String
    public let riskLevel: String
    public let priorityScore: Int
    public let decisionRequired: Bool
    public let decisionOptions: [String]

    public var id: String { findingHash }
}

public struct AtlasAutonomosBacklogBudgets: Codable, Sendable, Equatable {
    public let devBudget: AtlasAutonomosDevBudget
    public let forgeBudget: AtlasAutonomosForgeBudget
    public let wipLimit: Int
    public let wipUsed: Int
    public let devRouted: Int
    public let forgeRouted: Int
    public let queued: Int
    public let budgetConsumed: Bool
    public let executionExecuted: Bool
}

public struct AtlasAutonomosDevBudget: Codable, Sendable, Equatable {
    public let mode: String
    public let maxConcurrentWorkOrders: Int
}

public struct AtlasAutonomosForgeBudget: Codable, Sendable, Equatable {
    public let mode: String
    public let maxConcurrentObras: Int
}

/// Snapshot global da frota governada. Não é atribuído artificialmente a uma
/// área: a relação área→agente só existe quando o servidor a publicar.
public struct AtlasAutonomosFleetResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let generatedAt: String
    public let fleetMaster: String
    public let activeCount: Int
    public let spendingAccounts: [String]
    public let agents: [AtlasAutonomosFleetAgent]
}

public struct AtlasAutonomosFleetAgent: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let label: String
    public let account: String
    public let kind: String
    public let providerSpending: Bool
    public let desired: Bool
    public let authorized: Bool
    public let setBy: String?
    public let setAt: String?
    public let ttlRemainingSeconds: Int?
    public let budgetLimitUsd: Double?
    public let targetRef: String?
    public let reason: String?
    public let status: String
    public let alive: Bool
    public let pids: [Int]
    public let uptimeSeconds: Int?
    public let spentUsd: Double?

    enum CodingKeys: String, CodingKey {
        case id = "key", label, account, kind, providerSpending, desired,
             authorized, setBy, setAt, ttlRemainingSeconds, budgetLimitUsd,
             targetRef, reason, status, alive, pids, uptimeSeconds, spentUsd
    }

    public var isAlive: Bool { alive }
}

/// Ledger append-only de governança, já reduzido pelo servidor à cronologia
/// pública. O detalhe interno do worker/auditoria nunca atravessa para o app.
public struct AtlasAutonomosFleetHistoryResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let events: [AtlasAutonomosFleetHistoryEvent]
}

public struct AtlasAutonomosFleetHistoryEvent: Codable, Sendable, Equatable, Identifiable {
    public let agentKey: String
    public let event: String
    public let at: String
    public let by: String?
    public let account: String?
    public let pid: Int?
    public let durationSeconds: Int?
    public let reason: String?

    public var id: String {
        let pidComponent = pid.map(String.init) ?? "none"
        return "\(agentKey):\(event):\(at):\(pidComponent)"
    }
}

/// Saúde agregada da fila do músculo externo. Não carrega task packets,
/// objetivos, paths, prompts ou instruções executáveis: a casca só recebe
/// contagens, integridade do lease e um sinal operacional publicado pelo
/// servidor.
public struct AtlasAutonomosTaskHealthResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let observedAt: String
    public let providerSafe: Bool
    public let healthy: Bool
    public let tasks: AtlasAutonomosTaskHealthTasks
    public let leases: AtlasAutonomosTaskHealthLeases
    public let incidents: AtlasAutonomosTaskHealthIncidents
    public let operating: AtlasAutonomosTaskHealthOperating
}

public struct AtlasAutonomosTaskHealthTasks: Codable, Sendable, Equatable {
    public let claimable: Int
    public let servableNow: Int
    public let claimed: Int
    public let blocked: Int
    public let completed: Int
    public let recoverable: Int
}

public struct AtlasAutonomosTaskHealthLeases: Codable, Sendable, Equatable {
    public let active: Int
    public let matchesClaimed: Bool
}

public struct AtlasAutonomosTaskHealthIncidents: Codable, Sendable, Equatable {
    public let present: Bool
    public let flags: [String]
}

public struct AtlasAutonomosTaskHealthOperating: Codable, Sendable, Equatable {
    public let recommendedAction: String
    public let queuePressure: String
}

public enum AtlasAutonomosRunAction: String, Codable, Sendable, Equatable, CaseIterable, Identifiable {
    case pause
    case resume
    case kill
    case clearKill = "clear-kill"

    public var id: String { rawValue }
}

/// Um sinal governado, não uma falsa promessa de parar processo: o servidor
/// escreve o sinal e o loop o honra na próxima fronteira de iteração.
public struct AtlasAutonomosRunControlInput: Codable, Sendable, Equatable {
    public let action: AtlasAutonomosRunAction
    public let operatorActor: String
    public let reason: String
    public let focus: String?

    public init(action: AtlasAutonomosRunAction, operatorActor: String, reason: String, focus: String? = nil) {
        self.action = action
        self.operatorActor = operatorActor.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.focus = focus?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Estado público de um sinal que o loop lê no próximo limite seguro. O
/// servidor não publica path, conteúdo do arquivo ou outro detalhe operacional.
public struct AtlasAutonomosSignalState: Codable, Sendable, Equatable {
    public let active: Bool
}

public struct AtlasAutonomosRunControlResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let areaId: String
    public let focus: String
    public let action: AtlasAutonomosRunAction
    public let operatorActor: String
    public let applied: Bool
    public let killSwitch: AtlasAutonomosSignalState
    public let pause: AtlasAutonomosSignalState
    public let note: String

    public var isPaused: Bool { pause.active }
    public var isKilled: Bool { killSwitch.active }
}

/// Decisões do operador são declarações governadas; nenhuma delas inicia
/// provider, branch ou execução por conta própria.
public enum AtlasAutonomosOperatorDecision: String, Codable, Sendable, Equatable, CaseIterable, Identifiable {
    case accept
    case reject
    case deferDecision = "defer"
    case requestChanges = "request_changes"

    public var id: String { rawValue }
}

public enum AtlasAutonomosRiskLevel: String, Codable, Sendable, Equatable, CaseIterable {
    case low
    case medium
    case high
    case critical

    var requiresRationaleForAccept: Bool { self == .high || self == .critical }
}

public struct AtlasAutonomosOperatorDecisionInput: Codable, Sendable, Equatable {
    public let operatorActor: String
    public let decision: AtlasAutonomosOperatorDecision
    public let findingHash: String
    public let rationale: String
    public let riskLevel: AtlasAutonomosRiskLevel
    public let inboxItemId: String?
    public let workOrderId: String?
    public let evidencePackHash: String?

    public init(
        operatorActor: String,
        decision: AtlasAutonomosOperatorDecision,
        findingHash: String,
        rationale: String = "",
        riskLevel: AtlasAutonomosRiskLevel = .medium,
        inboxItemId: String? = nil,
        workOrderId: String? = nil,
        evidencePackHash: String? = nil
    ) {
        self.operatorActor = operatorActor.trimmingCharacters(in: .whitespacesAndNewlines)
        self.decision = decision
        self.findingHash = findingHash.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rationale = rationale.trimmingCharacters(in: .whitespacesAndNewlines)
        self.riskLevel = riskLevel
        self.inboxItemId = inboxItemId?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.workOrderId = workOrderId?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.evidencePackHash = evidencePackHash?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isLocallyValidForSubmission: Bool {
        !operatorActor.isEmpty
            && !findingHash.isEmpty
            && !(decision == .accept && riskLevel.requiresRationaleForAccept && rationale.isEmpty)
    }
}

public struct AtlasAutonomosDecisionOwnerRoute: Codable, Sendable, Equatable {
    public let owner: String
    public let note: String
}

public struct AtlasAutonomosOperatorDecisionReceipt: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let apContract: String
    public let decisionId: String
    public let areaId: String
    public let inboxItemId: String?
    public let findingHash: String
    public let workOrderId: String?
    public let evidencePackHash: String?
    public let operatorActor: String
    public let decision: AtlasAutonomosOperatorDecision
    public let rationale: String
    public let riskLevel: AtlasAutonomosRiskLevel
    public let nextAllowedAction: String
    public let routesToOwner: AtlasAutonomosDecisionOwnerRoute
    public let requiresOwnerExecution: Bool
    public let executed: Bool
    public let atlasAutoDecided: Bool
    public let autoapprovalAllowed: Bool
    public let autoimplementationAllowed: Bool
    public let branchCreated: Bool
    public let providerInvoked: Bool
    public let mutatesTargetRepo: Bool
    public let parallelRegistryCreated: Bool
    public let operatorOwned: Bool
    public let decisionHash: String
    public let decidedAt: String

    /// Segurança de apresentação: o recibo só pode ser apresentado como
    /// decisão gravada enquanto o servidor declara que nada foi executado.
    public var isRecordedDecisionOnly: Bool {
        !executed && !providerInvoked && !branchCreated && !mutatesTargetRepo
    }
}

public enum AtlasAutonomosStartRunMode: String, Codable, Sendable, Equatable, CaseIterable, Identifiable {
    case dryRun = "dry_run"
    case execute

    public var id: String { rawValue }
}

/// O comando apenas enfileira o runner. `execute` é deliberado e exige uma
/// justificativa; o lease de `/live` continua sendo a única confirmação de
/// que o loop começou.
public struct AtlasAutonomosStartRunInput: Codable, Sendable, Equatable {
    public let mode: AtlasAutonomosStartRunMode
    public let operatorActor: String
    public let operatorReason: String
    public let focus: String?

    public init(
        mode: AtlasAutonomosStartRunMode = .dryRun,
        operatorActor: String,
        operatorReason: String = "",
        focus: String? = nil
    ) {
        self.mode = mode
        self.operatorActor = operatorActor.trimmingCharacters(in: .whitespacesAndNewlines)
        self.operatorReason = operatorReason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.focus = focus?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isLocallyValidForSubmission: Bool {
        !operatorActor.isEmpty && (mode != .execute || !operatorReason.isEmpty)
    }
}

public struct AtlasAutonomosStartRunResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let status: String
    public let launch: String
    public let queue: String
    public let areaId: String
    public let focus: String
    public let mode: AtlasAutonomosStartRunMode
    public let execute: Bool
    public let requiresWorker: Bool
    public let operatorActor: String
    public let operatorReasonRecorded: Bool
    public let started: Bool
    public let mergePerformed: Bool
    public let providerInvoked: Bool
    public let note: String

    public var isEnqueued: Bool { status == "enqueued" && launch == "queued_job" && !started }
}

/// Uma transferência preserva a mesma missão `area + focus`. O target começa
/// desconhecido: a fila escolhe o worker e só o lock dele pode comprová-lo.
public struct AtlasAutonomosTransferInput: Codable, Sendable, Equatable {
    public let operatorActor: String
    public let reason: String
    public let focus: String?

    public init(operatorActor: String, reason: String, focus: String? = nil) {
        self.operatorActor = operatorActor.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.focus = focus?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isLocallyValidForSubmission: Bool { !operatorActor.isEmpty && !reason.isEmpty }
}

public struct AtlasAutonomosHandoffSource: Codable, Sendable, Equatable {
    public let runId: String
    public let host: String?
    public let acquiredAt: String?
}

public struct AtlasAutonomosHandoffTarget: Codable, Sendable, Equatable {
    public let status: String
    public let runId: String?
    public let host: String?
    public let claimedAt: String?
}

public struct AtlasAutonomosHandoff: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let handoffId: String
    public let areaId: String
    public let focus: String
    public let status: String
    public let source: AtlasAutonomosHandoffSource
    public let target: AtlasAutonomosHandoffTarget
    public let requestedAt: String?
    public let sourceReleasedAt: String?
    public let successorEnqueuedAt: String?
    public let checkpoint: JSONObject?
    public let updatedAt: String?
}

/// Recibo do pedido e também envelope do polling. Nunca confunde "enfileirado"
/// com alvo iniciado; o estado `target_claimed` só nasce depois do lock real.
public struct AtlasAutonomosTransferResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let status: String
    public let transferRequested: Bool?
    public let started: Bool
    public let areaId: String
    public let focus: String
    public let handoff: AtlasAutonomosHandoff
    public let source: AtlasAutonomosHandoffSource?
    public let target: AtlasAutonomosHandoffTarget?
    public let note: String?

    public var isAwaitingSourceRelease: Bool {
        status == "transfer_requested" && started == false && handoff.target.status == "awaiting_source_release"
    }

    public var isTargetClaimed: Bool {
        status == "target_claimed" && started && handoff.target.status == "claimed" && handoff.target.runId?.isEmpty == false
    }
}

public struct AtlasAutonomosCycleRevertInput: Codable, Sendable, Equatable {
    public let operatorActor: String
    public let reason: String
    public let focus: String?

    public init(operatorActor: String, reason: String, focus: String? = nil) {
        self.operatorActor = operatorActor.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.focus = focus?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isLocallyValidForSubmission: Bool { !operatorActor.isEmpty && !reason.isEmpty }
}

public enum AtlasAutonomosCycleRevertStatus: String, Codable, Sendable, Equatable {
    case enqueued
    case blocked
}

public struct AtlasAutonomosCycleRevertTarget: Codable, Sendable, Equatable {
    public let cycleIndex: Int
    public let cycleId: String
    public let mergeHash: String
}

public struct AtlasAutonomosCycleRevertMission: Codable, Sendable, Equatable {
    public let type: String
    public let status: String
    public let targetMergeHash: String
    public let commandIntent: String
    public let workerImplemented: Bool
    public let workerGap: String?
}

public struct AtlasAutonomosCycleRevertResponse: Decodable, Sendable, Equatable {
    public static let schemaVersion = "atlas.software_company_stewardship.loop_cycle_revert.v1"

    public let schemaVersion: String
    public let status: AtlasAutonomosCycleRevertStatus
    public let areaId: String
    public let focus: String
    public let cycleIndex: Int
    public let cycleId: String
    public let mergeHash: String
    public let revertOf: AtlasAutonomosCycleRevertTarget
    public let receiptId: String
    public let queue: String
    public let operatorActor: String
    public let gitRevertPerformed: Bool
    public let workerImplemented: Bool
    public let mission: AtlasAutonomosCycleRevertMission
    public let note: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion, status, areaId, focus, cycleIndex, cycleId, mergeHash,
             revertOf, receiptId, queue, operatorActor, gitRevertPerformed,
             workerImplemented, mission, note
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.requireSchema(
            Self.schemaVersion,
            forKey: .schemaVersion,
            message: "Unsupported Autonomos cycle revert schema."
        )
        let status = try values.decode(AtlasAutonomosCycleRevertStatus.self, forKey: .status)
        let gitRevertPerformed = try values.decode(Bool.self, forKey: .gitRevertPerformed)
        let workerImplemented = try values.decode(Bool.self, forKey: .workerImplemented)
        guard status == .enqueued, gitRevertPerformed == false, workerImplemented == false else {
            throw DecodingError.dataCorruptedError(
                forKey: .status,
                in: values,
                debugDescription: "M08 only represents an enqueued request; no git revert is claimed by the endpoint."
            )
        }

        self.schemaVersion = schemaVersion
        self.status = status
        self.areaId = try values.decode(String.self, forKey: .areaId)
        self.focus = try values.decode(String.self, forKey: .focus)
        self.cycleIndex = try values.decode(Int.self, forKey: .cycleIndex)
        self.cycleId = try values.decode(String.self, forKey: .cycleId)
        self.mergeHash = try values.decode(String.self, forKey: .mergeHash)
        self.revertOf = try values.decode(AtlasAutonomosCycleRevertTarget.self, forKey: .revertOf)
        self.receiptId = try values.decode(String.self, forKey: .receiptId)
        self.queue = try values.decode(String.self, forKey: .queue)
        self.operatorActor = try values.decode(String.self, forKey: .operatorActor)
        self.gitRevertPerformed = gitRevertPerformed
        self.workerImplemented = workerImplemented
        self.mission = try values.decode(AtlasAutonomosCycleRevertMission.self, forKey: .mission)
        self.note = try values.decodeIfPresent(String.self, forKey: .note)
    }
}

public struct AtlasAutonomosDigestResponse: Decodable, Sendable, Equatable {
    public static let schemaVersion = "atlas.autonomos.digest.v1"

    public let schemaVersion: String
    public let readOnly: Bool
    public let providerSafe: Bool
    public let nextDigestAt: String?
    public let schedule: AtlasAutonomosDigestSchedule
    public let last: AtlasAutonomosDigestLast

    enum CodingKeys: String, CodingKey {
        case schemaVersion, readOnly, providerSafe, nextDigestAt, schedule, last
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(
            Self.schemaVersion,
            forKey: .schemaVersion,
            message: "Unsupported Autonomos digest schema."
        )
        readOnly = try values.decode(Bool.self, forKey: .readOnly)
        providerSafe = try values.decode(Bool.self, forKey: .providerSafe)
        nextDigestAt = try values.decodeIfPresent(String.self, forKey: .nextDigestAt)
        schedule = try values.decode(AtlasAutonomosDigestSchedule.self, forKey: .schedule)
        last = try values.decode(AtlasAutonomosDigestLast.self, forKey: .last)
    }
}

public struct AtlasAutonomosDigestSchedule: Codable, Sendable, Equatable {
    public let available: Bool
    public let source: String?
    public let reason: String?
}

public struct AtlasAutonomosDigestLast: Codable, Sendable, Equatable {
    public let window: AtlasAutonomosDigestWindow
    public let counts: AtlasAutonomosDigestCounts
    public let delivered: [AtlasAutonomosDigestDelivered]
    public let risks: [AtlasAutonomosDigestRisk]
    public let pendingDecisions: [AtlasAutonomosDigestPendingDecision]
    public let sourceStatuses: JSONObject
}

public struct AtlasAutonomosDigestWindow: Codable, Sendable, Equatable {
    public let kind: String
    public let hours: Int
    public let startedAt: String
    public let endedAt: String
    public let timezone: String
    public let areas: [String]
    public let focus: String
}

public struct AtlasAutonomosDigestCounts: Codable, Sendable, Equatable {
    public let delivered: Int
    public let risks: Int
    public let pendingDecisions: Int
}

public struct AtlasAutonomosDigestDelivered: Codable, Sendable, Equatable, Identifiable {
    public let source: String
    public let areaId: String
    public let focus: String
    public let cycleIndex: Int
    public let cycleId: String
    public let outcome: String
    public let cycleFinalStatus: String
    public let mergePerformed: Bool
    public let mergeHash: String
    public let recordedAt: String

    public var id: String { "\(areaId):\(cycleIndex):\(cycleId)" }
}

public struct AtlasAutonomosDigestRisk: Codable, Sendable, Equatable, Identifiable {
    public let source: String
    public let areaId: String
    public let focus: String
    public let cycleIndex: Int?
    public let cycleId: String?
    public let findingId: String?
    public let title: String?
    public let severity: String
    public let reason: String?
    public let blockers: [String]?
    public let quarantined: Bool?
    public let route: String?
    public let routeReason: String?
    public let priorityScore: Int?
    public let evidenceRefs: [String]?
    public let recordedAt: String?

    public var id: String {
        if let findingId { return "\(areaId):finding:\(findingId)" }
        return "\(areaId):cycle:\(cycleIndex.map(String.init) ?? "none"):\(cycleId ?? "none")"
    }
}

public struct AtlasAutonomosDigestPendingDecision: Codable, Sendable, Equatable, Identifiable {
    public let source: String
    public let areaId: String
    public let focus: String
    public let findingId: String
    public let title: String
    public let severity: String
    public let route: String
    public let routeReason: String?
    public let priorityScore: Int
    public let operatorDecisionRequired: Bool

    public var id: String { "\(areaId):\(findingId)" }
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
