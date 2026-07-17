import SwiftUI
import UIKit
import AtlasCore

// Diff preview — peel de ArtifactViewer+TextPreview.

extension ArtifactPreviewContent {
    @ViewBuilder
    var diffPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(String(decoding: content.data, as: UTF8.self))
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .textSelection(.enabled)
        }
        .frame(maxHeight: 360)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ArtifactViewerA11y.spokenPreview(item: item))
        .accessibilityHint("arraste horizontalmente para ler o diff")
    }
}
