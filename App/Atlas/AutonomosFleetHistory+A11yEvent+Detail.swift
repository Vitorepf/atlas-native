import Foundation
import AtlasCore

/// Fleet history event detail spoken — peel de AutonomosFleetHistory+A11yEvent.

enum AutonomosFleetHistoryA11yEventDetail {
    static func spokenDetail(_ event: AtlasAutonomosFleetHistoryEvent, index: Int) -> [String] {
        var parts: [String] = []
        if let pid = event.pid { parts.append("processo \(pid)") }
        if let duration = event.durationSeconds { parts.append("duração \(AutonomosChrome.uptime(duration))") }
        if let reason = event.reason?.nonEmpty { parts.append(reason) }
        parts.append("em \(event.at)")
        if index == 0 { parts.append("mais recente") }
        return parts
    }
}
