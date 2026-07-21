import SwiftUI

/// Espinha decorativa do grafo — peel de AtlasCodeCommitRow+Spine (CICLO C).
/// Sem spoken próprio; o rótulo composto vive em AtlasCodeCommitRow+A11y.

extension View {
    /// Silencia conectores e nó; VoiceOver só ouve a linha do commit.
    func atlasCodeGraphSpineDecorative() -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(true)
    }
}
