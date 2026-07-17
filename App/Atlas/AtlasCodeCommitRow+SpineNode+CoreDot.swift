import SwiftUI
import AtlasCore

// Core dot — peel de AtlasCodeCommitRow+SpineNode.

extension AtlasCodeCommitRow {
    var spineCoreDot: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .overlay(Circle().strokeBorder(AtlasTheme.bg, lineWidth: 2))
            .accessibilityHidden(true)
    }
}
