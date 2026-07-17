import SwiftUI
import AtlasCore

// Citação do operador — peel de AtlasCodeProvenanceSections+Files.

extension AtlasCodeProvenanceSheet {
    func pullQuote(_ quote: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            Rectangle()
                .fill(AtlasTheme.accent.opacity(0.55))
                .frame(width: 2)
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
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel("sua frase: \(quote)")
    }
}
