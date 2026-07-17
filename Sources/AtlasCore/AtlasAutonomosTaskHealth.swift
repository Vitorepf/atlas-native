import Foundation

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
