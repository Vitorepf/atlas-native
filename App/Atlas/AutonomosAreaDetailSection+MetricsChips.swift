import SwiftUI
import AtlasCore

// Metric chips — peel de AutonomosAreaDetailSection+Metrics.

extension AutonomosAreaDetailSection {
    var metricsChips: some View {
        HStack(spacing: 12) {
            DetailMetric(label: "ciclos", value: AutonomosAreaDetailA11y.metricDisplay(cyclesCount))
            DetailMetric(label: "tarefas", value: AutonomosAreaDetailA11y.metricDisplay(workOrderCount))
            DetailMetric(label: "inbox", value: AutonomosAreaDetailA11y.metricDisplay(inboxCount))
        }
    }
}
