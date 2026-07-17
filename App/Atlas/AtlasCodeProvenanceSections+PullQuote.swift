import SwiftUI
import AtlasCore

// Citação do operador — peel de AtlasCodeProvenanceSections+Files.
// Bar → AtlasCodeProvenanceSections+PullQuote+Bar.swift
// QuoteStack → AtlasCodeProvenanceSections+PullQuote+QuoteStack.swift

extension AtlasCodeProvenanceSheet {
    func pullQuote(_ quote: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            pullQuoteBar
            pullQuoteStack(quote)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel("sua frase: \(quote)")
    }
}
