import Foundation
import AtlasCore

/// Spoken labels do histórico da frota — peel de AutonomosFleetHistorySection (CICLO C).
/// Contagem visível vs total publicada; evento fala só campos do payload.

enum AutonomosFleetHistoryA11y {
    static let visibleCap = 6

    static func spokenSection(total: Int) -> String {
        guard total > 0 else { return "histórico da frota vazio" }
        if total > visibleCap {
            return "histórico da frota, \(visibleCap) de \(total) eventos recentes"
        }
        return "histórico da frota, \(total) evento\(total == 1 ? "" : "s")"
    }

    static func spokenEvent(_ event: AtlasAutonomosFleetHistoryEvent, index: Int, visible: Int) -> String {
        var parts = ["evento \(index + 1) de \(visible)", event.event, "agente \(event.agentKey)"]
        if let by = event.by?.nonEmpty { parts.append("por \(by)") }
        if let account = event.account?.nonEmpty { parts.append("conta \(account)") }
        if let pid = event.pid { parts.append("processo \(pid)") }
        if let duration = event.durationSeconds { parts.append("duração \(AutonomosChrome.uptime(duration))") }
        if let reason = event.reason?.nonEmpty { parts.append(reason) }
        parts.append("em \(event.at)")
        if index == 0 { parts.append("mais recente") }
        return parts.joined(separator: ", ")
    }
}
