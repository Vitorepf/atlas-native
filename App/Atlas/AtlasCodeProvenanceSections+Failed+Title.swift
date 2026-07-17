import SwiftUI
import AtlasCore

// Failed title — peel de AtlasCodeProvenanceSections+Failed.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var provenanceFailedTitle: some View {
        Text("proveniência indisponível")
            .font(AtlasFont.serifItalic(15))
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
    }
}
