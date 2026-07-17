import SwiftUI
import AtlasCore

// Section caption — peel de AutonomosAreaDeliveredSection+Filled.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredFilledCaption(isSelf: Bool, deliveredTotal: Int, visible: Int) -> some View {
        AutonomosChrome.sectionCaption(
            AutonomosAreaDeliveredA11y.sectionCaption(isSelf: isSelf, total: deliveredTotal, visible: visible)
        )
    }
}
