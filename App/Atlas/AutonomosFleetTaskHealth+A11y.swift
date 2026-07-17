import Foundation
import AtlasCore

/// Spoken labels da saúde da fila — peel de AutonomosTaskHealthSection (CICLO C).
/// Saudável = uma linha quieta; incidente só com `incidents.present` e contagens publicadas.

enum AutonomosTaskHealthA11y {
    static func spokenQuiet(servableNow: Int, activeLeases: Int) -> String {
        "fila estável, \(servableNow) servíve\(servableNow == 1 ? "l" : "is"), \(activeLeases) lease\(activeLeases == 1 ? "" : "s") ativo\(activeLeases == 1 ? "" : "s")"
    }

    static func spokenIncident(_ health: AtlasAutonomosTaskHealthResponse) -> String {
        var parts = ["saúde da fila, incidente ativo"]
        parts.append(spokenMetrics(health))
        if !health.leases.matchesClaimed {
            parts.append("leases não batem com tarefas reivindicadas")
        }
        if !health.incidents.flags.isEmpty {
            parts.append(health.incidents.flags.joined(separator: ", "))
        }
        let pressure = health.operating.queuePressure.trimmingCharacters(in: .whitespacesAndNewlines)
        if !pressure.isEmpty {
            parts.append("pressão \(pressure)")
        }
        let action = health.operating.recommendedAction.trimmingCharacters(in: .whitespacesAndNewlines)
        if !action.isEmpty {
            parts.append(action)
        }
        return parts.joined(separator: ", ")
    }

    private static func spokenMetrics(_ health: AtlasAutonomosTaskHealthResponse) -> String {
        let t = health.tasks
        let l = health.leases
        return "\(t.servableNow) servíveis agora, \(t.claimed) reivindicadas, \(t.blocked) bloqueadas, \(l.active) leases ativos, \(t.completed) completas, \(t.recoverable) recuperáveis"
    }
}
