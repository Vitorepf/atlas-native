import SwiftUI
import AtlasCore

// Week body — peel de AtlasCodeGraphChrome+Week.
// Quiet → AtlasCodeGraphChrome+WeekQuiet.swift
// Title → AtlasCodeGraphChrome+WeekTitle.swift

extension AtlasCodeView {
    @ViewBuilder
    func weekBody(_ week: AtlasCodeWeek) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            weekTitleRow(week)
            weekMetricsOrQuiet(week)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AtlasCodeWeekUI.spokenLabel(week))
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier(A11yID.codeWeek)
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.28),
            value: AtlasCodeWeekUI.weekPhaseID(week)
        )
    }
}
