import AtlasCore
import SwiftUI

// Nav shell — peel de AtlasCodeRadarView.

extension AtlasCodeRadarView {
    @ViewBuilder
    func radarNavShell<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Código")
            .navigationBarTitleDisplayMode(.inline)
            .task { if model.phase == .idle { await model.load() } }
            .refreshable { await model.load() }
            .accessibilityIdentifier(A11yID.radarScreen)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(radarShellSpokenLabel)
            .accessibilityHint(Self.shellHint)
    }
}
