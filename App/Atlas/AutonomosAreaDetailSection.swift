import SwiftUI
import AtlasCore

/// Detalhe da área selecionada: métricas, placement, entregas, controles.
struct AutonomosAreaDetailSection: View {
    let area: AtlasAutonomosArea
    let model: AutonomosModel
    @Binding var control: AtlasAutonomosRunAction?
    @Binding var startRunMode: AtlasAutonomosStartRunMode?
    @Binding var showTransferSheet: Bool
    let onOpenDetail: (AutonomosDetailSheet) -> Void
    let onSelfConstructionReceipt: (SelfConstructionReceipt) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var cyclesCount: Int? { model.cycles?.ledgerRecordCountTotal }
    private var workOrderCount: Int? { model.backlog?.workOrders.count }
    private var inboxCount: Int? { model.backlog?.inboxItems.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            Text(area.objective).font(.footnote).foregroundStyle(AtlasTheme.textSecondary).fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            Divider().overlay(AtlasTheme.separatorSoft).accessibilityHidden(true)
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
            backlogDetailShortcuts
            placementSection
            AutonomosAreaDeliveredSection(
                area: area,
                model: model,
                onSelfConstructionReceipt: onSelfConstructionReceipt
            )
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
            AutonomosAreaControls(
                areaName: area.areaName,
                isPaused: model.live?.isPaused == true,
                canControl: model.canControlSelectedArea,
                onResume: { control = .resume },
                onPause: { control = .pause },
                onTransfer: { showTransferSheet = true },
                onKill: { control = .kill },
                onDryRun: { startRunMode = .dryRun },
                onExecute: { startRunMode = .execute }
            )
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(AtlasTheme.surface))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AtlasTheme.separator, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosAreaDetailSection)
    }
}
