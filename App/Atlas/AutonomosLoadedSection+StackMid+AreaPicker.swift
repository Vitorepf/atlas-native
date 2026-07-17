import SwiftUI
import AtlasCore

// Area picker — peel de AutonomosLoadedSection+StackMid.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackMidAreaPicker: some View {
        AutonomosAreaPicker(
            areas: model.areas,
            selectedAreaID: model.selectedAreaID
        ) { id in
            Task { await model.selectArea(id) }
        }
    }
}
