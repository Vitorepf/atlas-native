import SwiftUI
import AtlasCore

enum AutonomosChrome {
    static func uptime(_ seconds: Int) -> String {
        if seconds >= 86_400 { return "\(seconds / 86_400)d \((seconds % 86_400) / 3600)h" }
        if seconds >= 3600 { return "\(seconds / 3600)h \((seconds % 3600) / 60)m" }
        return "\(seconds / 60)m"
    }

    static func relativeAge(from date: Date, now: Date = Date()) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(date)))
        let days = seconds / 86_400
        if days > 0 { return days == 1 ? "1 dia" : "\(days) dias" }
        let hours = seconds / 3_600
        if hours > 0 { return "\(hours)h" }
        return "\(max(1, seconds / 60))min"
    }
}

enum AutonomosFleetHealth {
    static func isQuiet(fleet: AtlasAutonomosFleetResponse, incidentPresent: Bool) -> Bool {
        !incidentPresent
            && !fleet.agents.isEmpty
            && fleet.agents.allSatisfy { $0.alive && $0.desired && $0.authorized }
    }

    static func agentNeedsAttention(_ agent: AtlasAutonomosFleetAgent) -> Bool {
        !agent.alive || !agent.desired || !agent.authorized
    }
}
