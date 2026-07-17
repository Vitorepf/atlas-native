import Foundation

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
    public let createdAt: String?

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
