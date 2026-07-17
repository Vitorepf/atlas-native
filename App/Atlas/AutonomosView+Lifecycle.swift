import SwiftUI
import AtlasCore

// Autônomos lifecycle chrome — peel de AutonomosView.
// Rhythm → AutonomosView+LifecycleRhythm.swift
// Sheets → AutonomosView+LifecycleSheetsBind.swift

extension AutonomosView {
    func autonomosLifecycleChrome<Content: View>(_ content: Content) -> some View {
        autonomosRhythmTask(
            autonomosLifecycleSheets(
                content
                    .navigationBarHidden(true)
                    .accessibilityIdentifier(A11yID.autonomosScreen)
                    .accessibilityLabel(spokenScreenLabel())
                    .accessibilityHint(Self.screenHint)
                    .task { if case .idle = model.phase { await model.load() } }
            )
        )
    }
}
