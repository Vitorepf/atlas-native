import Foundation
import AtlasCore

/// Incident spoken metrics — peel de AutonomosFleetTaskHealth+A11y.

enum AutonomosTaskHealthA11yMetrics {
    static func spokenMetrics(_ health: AtlasAutonomosTaskHealthResponse) -> String {
        let t = health.tasks
        let l = health.leases
        return "\(t.servableNow) servíveis agora, \(t.claimed) reivindicadas, \(t.blocked) bloqueadas, \(l.active) leases ativos, \(t.completed) completas, \(t.recoverable) recuperáveis"
    }
}
