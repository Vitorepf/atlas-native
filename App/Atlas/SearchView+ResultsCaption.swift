import SwiftUI
import AtlasCore

// Results caption — peel de SearchView+Results.

extension SearchResultsSection {
    var resultsCaption: some View {
        Text("\(results.count) resultado\(results.count == 1 ? "" : "s")")
            .font(AtlasFont.mono(10, .semibold)).tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("\(results.count) conversa\(results.count == 1 ? "" : "s") com ‘\(query)’")
            .accessibilityIdentifier(A11yID.searchResultsCaption)
    }
}
