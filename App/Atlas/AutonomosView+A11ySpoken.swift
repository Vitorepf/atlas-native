import SwiftUI
import AtlasCore

// Screen spoken — peel de AutonomosView+A11y.
// Phase → AutonomosView+A11ySpoken+Phase.swift

extension AutonomosView {
    func spokenScreenLabel() -> String {
        spokenScreenPhaseLabel()
    }

    static let screenHint = "frota, digest e áreas só com dados publicados pelo servidor"
}
