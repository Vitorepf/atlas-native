import SwiftUI
import AtlasCore

// Arena a11y chrome — peel de AtlasArenaView+Lifecycle.

extension AtlasArenaView {
    func arenaLifecycleA11y<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Arena")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier(A11yID.arenaScreen)
            .accessibilityLabel(spokenArenaScreenLabel())
            .accessibilityHint(
                model.isDomainUnavailable && model.composite == nil
                    ? domainUnavailableHint
                    : "medição de regressão dos motores"
            )
    }
}
