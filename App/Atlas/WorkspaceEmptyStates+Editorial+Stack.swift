import SwiftUI
import AtlasCore

// Editorial empty stack — peel de WorkspaceEmptyStates+Editorial+Glyph.

extension AtlasEditorialGlyphEmpty {
    var editorialStack: some View {
        VStack(spacing: 14) {
            Text("✦")
                .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
                .accessibilityHidden(true)
            Text(headline)
                .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            if let footnote {
                Text(footnote)
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .accessibilityHidden(true)
            }
        }
    }
}
