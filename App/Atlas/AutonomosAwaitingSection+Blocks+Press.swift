import SwiftUI
import AtlasCore

// Detail chip press — peel de AutonomosAwaitingSection+Blocks.

extension AutonomosDetailChipButton {
    var chipPressAction: () -> Void {
        {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        }
    }
}
