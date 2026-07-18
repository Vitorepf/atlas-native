import SwiftUI
import AtlasCore

// Screen a11y bind — peel de AutonomosView+Lifecycle.

extension AutonomosView {
    func autonomosLifecycleScreenA11y<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(A11yID.autonomosScreen)
            .accessibilityLabel(spokenScreenLabel())
            .accessibilityHint(Self.screenHint)
            .task { if case .idle = model.phase { await model.load() } }
    }
}
