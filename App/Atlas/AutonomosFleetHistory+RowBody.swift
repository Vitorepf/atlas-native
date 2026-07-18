import SwiftUI
import AtlasCore

// Event body text — peel de AutonomosFleetHistory+Row.
// Tags → AutonomosFleetHistory+RowTags.swift
// Meta → AutonomosFleetHistory+RowMeta.swift

extension AutonomosFleetHistorySection {
    @ViewBuilder
    func historyEventBody(event: AtlasAutonomosFleetHistoryEvent) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(AutonomosFleetHistoryCopy.event(event.event))
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            historyEventTags(event: event)
            historyEventMeta(event: event)
        }
    }
}
