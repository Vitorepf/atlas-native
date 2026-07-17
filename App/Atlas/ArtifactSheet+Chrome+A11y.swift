import SwiftUI
import UIKit
import AtlasCore

// Sheet a11y — peel de ArtifactSheet+Chrome.

extension ArtifactSheet {
    func artifactSheetA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.artifactsSheet)
            .accessibilityLabel(spokenArtifactsSheetLabel())
            .accessibilityHint("lista e preview só com itens publicados no contrato")
    }
}
