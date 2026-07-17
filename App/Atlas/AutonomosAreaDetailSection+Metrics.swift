import SwiftUI
import AtlasCore

// Métricas + sistemas — peel de AutonomosAreaDetailSection+Header.

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

    @ViewBuilder
    var ownedSystemsBlock: some View {
        if !area.ownedSystems.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text("SISTEMAS SOB RESPONSABILIDADE").font(AtlasFont.mono(10)).tracking(0.9).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text(area.ownedSystems.joined(separator: " · ")).font(.caption).foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosAreaDetailA11y.spokenOwnedSystems(area.ownedSystems))
        }
    }
}
