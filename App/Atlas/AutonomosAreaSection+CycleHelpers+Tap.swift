import SwiftUI

// Tap helper — peel de AutonomosAreaSection+CycleHelpers.

extension AutonomosAreaControls {
    func tap(_ action: () -> Void) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        action()
    }
}
