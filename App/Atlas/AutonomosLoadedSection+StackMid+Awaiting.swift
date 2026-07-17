import SwiftUI
import AtlasCore

// Awaiting section — peel de AutonomosLoadedSection+StackMid.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackMidAwaiting: some View {
        AutonomosAwaitingYouSection(backlog: model.backlog) { detailSheet = $0 }
            .animation(
                reduceMotion ? nil : AtlasMotion.editorial,
                value: AutonomosAwaitingYouSection.decisionCount(in: model.backlog)
            )
    }
}
