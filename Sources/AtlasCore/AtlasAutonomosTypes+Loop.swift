import Foundation

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
