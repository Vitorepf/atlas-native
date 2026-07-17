import SwiftUI

// Spoken + hint — peel de AutonomosAreaSection+CycleHelpers.

extension AutonomosAreaControls {
    func spoken(_ label: String) -> String {
        canControl ? label : "\(label), indisponível"
    }

    func hint(_ text: String) -> String {
        canControl ? text : spokenContainerHint
    }
}
