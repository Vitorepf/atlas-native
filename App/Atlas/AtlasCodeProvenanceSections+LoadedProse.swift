import SwiftUI
import AtlasCore

// Provenance prose/quote — peel de AtlasCodeProvenanceSections+Loaded.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceProseBlocks(_ provenance: AtlasCodeProvenance) -> some View {
        if let body = provenance.commitBody?.nonEmpty {
            Text(AtlasCodeCommitBody.prose(body))
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier(A11yID.codeCommitBody)
        }

        if let quote = provenance.operatorQuote?.nonEmpty {
            pullQuote(quote)
        }
    }
}
