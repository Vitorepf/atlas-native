import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

// --- ArtifactFileFicha+A11yBind.swift ---
extension ArtifactFileFicha {
    func fichaA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ArtifactViewerA11y.spokenFicha(name: name, subtitle: subtitle))
    }
}

// --- ArtifactFileFicha+NameStack.swift ---
extension ArtifactFileFicha {
    var fichaNameStack: some View {
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
    }
}

// --- ArtifactFileFicha.swift ---
struct ArtifactFileFicha: View {
    let name: String
    let subtitle: String

    var body: some View {
        fichaA11yBind(fichaNameStack)
    }
}
