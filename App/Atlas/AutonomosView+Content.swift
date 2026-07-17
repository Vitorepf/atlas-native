import SwiftUI
import AtlasCore

// Conteúdo por fase — peel de AutonomosView (régua ≤100).
// Shell → AutonomosView+ContentShell.swift
// Loaded → AutonomosView+ContentLoaded.swift

extension AutonomosView {
    @ViewBuilder
    var content: some View {
        autonomosPhaseRouter
    }
}
