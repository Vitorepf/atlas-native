import SwiftUI
import AtlasCore

// Event row — peel de AutonomosFleetHistory.
// Body → AutonomosFleetHistory+RowBody.swift
// Spine → AutonomosFleetHistory+RowSpine.swift

extension AutonomosFleetHistorySection {
    @ViewBuilder
    func historyEventRow(event: AtlasAutonomosFleetHistoryEvent, index: Int, visibleCount: Int) -> some View {
        HStack(alignment: .top, spacing: 10) {
            historyEventSpine(index: index, visibleCount: visibleCount)
            historyEventBody(event: event)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AutonomosFleetHistoryA11y.spokenEvent(event, index: index, visible: visibleCount)
        )
        .accessibilityIdentifier(A11yID.autonomosFleetHistoryRow(index))
    }
}
