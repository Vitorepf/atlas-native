import SwiftUI
import AtlasCore

// Arena lifecycle + a11y — peel de AtlasArenaView.

extension AtlasArenaView {
    func arenaLifecycleChrome<Content: View>(_ content: Content) -> some View {
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
            .task {
                if case .idle = model.phase {
                    await model.load()
                }
            }
            .onAppear { model.setVisible(true) }
            .onDisappear { model.setVisible(false) }
            .refreshable { await model.load() }
    }
}
