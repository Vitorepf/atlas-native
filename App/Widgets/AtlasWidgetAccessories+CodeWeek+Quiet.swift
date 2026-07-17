import WidgetKit
import SwiftUI
import AtlasCore

// Corpo quieto / métricas — peel de CodeWeek+Body.
// QuietBranch → AtlasWidgetAccessories+CodeWeek+Quiet+QuietBranch.swift
// MetricsStack → AtlasWidgetAccessories+CodeWeek+Quiet+MetricsStack.swift

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekMetricsOrQuiet(_ week: AtlasNativeSnapshot.Week) -> some View {
        if CodeWeekWidgetA11y.isQuiet(week) {
            weekQuietBranch()
        } else {
            weekMetricsStack(week)
        }
    }
}
