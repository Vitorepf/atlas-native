import SwiftUI
import AtlasCore

// Screen spoken — peel de AutonomosView+A11y.
// Phase → AutonomosView+A11ySpoken+Phase.swift

extension AutonomosView {
    func spokenScreenLabel() -> String {
        spokenScreenPhaseLabel()
    }

    static let screenHint = "catálogo local neste iPhone; pergunta e manda só pela pílula"
}
