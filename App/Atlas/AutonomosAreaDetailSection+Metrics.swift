import SwiftUI
import AtlasCore

// Métricas — peel de AutonomosAreaDetailSection+Header.
// Sistemas → AutonomosAreaDetailSection+Systems.swift
// Chips → AutonomosAreaDetailSection+MetricsChips.swift

extension AutonomosAreaDetailSection {
    var metricsRow: some View {
        metricsChips
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosAreaDetailA11y.spokenMetrics(cycles: cyclesCount, workOrders: workOrderCount, inbox: inboxCount))
            .animation(reduceMotion ? nil : .default, value: cyclesCount)
            .animation(reduceMotion ? nil : .default, value: workOrderCount)
            .animation(reduceMotion ? nil : .default, value: inboxCount)
    }
}
