import SwiftUI
import AtlasCore

// Métricas — peel de AutonomosAreaDetailSection+Header.
// Sistemas → AutonomosAreaDetailSection+Systems.swift

extension AutonomosAreaDetailSection {
    var metricsRow: some View {
        HStack(spacing: 12) {
            DetailMetric(label: "ciclos", value: AutonomosAreaDetailA11y.metricDisplay(cyclesCount))
            DetailMetric(label: "tarefas", value: AutonomosAreaDetailA11y.metricDisplay(workOrderCount))
            DetailMetric(label: "inbox", value: AutonomosAreaDetailA11y.metricDisplay(inboxCount))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AutonomosAreaDetailA11y.spokenMetrics(cycles: cyclesCount, workOrders: workOrderCount, inbox: inboxCount))
        .animation(reduceMotion ? nil : .default, value: cyclesCount)
        .animation(reduceMotion ? nil : .default, value: workOrderCount)
        .animation(reduceMotion ? nil : .default, value: inboxCount)
    }
}
