import SwiftUI
import AtlasCore

/// Detalhe da área selecionada: métricas, placement, entregas, controles.
/// Header/métricas → AutonomosAreaDetailSection+Header.swift
struct AutonomosAreaDetailSection: View {
    let area: AtlasAutonomosArea
    let model: AutonomosModel
    @Binding var control: AtlasAutonomosRunAction?
    @Binding var startRunMode: AtlasAutonomosStartRunMode?
    @Binding var showTransferSheet: Bool
    let onOpenDetail: (AutonomosDetailSheet) -> Void
    let onSelfConstructionReceipt: (SelfConstructionReceipt) -> Void

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var cyclesCount: Int? { model.cycles?.ledgerRecordCountTotal }
    var workOrderCount: Int? { model.backlog?.workOrders.count }
    var inboxCount: Int? { model.backlog?.inboxItems.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            areaHeader
            Text(area.objective).font(.footnote).foregroundStyle(AtlasTheme.textSecondary).fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            Divider().overlay(AtlasTheme.separatorSoft).accessibilityHidden(true)
            metricsRow
            backlogDetailShortcuts
            placementSection
            AutonomosAreaDeliveredSection(
                area: area,
                model: model,
                onSelfConstructionReceipt: onSelfConstructionReceipt
            )
            ownedSystemsBlock
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
