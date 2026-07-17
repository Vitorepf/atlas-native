import SwiftUI
import AtlasCore

// Ask label lead — peel de AtlasCodeProvenanceSections+AskLabel.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var askButtonLabelLead: some View {
        Text("✦")
            .font(AtlasFont.serif(12))
            .foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
        Text("perguntar sobre este commit")
            .font(AtlasFont.serifItalic(14))
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
    }
}
