import Foundation
import AtlasCore

/// Fleet history event identity spoken — peel de AutonomosFleetHistory+A11yEvent.

enum AutonomosFleetHistoryA11yEventIdentity {
    static func spokenIdentity(_ event: AtlasAutonomosFleetHistoryEvent, index: Int, visible: Int) -> [String] {
        var parts = ["evento \(index + 1) de \(visible)", event.event, "agente \(event.agentKey)"]
        if let by = event.by?.nonEmpty { parts.append("por \(by)") }
        if let account = event.account?.nonEmpty { parts.append("conta \(account)") }
        return parts
    }
}
