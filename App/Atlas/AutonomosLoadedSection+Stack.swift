import SwiftUI
import AtlasCore

// LazyVStack do corpo Autônomos — peel de AutonomosLoadedSection (régua ≤100).
// Head → +StackHead.swift · Tail → +StackTail.swift

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStack: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            loadedStackHead
            AutonomosAwaitingYouSection(backlog: model.backlog) { detailSheet = $0 }
                .animation(
                    reduceMotion ? nil : AtlasMotion.editorial,
                    value: AutonomosAwaitingYouSection.decisionCount(in: model.backlog)
                )
            AutonomosAreaPicker(
                areas: model.areas,
                selectedAreaID: model.selectedAreaID
            ) { id in
                Task { await model.selectArea(id) }
            }
            if let area = model.selectedArea {
                AutonomosAreaDetailSection(
                    area: area,
                    model: model,
                    control: $control,
                    startRunMode: $startRunMode,
                    showTransferSheet: $showTransferSheet,
                    onOpenDetail: { detailSheet = $0 },
                    onSelfConstructionReceipt: { selfConstructionReceipt = $0 }
                )
            }
            loadedStackTail
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 10).padding(.bottom, 32)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: receiptPhaseID)
    }
}
