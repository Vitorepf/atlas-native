import Foundation

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
