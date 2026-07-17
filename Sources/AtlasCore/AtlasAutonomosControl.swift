import Foundation

/// Controle do loop (start/pause/resume/kill), decisões do operador,
/// transferência de missão e recibos de revert. Sinais governados, não
/// promessas de processo.
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
