import SwiftUI
import AtlasCore

// Ficha a11y bind — peel de ArtifactFileFicha.

extension ArtifactFileFicha {
    func fichaA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ArtifactViewerA11y.spokenFicha(name: name, subtitle: subtitle))
    }
}
