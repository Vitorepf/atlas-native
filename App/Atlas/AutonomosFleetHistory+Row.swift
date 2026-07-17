import SwiftUI
import AtlasCore

// Event row — peel de AutonomosFleetHistory.
// Body → AutonomosFleetHistory+RowBody.swift

extension AutonomosFleetHistorySection {
    @ViewBuilder
    func historyEventRow(event: AtlasAutonomosFleetHistoryEvent, index: Int, visibleCount: Int) -> some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 0) {
                Circle()
                    .fill(index == 0 ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.35))
                    .frame(width: 7, height: 7)
                    .padding(.top, 5)
                if index < visibleCount - 1 {
                    Rectangle()
                        .fill(AtlasTheme.accent.opacity(0.18))
                        .frame(width: 1.5, height: 34)
                }
            }
            .accessibilityHidden(true)
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
