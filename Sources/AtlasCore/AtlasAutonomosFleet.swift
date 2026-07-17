import Foundation

/// Frota governada, histórico append-only e saúde agregada da fila do músculo
/// externo. Contratos globais — não atribuídos artificialmente a uma área.
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
