import SwiftUI
import AtlasCore

// Pull quote bar — peel de AtlasCodeProvenanceSections+PullQuote.

extension AtlasCodeProvenanceSheet {
    var pullQuoteBar: some View {
        Rectangle()
            .fill(AtlasTheme.accent.opacity(0.55))
            .frame(width: 2)
    }
}
