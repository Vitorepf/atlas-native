import SwiftUI
import AtlasCore

// Awaiting + picker do stack — peel de AutonomosLoadedSection+Stack.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackMid: some View {
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
    }
}
