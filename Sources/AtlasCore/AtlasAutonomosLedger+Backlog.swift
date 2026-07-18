import Foundation

/// Backlog items e budgets — peel de AtlasAutonomosLedger.

public struct AtlasAutonomosWorkOrder: Codable, Sendable, Equatable, Identifiable {
    public let workOrderId: String
    public let findingHash: String
    public let title: String
    public let route: String
    /// O servidor emite `null` quando o work order ainda não roteou para um
    /// owner service; ausência é estado real, não erro de contrato.
    public let routesToOwnerService: String?
    public let riskLevel: String
    public let priorityScore: Int
    public let requiresBranchIsolation: Bool
    public let operatorDecisionRequired: Bool
    public let evidenceRequired: Bool
    public let executionExecuted: Bool
    public let status: String
    public let createdAt: String?

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
    public let createdAt: String?

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
