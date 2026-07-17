import SwiftUI
import AtlasCore

// Info line init — peel de AutonomosLoadedSection+Lines.

extension AutonomosInfoLine {
    init(_ text: String, spokenLabel: String? = nil, identifier: String? = nil) {
        self.text = text
        self.spokenLabel = spokenLabel ?? text
        self.identifier = identifier
    }
}
