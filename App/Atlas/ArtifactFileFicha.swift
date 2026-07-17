import SwiftUI
import AtlasCore

// Ficha do artefato — peel de ArtifactViewer.

struct ArtifactFileFicha: View {
    let name: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(AtlasFont.serif(17, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subtitle)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArtifactViewerA11y.spokenFicha(name: name, subtitle: subtitle))
    }
}
