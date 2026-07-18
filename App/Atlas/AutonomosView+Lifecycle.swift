import SwiftUI
import AtlasCore

// Autônomos lifecycle chrome — peel de AutonomosView.
// Sheets → AutonomosView+LifecycleSheetsBind.swift

extension AutonomosView {
    func autonomosLifecycleChrome<Content: View>(_ content: Content) -> some View {
        autonomosLifecycleSheets(
            autonomosLifecycleScreenA11y(content)
        )
    }
}
