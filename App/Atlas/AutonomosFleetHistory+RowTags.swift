import SwiftUI
import AtlasCore

// History event tags — peel de AutonomosFleetHistory+RowBody.

extension AutonomosFleetHistorySection {
    @ViewBuilder
    func historyEventTags(event: AtlasAutonomosFleetHistoryEvent) -> some View {
        HStack(spacing: 6) {
            AutonomosChrome.tag(event.agentKey)
            if let by = event.by?.nonEmpty { AutonomosChrome.tag(by) }
            if let account = event.account?.nonEmpty { AutonomosChrome.tag(account) }
            if let pid = event.pid { AutonomosChrome.tag("pid \(pid)") }
            if let duration = event.durationSeconds { AutonomosChrome.tag(AutonomosChrome.uptime(duration)) }
        }
        .accessibilityHidden(true)
    }
}
