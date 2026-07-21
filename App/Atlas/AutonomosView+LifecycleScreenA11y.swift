import SwiftUI
import AtlasCore

// Screen a11y bind — peel de AutonomosView+Lifecycle.

extension AutonomosView {
    func autonomosLifecycleScreenA11y<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            // children:.contain — NÃO colapsar o ecrã num único label; Nightly/
            // Ritmo/lista precisam de identifiers próprios na árvore a11y.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.autonomosScreen)
            .task { await model.load() }
    }
}
