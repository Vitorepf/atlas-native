import SwiftUI
import AtlasCore

// Header + métricas da área — peel de AutonomosAreaDetailSection.

extension AutonomosAreaDetailSection {
    var areaHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(area.areaName).font(AtlasFont.serif(24, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                Text(area.focus).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Spacer()
            Text("tier \(area.autonomyTier)/\(area.maxTierForArea)")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AutonomosAreaDetailA11y.spokenHeader(area: area, isPaused: model.live?.isPaused))
        .accessibilityAddTraits(.isHeader)
    }

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
