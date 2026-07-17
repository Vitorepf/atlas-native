import SwiftUI
import AtlasCore

// Autônomos lifecycle chrome — peel de AutonomosView.
// Rhythm → AutonomosView+LifecycleRhythm.swift
// Sheets → AutonomosView+LifecycleSheetsBind.swift

extension AutonomosView {
    func autonomosLifecycleChrome<Content: View>(_ content: Content) -> some View {
        autonomosRhythmTask(
            autonomosLifecycleSheets(
                autonomosLifecycleScreenA11y(content)
            )
        )
    }
}
