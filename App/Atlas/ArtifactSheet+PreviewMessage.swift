import SwiftUI
import AtlasCore

// Preview message failure — peel de ArtifactSheet+PreviewFailure.

extension ArtifactSheet {
    @ViewBuilder
    func previewMessageFailure(_ message: String) -> some View {
        Text(message)
            .font(AtlasFont.serifItalic(14))
            .foregroundStyle(AtlasTheme.domOperacional)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("preview falhou, \(message)")
    }
}
