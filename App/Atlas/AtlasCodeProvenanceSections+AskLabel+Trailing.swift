import SwiftUI
import AtlasCore

// Ask label trailing — peel de AtlasCodeProvenanceSections+AskLabel.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var askButtonLabelTrailing: some View {
        Spacer(minLength: 0)
        Image(systemName: "arrow.up.right")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}
