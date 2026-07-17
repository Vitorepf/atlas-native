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
