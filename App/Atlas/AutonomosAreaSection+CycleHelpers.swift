import SwiftUI

// Cycle helpers — peel de AutonomosAreaSection+Cycle.

extension AutonomosAreaControls {
    func tap(_ action: () -> Void) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        action()
    }

    func spoken(_ label: String) -> String {
        canControl ? label : "\(label), indisponível"
    }

    func hint(_ text: String) -> String {
        canControl ? text : spokenContainerHint
    }
}
