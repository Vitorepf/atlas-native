import Foundation
import AtlasCore

/// Spoken event — peel de AutonomosFleetHistory+A11y.

enum AutonomosFleetHistoryA11yEvent {
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
