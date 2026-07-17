import SwiftUI
import AtlasCore

// LazyVStack do corpo Autônomos — peel de AutonomosLoadedSection (régua ≤100).
// Head → +StackHead.swift · Tail → +StackTail.swift
// Area → AutonomosLoadedSection+StackArea.swift

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
            loadedAreaDetail
            loadedStackTail
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 10).padding(.bottom, 32)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: receiptPhaseID)
    }
}
