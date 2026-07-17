import Foundation

// Decisões do operador — peel de AtlasAutonomosControl (régua anti-inchaço).

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
