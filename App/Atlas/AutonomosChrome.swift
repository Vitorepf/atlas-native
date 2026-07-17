import SwiftUI
import AtlasCore

enum AutonomosChrome {
    @ViewBuilder
    static func sectionCaption(_ t: String) -> some View {
        Text(t)
            .font(.system(.caption, weight: .semibold)).tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
    }

    @ViewBuilder
    static func tag(_ t: String) -> some View {
        Text(t)
            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            .lineLimit(1)
    }

    @ViewBuilder
    static func digestChip(_ value: String, _ label: String) -> some View {
        HStack(spacing: 5) {
            Text(value).font(AtlasFont.mono(14)).foregroundStyle(AtlasTheme.accent)
                .monospacedDigit()
                .contentTransition(.numericText())
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, 9).padding(.vertical, 6)
        .background(Capsule().fill(AtlasTheme.bgRecessed))
    }

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
