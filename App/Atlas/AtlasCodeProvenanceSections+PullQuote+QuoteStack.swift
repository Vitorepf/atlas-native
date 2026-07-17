import SwiftUI
import AtlasCore

// Pull quote text stack — peel de AtlasCodeProvenanceSections+PullQuote.

extension AtlasCodeProvenanceSheet {
    func pullQuoteStack(_ quote: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\u{201C}\(quote)\u{201D}")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("sua frase")
                .font(.system(size: 9))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}
