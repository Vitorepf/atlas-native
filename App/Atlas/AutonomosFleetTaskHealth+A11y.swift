import Foundation
import AtlasCore

/// Spoken labels da saúde da fila — peel de AutonomosTaskHealthSection (CICLO C).
/// Saudável = uma linha quieta; incidente só com `incidents.present` e contagens publicadas.
/// Metrics → AutonomosFleetTaskHealth+A11yMetrics.swift
/// Incident → AutonomosFleetTaskHealth+A11yIncident.swift

enum AutonomosTaskHealthA11y {
    static func spokenQuiet(servableNow: Int, activeLeases: Int) -> String {
        "fila estável, \(servableNow) servíve\(servableNow == 1 ? "l" : "is"), \(activeLeases) lease\(activeLeases == 1 ? "" : "s") ativo\(activeLeases == 1 ? "" : "s")"
    }

    static func spokenIncident(_ health: AtlasAutonomosTaskHealthResponse) -> String {
        var parts = ["saúde da fila, incidente ativo"]
        parts.append(AutonomosTaskHealthA11yMetrics.spokenMetrics(health))
        parts.append(contentsOf: spokenIncidentExtras(health))
        return parts.joined(separator: ", ")
    }
}
