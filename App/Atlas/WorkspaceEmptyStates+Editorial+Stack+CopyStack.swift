import SwiftUI
import AtlasCore

// Editorial copy stack — peel de WorkspaceEmptyStates+Editorial+Stack.
// Glyph → WorkspaceEmptyStates+Editorial+Stack+Glyph.swift

extension AtlasEditorialGlyphEmpty {
    var editorialCopyStack: some View {
        VStack(spacing: 8) {
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
